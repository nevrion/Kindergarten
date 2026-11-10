#!/usr/bin/env python3
"""Erzeugt Kindergarten/AbilityData.lua: Klassenfähigkeiten mit Rängen und Lernstufen aus den DB2-Tabellen von WoW Forever
(Produkt wowf bei wago.tools): SkillLineAbility, SkillLine, SpellLevels, SpellName, Talent.

Aufruf:  python3 tools/gen_abilities.py [Build]      (ohne Build: neuester wowf-Build)

Regeln: nur Skill-Linien der Kategorie 7 (Klassen), ohne Gravuren/Runen/Begleiter-Linien, ohne Zauber mit AcquireMethod 3
(Runen), ohne Zauber-IDs von 390000 bis 999999 (Season-of-Discovery-Runen) und ohne Reittier-Auren auf Stufe 1 (normale
Reittiere; die Klassen-Reittiere ab Stufe 40 bleiben). Eine Skill-Linie mit leerer Klassenmaske gehört zur Klasse, die in den
anderen Zeilen der Linie steht. Ränge desselben Namens werden zu einer Fähigkeit zusammengefasst, gleiche Lernstufen nur einmal.
Die Zauber der Talente selbst fallen weg; bleiben spätere Ränge übrig (Aimed Shot Rang 2 und höher), steht beim Eintrag die
ID des Talent-Zaubers als "Tor": der Lehrer bietet diese Ränge erst an, wenn das Talent gelernt ist.
"""
import csv, collections, io, json, os, sys, urllib.request

UA = {"User-Agent": "Mozilla/5.0 (X11; Linux x86_64) Chrome/126 Safari/537.36"}
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "Kindergarten", "AbilityData.lua")
MASKS = {1: "WARRIOR", 2: "PALADIN", 4: "HUNTER", 8: "ROGUE", 16: "PRIEST", 64: "SHAMAN", 128: "MAGE", 256: "WARLOCK", 1024: "DRUID"}
BAD = {"Engraving", "Runes", "Beast Training"}

def get(url):
    return urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=180).read().decode("utf-8")

build = sys.argv[1] if len(sys.argv) > 1 else json.loads(get("https://wago.tools/api/builds"))["wowf"][0]["version"]
def table(name):
    return list(csv.DictReader(io.StringIO(get(f"https://wago.tools/db2/{name}/csv?build={build}"))))

sl = {r["ID"]: r for r in table("SkillLine")}
sla = table("SkillLineAbility")
names = {r["ID"]: r["Name_lang"] for r in table("SpellName")}
lv = collections.defaultdict(int)
for r in table("SpellLevels"):
    if r["DifficultyID"] == "0":
        lv[r["SpellID"]] = max(lv[r["SpellID"]], int(r["BaseLevel"]), int(r["SpellLevel"]))
tal = {t[f"SpellRank_{i}"] for t in table("Talent") for i in range(9)}
mount = {r["SpellID"] for r in table("SpellEffect") if r["EffectAura"] == "78"}

lineMask = collections.defaultdict(collections.Counter)
for r in sla:
    m = int(r["ClassMask"])
    if m in MASKS:
        lineMask[r["SkillLine"]][m] += 1
lineClass = {k: c.most_common(1)[0][0] for k, c in lineMask.items()}

def q(s):
    return '"' + s.replace("\\", "\\\\").replace('"', '\\"') + '"'

out = [f"-- Erzeugt von tools/gen_abilities.py aus WoW Forever, Build {build}. Nicht von Hand ändern.",
       "-- Eintrag: { englischer Name, Talent (1) oder nicht (0), { Lernstufe, Zauber-ID, ... } je Rang }",
       "local _, KG = ...", "", f'KG.ABILITY_BUILD = "{build}"', "KG.ABILITIES = {"]
total = 0
for mask, cls in MASKS.items():
    cand, gate = collections.defaultdict(dict), {}
    for r in sla:
        s = sl.get(r["SkillLine"])
        if not s or s["CategoryID"] != "7" or s["DisplayName_lang"] in BAD or s["DisplayName_lang"].startswith("Pet"):
            continue
        m = int(r["ClassMask"])
        if not ((m & mask) or (m == 0 and lineClass.get(r["SkillLine"]) == mask)):
            continue
        if r["AcquireMethod"] == "3":
            continue
        sp = int(r["Spell"])
        if 390000 <= sp < 1000000:
            continue
        n, l = names.get(r["Spell"]), lv.get(r["Spell"], 0)
        if not n or l <= 0 or (l <= 1 and r["Spell"] in mount):
            continue
        if r["Spell"] in tal:
            if n not in gate or sp < gate[n]:
                gate[n] = sp
            continue
        cand[n].setdefault(l, sp)
    rows = sorted(((min(d), n, sorted(d.items())) for n, d in cand.items()), key=lambda x: (x[0], x[1]))
    out.append(f"    {cls} = {{")
    for _, n, ranks in rows:
        flat = ", ".join(f"{l}, {sp}" for l, sp in ranks)
        out.append(f"        {{ {q(n)}, {gate.get(n, 0)}, {{ {flat} }} }},")
        total += 1
    out.append("    },")
out.append("}")
open(OUT, "w", encoding="utf-8").write("\n".join(out) + "\n")
print(f"Build {build}: {total} Fähigkeiten nach {os.path.normpath(OUT)}")
