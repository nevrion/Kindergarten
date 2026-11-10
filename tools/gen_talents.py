#!/usr/bin/env python3
"""Erzeugt Kindergarten/TalentData.lua aus den DB2-Tabellen von WoW Forever (Produkt wowf bei wago.tools).

Aufruf:  python3 tools/gen_talents.py [Build]      (ohne Build: neuester wowf-Build)
Tabellen: Talent, TalentTab, SpellName. Die Namen im Spiel kommen später aus der Zauber-ID in der Client-Sprache,
die englischen Namen hier sind nur Rückfall.
"""
import csv, collections, io, json, os, sys, urllib.request

UA = {"User-Agent": "Mozilla/5.0 (X11; Linux x86_64) Chrome/126 Safari/537.36"}
OUT = os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "Kindergarten", "TalentData.lua")
MASKS = {1: "WARRIOR", 2: "PALADIN", 4: "HUNTER", 8: "ROGUE", 16: "PRIEST", 64: "SHAMAN", 128: "MAGE", 256: "WARLOCK", 1024: "DRUID"}

def get(url):
    return urllib.request.urlopen(urllib.request.Request(url, headers=UA), timeout=120).read().decode("utf-8")

def table(name, build):
    return list(csv.DictReader(io.StringIO(get(f"https://wago.tools/db2/{name}/csv?build={build}"))))

build = sys.argv[1] if len(sys.argv) > 1 else json.loads(get("https://wago.tools/api/builds"))["wowf"][0]["version"]
tabs, tal = table("TalentTab", build), table("Talent", build)
names = {r["ID"]: r["Name_lang"] for r in table("SpellName", build)}
byid = {t["ID"]: t for t in tal}
bytab = collections.defaultdict(list)
for t in tal:
    bytab[t["TabID"]].append(t)

def q(s):
    return '"' + s.replace("\\", "\\\\").replace('"', '\\"') + '"'

out = [f"-- Erzeugt von tools/gen_talents.py aus WoW Forever, Build {build}. Nicht von Hand ändern.",
       "local _, KG = ...", "", f'KG.TREE_BUILD = "{build}"', "KG.TREE_DATA = {"]
total = 0
for mask, cls in MASKS.items():
    ctabs = sorted([t for t in tabs if int(t["ClassMask"]) == mask], key=lambda t: int(t["OrderIndex"]))
    if not ctabs:
        continue
    out.append(f"    {cls} = {{")
    for tab in ctabs:
        out.append(f'        {{ en = {q(tab["Name_lang"])}, icon = {tab["SpellIconID"]}, t = {{')
        rows = sorted(bytab[tab["ID"]], key=lambda t: (int(t["TierID"]), int(t["ColumnIndex"])))
        for t in rows:
            ids = [int(t[f"SpellRank_{i}"]) for i in range(9) if int(t[f"SpellRank_{i}"])]
            name = next((names[str(i)] for i in ids if str(i) in names), "Talent")
            pre = ""
            if t["PrereqTalent_0"] != "0":
                p = byid[t["PrereqTalent_0"]]
                pre = f", {p['TierID']}, {p['ColumnIndex']}"
            out.append(f'            {{ {t["TierID"]}, {t["ColumnIndex"]}, {q(name)}, {{ {", ".join(map(str, ids))} }}{pre} }},')
            total += 1
        out.append("        } },")
    out.append("    },")
out.append("}")
open(OUT, "w", encoding="utf-8").write("\n".join(out) + "\n")
print(f"Build {build}: {total} Talente nach {os.path.normpath(OUT)}")
