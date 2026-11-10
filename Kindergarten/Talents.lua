local _, KG = ...

local VERSION = "KG1"
local ALPHA = "0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ"
local CHUNK = 190

---------------------------------------------------------------------------
-- Talentbäume lesen (klassische Schnittstelle: Bäume, Reihen, Spalten)
---------------------------------------------------------------------------

-- Liefert { class, tabs = { { name, icon, talents = { { name, icon, tier, col, max } } } } } oder nil
function KG.ReadTalents()
    if not (GetNumTalentTabs and GetNumTalents and GetTalentInfo and GetTalentTabInfo) then return nil end
    local tree = { class = KG.MyClass(), tabs = {} }
    local count = 0
    for tab = 1, math.min(GetNumTalentTabs() or 0, 5) do
        local a, b, _, d = GetTalentTabInfo(tab)
        local name, icon
        if type(a) == "number" then name, icon = b, d else name, icon = a, b end
        local t = { name = tostring(name or ("Baum " .. tab)), icon = icon, talents = {} }
        for i = 1, math.min(GetNumTalents(tab) or 0, #ALPHA - 1) do
            local n, ic, tier, col, _, max = GetTalentInfo(tab, i)
            t.talents[i] = { name = tostring(n or "?"), icon = ic, tier = tonumber(tier) or 1, col = tonumber(col) or 1, max = tonumber(max) or 1 }
            count = count + 1
        end
        tree.tabs[tab] = t
    end
    if count == 0 then return nil end
    return tree
end

function KG.TalentRank(tab, idx)
    if not GetTalentInfo then return 0 end
    local _, _, _, _, rank = GetTalentInfo(tab, idx)
    return tonumber(rank) or 0
end

function KG.UnspentPoints()
    if UnitCharacterPoints then
        local p = UnitCharacterPoints("player")
        if type(p) == "number" then return p end
    end
    if GetUnspentTalentPoints then return tonumber(GetUnspentTalentPoints()) or 0 end
    return 0
end

-- Baum einer Klasse: der eigene live aus dem Spiel, sonst ein vom Partner empfangener
function KG.TreeFor(class)
    if class == KG.MyClass() then
        local t = KG.ReadTalents()
        if t then
            KG.db.trees[class] = t
            return t, true
        end
    end
    return KG.db.trees[class], false
end

---------------------------------------------------------------------------
-- Skillung: geordnete Liste von Punkten (Baum, Talent)
---------------------------------------------------------------------------

function KG.ParsePicks(str)
    local out = {}
    for i = 1, #(str or "") - 1, 2 do
        local tab = tonumber(str:sub(i, i))
        local idx = ALPHA:find(str:sub(i + 1, i + 1), 1, true)
        if tab and idx and idx > 1 then out[#out + 1] = { tab = tab, idx = idx - 1 } end
    end
    return out
end

function KG.PicksToString(picks)
    local out = {}
    for i, p in ipairs(picks) do out[i] = p.tab .. ALPHA:sub(p.idx + 1, p.idx + 1) end
    return table.concat(out)
end

-- planned[tab*100+idx] = geplanter Rang; nextPick = erster Punkt, der noch nicht gelernt ist
function KG.BuildProgress(picks, getRank)
    local planned, nextPick, done = {}, nil, 0
    for n, p in ipairs(picks) do
        local key = p.tab * 100 + p.idx
        planned[key] = (planned[key] or 0) + 1
        if getRank and not nextPick then
            if (getRank(p.tab, p.idx) or 0) >= planned[key] then done = done + 1
            else nextPick = { tab = p.tab, idx = p.idx, n = n } end
        end
    end
    return planned, nextPick, done
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
    if #picks > 400 or #picks % 2 ~= 0 or picks:find("[^%w]") then return nil, "Der Skillungs-Code ist beschädigt." end
    local list = KG.ParsePicks(picks)
    if #list == 0 then return nil, "Die Skillung ist leer." end
    return class, { picks = KG.PicksToString(list), author = (author or "?"):sub(1, 40), time = date and date("%d.%m. %H:%M") or "" }
end

---------------------------------------------------------------------------
-- Übertragung: Skillung (eine Nachricht) und Talentbaum (mehrere Teile)
---------------------------------------------------------------------------

local function clean(s)
    return (tostring(s or ""):gsub("[|;:,~]", " "))
end

local function treeToString(tree)
    local tabs = {}
    for i, t in ipairs(tree.tabs) do
        local tl = {}
        for j, x in ipairs(t.talents) do
            tl[j] = table.concat({ x.tier, x.col, x.max, type(x.icon) == "number" and x.icon or 0, clean(x.name) }, "~")
        end
        tabs[i] = clean(t.name) .. ":" .. (type(t.icon) == "number" and t.icon or 0) .. ":" .. table.concat(tl, ",")
    end
    return table.concat(tabs, ";")
end

local function treeFromString(class, s)
    local tree = { class = class, tabs = {} }
    for tabStr in s:gmatch("[^;]+") do
        local name, icon, list = tabStr:match("^([^:]*):([^:]*):(.*)$")
        if not name or #tree.tabs >= 5 then return nil end
        local t = { name = name, icon = tonumber(icon) ~= 0 and tonumber(icon) or nil, talents = {} }
        for item in list:gmatch("[^,]+") do
            local tier, col, max, ic, n = item:match("^(%d+)~(%d+)~(%d+)~(%d+)~(.*)$")
            if not tier or #t.talents >= #ALPHA - 1 then return nil end
            t.talents[#t.talents + 1] = { name = n, icon = tonumber(ic) ~= 0 and tonumber(ic) or nil,
                tier = math.max(1, math.min(15, tonumber(tier))), col = math.max(1, math.min(6, tonumber(col))), max = math.max(1, math.min(9, tonumber(max))) }
        end
        tree.tabs[#tree.tabs + 1] = t
    end
    if #tree.tabs == 0 then return nil end
    return tree
end

local function later(i, fn)
    if C_Timer and C_Timer.After and i > 0 then C_Timer.After(i * 0.35, fn) else fn() end
end

local function sendTo(msg, channel, target)
    if channel == "WHISPER" then KG.RawSend(msg, "WHISPER", target)
    else
        local ch = KG.GroupChannel()
        if ch then KG.RawSend(msg, ch) end
    end
end

function KG.SendTree(channel, target)
    local tree = KG.ReadTalents()
    if not tree then return false end
    local s = treeToString(tree)
    local total = math.ceil(#s / CHUNK)
    for i = 1, total do
        local part = s:sub((i - 1) * CHUNK + 1, i * CHUNK)
        later(i - 1, function() sendTo(table.concat({ VERSION, "T", tree.class, i, total, part }, "|"), channel, target) end)
    end
    return true
end

function KG.RequestTree()
    local ch = KG.GroupChannel()
    if not ch then KG.Print("Ihr seid nicht in einer Gruppe. Ladet euch zuerst gegenseitig ein.") return false end
    KG.RawSend(VERSION .. "|TQ", ch)
    KG.Print("Talentbäume angefragt. Die Antwort kommt in ein paar Sekunden.")
    return true
end

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

local buffers = {}

function KG.OnTalentMessage(kind, text, channel, sender, short)
    if kind == "TQ" then
        KG.SendTree(channel, sender)
    elseif kind == "BQ" then
        local class = select(3, strsplit("|", text))
        if KG.db.role == "parent" and class and KG.db.builds[class] then
            sendTo(KG.EncodeBuild(class) or "", channel, sender)
        end
    elseif kind == "B" then
        if KG.db.role == "parent" then return end
        local class, build = KG.DecodeBuild(text)
        if not class then return end
        build.author = short ~= "" and short or build.author
        local old = KG.db.builds[class]
        KG.db.builds[class] = build
        if not old or old.picks ~= build.picks then
            KG.Print(("Skillung für %s von %s erhalten (%d Punkte)."):format(KG.ClassName(class), build.author, #build.picks / 2))
        end
        if KG.RefreshUI then KG.RefreshUI() end
        KG.TalentPointsChanged(true)
    elseif kind == "T" then
        local _, _, class, seq, total, part = strsplit("|", text, 6)
        seq, total = tonumber(seq), tonumber(total)
        if not KG.CLASSES[class or ""] or not seq or not total or total > 40 or seq < 1 or seq > total then return end
        local key = short .. class
        local buf = buffers[key]
        if not buf or buf.total ~= total or seq == 1 then
            buf = { total = total, parts = {}, n = 0 }
            buffers[key] = buf
        end
        if not buf.parts[seq] then buf.n = buf.n + 1 end
        buf.parts[seq] = part or ""
        if buf.n == total then
            buffers[key] = nil
            local tree = treeFromString(class, table.concat(buf.parts))
            if tree and class ~= KG.MyClass() then
                KG.db.trees[class] = tree
                KG.Print(("Talentbäume für %s von %s empfangen."):format(KG.ClassName(class), short))
                if KG.RefreshUI then KG.RefreshUI() end
            end
        end
    end
end

---------------------------------------------------------------------------
-- Erinnerung beim Kind: freier Talentpunkt und nächster Schritt laut Plan
---------------------------------------------------------------------------

local lastNote

function KG.NextStepText()
    local class = KG.MyClass()
    local build = KG.db.builds[class]
    local tree = KG.TreeFor(class)
    if not build or not tree then return nil end
    local _, nextPick = KG.BuildProgress(KG.ParsePicks(build.picks), KG.TalentRank)
    if not nextPick then return nil end
    local tab = tree.tabs[nextPick.tab]
    local tal = tab and tab.talents[nextPick.idx]
    if not tal then return nil end
    return tal.name, tab.name, nextPick
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
    local d = { time = date and date("%Y-%m-%d %H:%M") or "", class = KG.MyClass(), api = {} }
    for _, n in ipairs({ "GetNumTalentTabs", "GetTalentTabInfo", "GetNumTalents", "GetTalentInfo", "LearnTalent", "UnitCharacterPoints",
        "GetUnspentTalentPoints", "GetTalentPrereqs", "GetActiveTalentGroup", "GetSpecialization", "GetNumSpecializations" }) do
        d.api[n] = _G[n] ~= nil
    end
    for _, n in ipairs({ "C_ClassTalents", "C_Traits", "C_SpecializationInfo", "C_Talent" }) do d.api[n] = _G[n] ~= nil end
    d.classic = KG.ReadTalents()
    d.unspent = KG.UnspentPoints()
    local ok, err = pcall(function()
        local cfg = C_ClassTalents and C_ClassTalents.GetActiveConfigID and C_ClassTalents.GetActiveConfigID()
        d.configID = cfg
        if not (cfg and C_Traits) then return end
        local info = C_Traits.GetConfigInfo(cfg)
        d.treeIDs = info and info.treeIDs
        d.nodes = {}
        for _, tid in ipairs(d.treeIDs or {}) do
            for i, nodeID in ipairs(C_Traits.GetTreeNodes(tid) or {}) do
                if i > 200 then break end
                local n = C_Traits.GetNodeInfo(cfg, nodeID)
                local e = n and n.entryIDs and n.entryIDs[1]
                local ei = e and C_Traits.GetEntryInfo(cfg, e)
                local def = ei and ei.definitionID and C_Traits.GetDefinitionInfo(ei.definitionID)
                local spell = def and def.spellID
                d.nodes[#d.nodes + 1] = { id = nodeID, tree = tid, x = n and n.posX, y = n and n.posY, max = n and n.maxRanks, spell = spell,
                    name = spell and ((C_Spell and C_Spell.GetSpellName and C_Spell.GetSpellName(spell)) or (GetSpellInfo and GetSpellInfo(spell))) or nil }
            end
        end
    end)
    if not ok then d.traitsError = tostring(err) end
    KG.db.talentDump = d
    if d.classic then
        local n = 0
        for _, t in ipairs(d.classic.tabs) do n = n + #t.talents end
        KG.Print(("Talente gelesen: %d Bäume, %d Talente. Gespeichert nach /reload oder beim Ausloggen."):format(#d.classic.tabs, n))
    elseif d.nodes and #d.nodes > 0 then
        KG.Print(("Talente über die neue Schnittstelle gelesen: %d Knoten. Der Planer kann diese Bäume noch nicht, bitte die Datei schicken."):format(#d.nodes))
    else
        KG.Print("Die Talentbäume konnten nicht gelesen werden. Bitte die Datei trotzdem schicken, sie enthält die Diagnose.")
    end
    KG.Print("Datei: WTF/Account/<Kontoname>/SavedVariables/Kindergarten.lua")
end
