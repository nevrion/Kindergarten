local _, KG = ...

local VERSION = "KG1"
KG.MAX_POINTS = 51
KG.FIRST_TALENT_LEVEL = 10

---------------------------------------------------------------------------
-- Talentbäume: eingebaute Daten (alle Klassen) plus der eigene Baum live aus dem Spiel
---------------------------------------------------------------------------

local function SpellName(id)
    if C_Spell and C_Spell.GetSpellName then return C_Spell.GetSpellName(id) end
    if GetSpellInfo then return (GetSpellInfo(id)) end
end

local function SpellIcon(id)
    if C_Spell and C_Spell.GetSpellTexture then return C_Spell.GetSpellTexture(id) end
    if GetSpellTexture then return GetSpellTexture(id) end
end

local TAB_DE = {
    ["Arms"] = "Waffen", ["Fury"] = "Furor", ["Protection"] = "Schutz", ["Holy"] = "Heilig", ["Retribution"] = "Vergeltung",
    ["Beast Mastery"] = "Tierherrschaft", ["Marksmanship"] = "Treffsicherheit", ["Survival"] = "Überleben",
    ["Assassination"] = "Meucheln", ["Combat"] = "Kampf", ["Subtlety"] = "Täuschung", ["Discipline"] = "Disziplin",
    ["Shadow"] = "Schatten", ["Elemental"] = "Elementar", ["Enhancement"] = "Verstärkung", ["Restoration"] = "Wiederherstellung",
    ["Arcane"] = "Arkan", ["Fire"] = "Feuer", ["Frost"] = "Frost", ["Affliction"] = "Gebrechen", ["Demonology"] = "Dämonologie",
    ["Destruction"] = "Zerstörung", ["Balance"] = "Gleichgewicht", ["Feral Combat"] = "Wilder Kampf",
}

local function tabName(en)
    if GetLocale and GetLocale() == "deDE" and TAB_DE[en] then return TAB_DE[en] end
    return en
end

local staticCache = {}

-- Baum einer Klasse aus den eingebauten Daten (tier und col beginnen bei 0)
function KG.StaticTree(class)
    if staticCache[class] then return staticCache[class] end
    local data = KG.TREE_DATA and KG.TREE_DATA[class]
    if not data then return nil end
    local tree = { class = class, tabs = {} }
    for ti, td in ipairs(data) do
        local tab = { name = tabName(td.en), icon = td.icon, talents = {}, byKey = {} }
        for _, r in ipairs(td.t) do
            local tal = { tier = r[1], col = r[2], name = r[3], spells = r[4], max = #r[4], key = r[1] * 10 + r[2] }
            if r[5] then tal.pre = r[5] * 10 + r[6] end
            tab.talents[#tab.talents + 1] = tal
            tab.byKey[tal.key] = tal
        end
        tree.tabs[ti] = tab
    end
    staticCache[class] = tree
    return tree
end

function KG.TalentName(tal)
    local n = tal.spells and SpellName(tal.spells[1])
    return (n and n ~= "") and n or tal.name
end

function KG.TalentIcon(tal)
    if tal.icon then return tal.icon end
    return (tal.spells and SpellIcon(tal.spells[1])) or "Interface\\Icons\\INV_Misc_QuestionMark"
end

-- Liest die Talentbäume des eigenen Charakters über die klassische Schnittstelle
function KG.ReadTalents()
    if not (GetNumTalentTabs and GetNumTalents and GetTalentInfo and GetTalentTabInfo) then return nil end
    local tabs, count = {}, 0
    for tab = 1, math.min(GetNumTalentTabs() or 0, 5) do
        local a, b, _, d = GetTalentTabInfo(tab)
        local name, icon
        if type(a) == "number" then name, icon = b, d else name, icon = a, b end
        local t = { name = tostring(name or ("Baum " .. tab)), icon = icon, talents = {} }
        for i = 1, math.min(GetNumTalents(tab) or 0, 40) do
            local n, ic, tier, col, rank, max = GetTalentInfo(tab, i)
            t.talents[i] = { name = tostring(n or "?"), icon = ic, tier = tonumber(tier) or 1, col = tonumber(col) or 1,
                rank = tonumber(rank) or 0, max = tonumber(max) or 1 }
            count = count + 1
        end
        tabs[tab] = t
    end
    if count == 0 then return nil end
    return tabs
end

-- Verknüpft den Live-Baum mit den eingebauten Daten über die Positionen (Reihe, Spalte).
-- Liefert { tabs = Live-Bäume, map = { [Datenbaum] = { liveTab, idx = { [key] = Live-Index } } } oder nil bei Abweichung }
function KG.LiveInfo(static)
    local live = KG.ReadTalents()
    if not live then return nil end
    local minTier, minCol = 99, 99
    for _, t in ipairs(live) do
        for _, x in ipairs(t.talents) do
            minTier, minCol = math.min(minTier, x.tier), math.min(minCol, x.col)
        end
    end
    local sig = {}
    for ti, t in ipairs(live) do
        local keys, idx = {}, {}
        for i, x in ipairs(t.talents) do
            x.key = (x.tier - minTier) * 10 + (x.col - minCol)
            keys[#keys + 1] = x.key
            idx[x.key] = i
        end
        table.sort(keys)
        sig[ti] = { s = table.concat(keys, ","), idx = idx }
    end
    local info = { tabs = live, minTier = minTier, minCol = minCol }
    if not static or #static.tabs ~= #live then return info end
    local used, map = {}, {}
    for si, st in ipairs(static.tabs) do
        local keys = {}
        for _, x in ipairs(st.talents) do keys[#keys + 1] = x.key end
        table.sort(keys)
        local s, found = table.concat(keys, ","), nil
        for li = 1, #live do
            if not used[li] and sig[li].s == s then found = li break end
        end
        if not found then return info end
        used[found] = true
        map[si] = { liveTab = found, idx = sig[found].idx }
    end
    info.map = map
    return info
end

-- Baum aus dem Live-Lesen, falls die eingebauten Daten nicht zum Spiel passen (ohne Voraussetzungen)
local function treeFromLive(class, info)
    local tree = { class = class, tabs = {}, fromLive = true }
    for ti, t in ipairs(info.tabs) do
        local tab = { name = t.name, icon = t.icon, talents = {}, byKey = {} }
        for i, x in ipairs(t.talents) do
            local tal = { tier = x.tier - info.minTier, col = x.col - info.minCol, name = x.name, icon = x.icon, max = x.max,
                key = x.key, liveTab = ti, liveIdx = i }
            tab.talents[#tab.talents + 1] = tal
            tab.byKey[tal.key] = tal
        end
        tree.tabs[ti] = tab
    end
    return tree
end

-- Liefert den Baum einer Klasse, die Live-Verknüpfung (nur für die eigene Klasse) und ob die Daten abweichen
function KG.TreeFor(class)
    local static = KG.StaticTree(class)
    if class ~= KG.MyClass() then return static, nil, false end
    local info = KG.LiveInfo(static)
    if not info then return static, nil, false end
    if static and info.map then return static, info, false end
    return treeFromLive(class, info), info, true
end

-- Gelernter Rang eines Talents (Baum-Nummer und key aus dem Plan)
function KG.RankFn(tree, info)
    if not info then return nil end
    return function(tab, key)
        local lt, li
        if tree.fromLive then
            local tal = tree.tabs[tab] and tree.tabs[tab].byKey[key]
            lt, li = tal and tal.liveTab, tal and tal.liveIdx
        else
            local m = info.map and info.map[tab]
            lt, li = m and m.liveTab, m and m.idx[key]
        end
        if not (lt and li and GetTalentInfo) then return 0 end
        return tonumber((select(5, GetTalentInfo(lt, li)))) or 0
    end
end

function KG.LiveRef(tree, info, tab, key)
    if not info then return nil end
    if tree.fromLive then
        local tal = tree.tabs[tab] and tree.tabs[tab].byKey[key]
        return tal and tal.liveTab, tal and tal.liveIdx
    end
    local m = info.map and info.map[tab]
    return m and m.liveTab, m and m.idx[key]
end

function KG.UnspentPoints()
    if UnitCharacterPoints then
        local p = UnitCharacterPoints("player")
        if type(p) == "number" then return p end
    end
    if GetUnspentTalentPoints then return tonumber(GetUnspentTalentPoints()) or 0 end
    return 0
end

---------------------------------------------------------------------------
-- Skillung: geordnete Liste von Punkten, jeder Punkt = Baum + Position (3 Zeichen)
---------------------------------------------------------------------------

function KG.ParsePicks(str)
    local out = {}
    str = str or ""
    for i = 1, #str - 2, 3 do
        local tab, tier, col = tonumber(str:sub(i, i)), tonumber(str:sub(i + 1, i + 1)), tonumber(str:sub(i + 2, i + 2))
        if tab and tier and col and tab >= 1 and tab <= 5 then out[#out + 1] = { tab = tab, key = tier * 10 + col } end
    end
    return out
end

function KG.PicksToString(picks)
    local out = {}
    for i, p in ipairs(picks) do out[i] = ("%d%d%d"):format(p.tab, math.floor(p.key / 10), p.key % 10) end
    return table.concat(out)
end

local function newState() return { spent = {}, rank = {}, total = 0 } end

local function whyNot(tree, st, tab, key)
    local tb = tree.tabs[tab]
    local tal = tb and tb.byKey[key]
    if not tal then return "Dieses Talent gibt es hier nicht." end
    if (st.rank[tab * 100 + key] or 0) >= tal.max then return "Dieses Talent ist schon voll." end
    if st.total >= KG.MAX_POINTS then return "Mehr als " .. KG.MAX_POINTS .. " Punkte gibt es nicht." end
    local need = tal.tier * 5
    if (st.spent[tab] or 0) < need then
        return ("Dafür brauchst du %d Punkte in %s (im Plan: %d)."):format(need, tb.name, st.spent[tab] or 0)
    end
    if tal.pre then
        local pre = tb.byKey[tal.pre]
        if pre and (st.rank[tab * 100 + tal.pre] or 0) < pre.max then
            return ("Zuerst muss %s voll sein."):format(KG.TalentName(pre))
        end
    end
    return nil
end

local function apply(st, tab, key)
    st.spent[tab] = (st.spent[tab] or 0) + 1
    st.rank[tab * 100 + key] = (st.rank[tab * 100 + key] or 0) + 1
    st.total = st.total + 1
end

-- Warum geht dieser Punkt als Nächstes nicht? (nil = erlaubt)
function KG.WhyNot(tree, picks, tab, key)
    local st = newState()
    for _, p in ipairs(picks) do apply(st, p.tab, p.key) end
    return whyNot(tree, st, tab, key)
end

-- Wirft Punkte raus, die in dieser Reihenfolge nicht erlaubt wären. Liefert Liste und Anzahl der entfernten Punkte.
function KG.Normalize(tree, picks)
    local st, out, dropped = newState(), {}, 0
    for _, p in ipairs(picks) do
        if not whyNot(tree, st, p.tab, p.key) then
            apply(st, p.tab, p.key)
            out[#out + 1] = p
        else
            dropped = dropped + 1
        end
    end
    return out, dropped
end

-- Entfernt den letzten Punkt dieses Talents und prüft den Rest
function KG.RemovePick(tree, picks, tab, key)
    for n = #picks, 1, -1 do
        if picks[n].tab == tab and picks[n].key == key then
            table.remove(picks, n)
            return KG.Normalize(tree, picks)
        end
    end
    return picks, 0
end

-- planned[tab*100+key] = geplanter Rang; nextPick = erster Punkt, der noch nicht gelernt ist
function KG.BuildProgress(picks, rankFn)
    local planned, nextPick, done = {}, nil, 0
    for n, p in ipairs(picks) do
        local pk = p.tab * 100 + p.key
        planned[pk] = (planned[pk] or 0) + 1
        if rankFn and not nextPick then
            if (rankFn(p.tab, p.key) or 0) >= planned[pk] then done = done + 1
            else nextPick = { tab = p.tab, key = p.key, n = n } end
        end
    end
    return planned, nextPick, done
end

function KG.PointLevel(n)
    return KG.FIRST_TALENT_LEVEL - 1 + n
end

function KG.SetBuild(class, picks, author)
    KG.db.builds[class] = { picks = KG.PicksToString(picks), author = author or KG.MyName(), time = date and date("%d.%m. %H:%M") or "" }
end

function KG.EncodeBuild(class)
    local b = KG.db.builds[class]
    if not b or b.picks == "" then return nil end
    return table.concat({ VERSION, "B", class, (tostring(b.author or "?"):gsub("[|,]", "")), b.picks }, "|")
end

function KG.DecodeBuild(text)
    local ver, kind, class, author, picks = strsplit("|", strtrim(text or ""))
    if ver ~= VERSION or kind ~= "B" then return nil, "Das ist kein Skillungs-Code." end
    if not KG.CLASSES[class or ""] then return nil, "Der Code enthält keine gültige Klasse." end
    picks = picks or ""
    if #picks > 200 or #picks % 3 ~= 0 or picks:find("%D") then return nil, "Der Skillungs-Code ist beschädigt." end
    local list = KG.ParsePicks(picks)
    if #list == 0 then return nil, "Die Skillung ist leer." end
    return class, { picks = KG.PicksToString(list), author = (author or "?"):sub(1, 40), time = date and date("%d.%m. %H:%M") or "" }
end

---------------------------------------------------------------------------
-- Übertragung: Skillung als eine Nachricht (Gruppe oder Flüstern)
---------------------------------------------------------------------------

function KG.SendBuild(class)
    local msg = KG.EncodeBuild(class)
    if not msg then KG.Print("Es ist noch keine Skillung geplant.") return false end
    local ch = KG.GroupChannel()
    if not ch then KG.Print("Ihr seid nicht in einer Gruppe. Nutze den Code, um die Skillung zu schicken.") return false end
    KG.RawSend(msg, ch)
    KG.Print("Skillung an die Gruppe geschickt.")
    return true
end

function KG.RequestBuild()
    local ch = KG.GroupChannel()
    if not ch then KG.Print("Ihr seid nicht in einer Gruppe. Ladet euch zuerst gegenseitig ein.") return false end
    KG.RawSend(VERSION .. "|BQ|" .. KG.MyClass(), ch)
    KG.Print("Skillung angefragt.")
    return true
end

function KG.OnTalentMessage(kind, text, channel, sender, short)
    if kind == "BQ" then
        local class = select(3, strsplit("|", text))
        if KG.db.role == "parent" and class and KG.db.builds[class] then
            local msg = KG.EncodeBuild(class)
            if not msg then return end
            if channel == "WHISPER" then KG.RawSend(msg, "WHISPER", sender)
            else
                local ch = KG.GroupChannel()
                if ch then KG.RawSend(msg, ch) end
            end
        end
    elseif kind == "B" then
        if KG.db.role == "parent" then return end
        local class, build = KG.DecodeBuild(text)
        if not class then return end
        build.author = short ~= "" and short or build.author
        local old = KG.db.builds[class]
        KG.db.builds[class] = build
        if not old or old.picks ~= build.picks then
            KG.Print(("Skillung für %s von %s erhalten (%d Punkte)."):format(KG.ClassName(class), build.author, #build.picks / 3))
        end
        if KG.RefreshUI then KG.RefreshUI() end
        KG.TalentPointsChanged(true)
    end
end

---------------------------------------------------------------------------
-- Erinnerung beim Kind: freier Talentpunkt und nächster Schritt laut Plan
---------------------------------------------------------------------------

local lastNote

-- Name, Baumname und nächster Punkt laut Plan (oder nil)
function KG.NextStepText()
    local class = KG.MyClass()
    local build = KG.db.builds[class]
    if not build then return nil end
    local tree, info = KG.TreeFor(class)
    if not tree or not info then return nil end
    local _, nextPick = KG.BuildProgress(KG.ParsePicks(build.picks), KG.RankFn(tree, info))
    if not nextPick then return nil end
    local tab = tree.tabs[nextPick.tab]
    local tal = tab and tab.byKey[nextPick.key]
    if not tal then return nil end
    return KG.TalentName(tal), tab.name, nextPick
end

function KG.TalentPointsChanged(force)
    if not KG.db or KG.db.role ~= "kid" then return end
    local free = KG.UnspentPoints()
    local name, tabName = KG.NextStepText()
    if free <= 0 or not name then lastNote = nil return end
    local note = free .. name
    if note == lastNote and not force then return end
    lastNote = note
    local msg = ("Du hast %d freie%s Talentpunkt%s. Nächster Punkt laut Plan: %s (Baum %s)."):format(free, free == 1 and "n" or "", free == 1 and "" or "e", name, tabName)
    KG.Print(msg .. " Öffne den Kindergarten mit /kg.")
    if KG.ShowToast then KG.ShowToast(msg) end
    if KG.RefreshUI then KG.RefreshUI() end
end

---------------------------------------------------------------------------
-- Diagnose: /kg talente schreibt alles Lesbare in die Addon-Datei
---------------------------------------------------------------------------

function KG.TalentDump()
    local d = { time = date and date("%Y-%m-%d %H:%M") or "", class = KG.MyClass(), build = KG.TREE_BUILD, api = {} }
    for _, n in ipairs({ "GetNumTalentTabs", "GetTalentTabInfo", "GetNumTalents", "GetTalentInfo", "LearnTalent", "UnitCharacterPoints",
        "GetUnspentTalentPoints", "GetTalentPrereqs", "GetActiveTalentGroup", "GetSpecialization", "GetNumSpecializations" }) do
        d.api[n] = _G[n] ~= nil
    end
    for _, n in ipairs({ "C_ClassTalents", "C_Traits", "C_SpecializationInfo", "C_Talent" }) do d.api[n] = _G[n] ~= nil end
    d.classic = KG.ReadTalents()
    d.unspent = KG.UnspentPoints()
    local static = KG.StaticTree(KG.MyClass())
    local info = KG.LiveInfo(static)
    d.matchesData = info and info.map ~= nil or false
    d.minTierCol = info and { info.minTier, info.minCol } or nil
    KG.db.talentDump = d
    if not d.classic then
        KG.Print("Die Talentbäume konnten im Spiel nicht gelesen werden. Die eingebauten Daten gibt es trotzdem, das Planen geht.")
    elseif d.matchesData then
        KG.Print("Dein Talentbaum passt zu den eingebauten Daten (Build " .. tostring(KG.TREE_BUILD) .. ").")
    else
        KG.Print("Dein Talentbaum weicht von den eingebauten Daten ab. Bitte die Datei schicken, damit sie aktualisiert werden.")
    end
    KG.Print("Datei: WTF/Account/<Kontoname>/SavedVariables/Kindergarten.lua")
end
