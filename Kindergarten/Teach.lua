local _, KG = ...

local VERSION = "KG1"

---------------------------------------------------------------------------
-- Fähigkeiten einer Klasse (aus den eingebauten Daten)
---------------------------------------------------------------------------

local function SpellName(id)
    if C_Spell and C_Spell.GetSpellName then return C_Spell.GetSpellName(id) end
    if GetSpellInfo then return (GetSpellInfo(id)) end
end

local function SpellIcon(id)
    if C_Spell and C_Spell.GetSpellTexture then return C_Spell.GetSpellTexture(id) end
    if GetSpellTexture then return GetSpellTexture(id) end
end

local function known(id)
    if IsPlayerSpell and IsPlayerSpell(id) then return true end
    if IsSpellKnown and IsSpellKnown(id) then return true end
    return false
end

local cache = {}

-- Liste { idx, key, en, gate, first, ranks = { { level, id }, ... } }, sortiert nach erster Lernstufe
function KG.Abilities(class)
    if cache[class] then return cache[class] end
    local data = KG.ABILITIES and KG.ABILITIES[class]
    if not data then return nil end
    local list = {}
    for i, e in ipairs(data) do
        local a = { idx = i, en = e[1], gate = e[2], ranks = {} }
        for j = 1, #e[3], 2 do a.ranks[#a.ranks + 1] = { level = e[3][j], id = e[3][j + 1] } end
        a.first = a.ranks[1].level
        a.key = tostring(a.ranks[1].id)
        list[i] = a
    end
    cache[class] = list
    return list
end

function KG.AbilityName(a)
    local n = SpellName(a.ranks[1].id)
    return (n and n ~= "") and n or a.en
end

function KG.AbilityIcon(a)
    return SpellIcon(a.ranks[1].id) or "Interface\\Icons\\INV_Misc_QuestionMark"
end

---------------------------------------------------------------------------
-- Markierungen der Eltern: 0 = normal, 1 = wichtig, 2 = auslassen
---------------------------------------------------------------------------

function KG.TeachMark(class, a)
    local t = KG.db.teach[class]
    return t and t[a.key] or 0
end

function KG.SetTeachMark(class, a, v)
    local t = KG.db.teach[class]
    if not t then t = {}; KG.db.teach[class] = t end
    t[a.key] = (v ~= 0) and v or nil
    if not next(t) then KG.db.teach[class] = nil end
end

function KG.HasTeach(class)
    return KG.db.teach[class] ~= nil
end

function KG.EncodeTeach(class)
    local list = KG.Abilities(class)
    if not list or not KG.HasTeach(class) then return nil end
    local chars = {}
    for i, a in ipairs(list) do chars[i] = tostring(KG.TeachMark(class, a)) end
    return table.concat({ VERSION, "L", class, (KG.MyName():gsub("[|,]", "")), tostring(KG.ABILITY_BUILD), table.concat(chars) }, "|")
end

-- Liefert Klasse, Markierungen (key -> 1 oder 2), Autor oder nil und eine Fehlermeldung
function KG.DecodeTeach(text)
    local ver, kind, class, author, build, chars = strsplit("|", strtrim(text or ""))
    if ver ~= VERSION or kind ~= "L" then return nil, "Das ist kein Lehrer-Code." end
    local list = KG.CLASSES[class or ""] and KG.Abilities(class)
    if not list then return nil, "Der Code enthält keine gültige Klasse." end
    if build ~= tostring(KG.ABILITY_BUILD) then
        return nil, "Euer Addon hat einen anderen Datenstand (Build " .. tostring(build) .. " gegen " .. tostring(KG.ABILITY_BUILD) .. "). Bitte beide aktualisieren."
    end
    chars = chars or ""
    if #chars ~= #list or chars:find("[^012]") then return nil, "Der Lehrer-Code ist beschädigt." end
    local marks = {}
    for i, a in ipairs(list) do
        local v = tonumber(chars:sub(i, i))
        if v > 0 then marks[a.key] = v end
    end
    return class, marks, (author or "?"):sub(1, 40)
end

function KG.SendTeach(class)
    local msg = KG.EncodeTeach(class)
    if not msg then KG.Print("Es ist noch nichts markiert.") return false end
    local ch = KG.GroupChannel()
    if not ch then KG.Print("Ihr seid nicht in einer Gruppe. Nutze den Code, um die Empfehlung zu schicken.") return false end
    KG.RawSend(msg, ch)
    KG.Print("Lehrer-Empfehlung an die Gruppe geschickt.")
    return true
end

function KG.RequestTeach()
    local ch = KG.GroupChannel()
    if not ch then KG.Print("Ihr seid nicht in einer Gruppe. Ladet euch zuerst gegenseitig ein.") return false end
    KG.RawSend(VERSION .. "|LQ|" .. KG.MyClass(), ch)
    KG.Print("Lehrer-Empfehlung angefragt.")
    return true
end

function KG.OnTeachMessage(kind, text, channel, sender, short)
    if kind == "LQ" then
        local class = select(3, strsplit("|", text))
        if KG.db.role == "parent" and class and KG.HasTeach(class) then
            local msg = KG.EncodeTeach(class)
            if not msg then return end
            if channel == "WHISPER" then KG.RawSend(msg, "WHISPER", sender)
            else
                local ch = KG.GroupChannel()
                if ch then KG.RawSend(msg, ch) end
            end
        end
    elseif kind == "L" then
        if KG.db.role == "parent" then return end
        local class, marks = KG.DecodeTeach(text)
        if not class then return end
        KG.db.teach[class] = next(marks) and marks or nil
        KG.Print(("Lehrer-Empfehlung für %s von %s erhalten."):format(KG.ClassName(class), short ~= "" and short or "deiner Begleitung"))
        if KG.RefreshUI then KG.RefreshUI() end
        KG.TeachReminder(true)
    end
end

---------------------------------------------------------------------------
-- Beim Kind: welche Fähigkeiten sind auf diesem Level fällig?
---------------------------------------------------------------------------

-- "learned", "ready" (Level erreicht, noch nicht gelernt), "later" (Level noch nicht erreicht) oder "gated" (Talent fehlt)
function KG.TeachStatus(a, level)
    local target
    for i, r in ipairs(a.ranks) do
        if r.level <= level then target = i end
    end
    if not target then return "later", nil end
    if a.gate ~= 0 and not known(a.gate) then return "gated", target end
    if known(a.ranks[target].id) then return "learned", target end
    return "ready", target
end

local lastTeach

local function rankText(a, rank)
    return #a.ranks > 1 and (" (Rang " .. rank .. ")") or ""
end

function KG.TeachReminder(force)
    if not KG.db or KG.db.role ~= "kid" then return end
    local class = KG.MyClass()
    local list = KG.Abilities(class)
    if not list or not KG.HasTeach(class) then return end
    local level = UnitLevel and UnitLevel("player") or 1
    local names = {}
    for _, a in ipairs(list) do
        if KG.TeachMark(class, a) == 1 then
            local st, rank = KG.TeachStatus(a, level)
            if st == "ready" then names[#names + 1] = KG.AbilityName(a) .. rankText(a, rank) end
        end
    end
    if #names == 0 then lastTeach = nil return end
    local note = table.concat(names, ", ")
    if note == lastTeach and not force then return end
    lastTeach = note
    local msg = "Beim Klassenlehrer abholen: " .. note .. "."
    KG.Print(msg)
    if KG.ShowToast then KG.ShowToast(msg, "teacher") end
end

---------------------------------------------------------------------------
-- Lehrerfenster: Empfehlung neben dem Angebot anzeigen
---------------------------------------------------------------------------

-- Liefert Liste { name, rank (Zahl oder nil), type } der Angebote im geöffneten Lehrerfenster
local function trainerServices()
    local out = {}
    if GetNumTrainerServices and GetTrainerServiceInfo then
        for i = 1, GetNumTrainerServices() or 0 do
            local name, sub, typ = GetTrainerServiceInfo(i)
            if name then out[#out + 1] = { name = name, rank = tonumber(tostring(sub or ""):match("(%d+)")), type = typ } end
        end
    elseif C_Trainer and C_Trainer.GetNumTrainerServices and C_Trainer.GetTrainerServiceInfo then
        for i = 1, C_Trainer.GetNumTrainerServices() or 0 do
            local info = C_Trainer.GetTrainerServiceInfo(i)
            if type(info) == "table" and info.name then
                out[#out + 1] = { name = info.name, rank = tonumber(tostring(info.subText or info.rank or ""):match("(%d+)")), type = info.serviceType or info.type }
            end
        end
    end
    return out
end

function KG.UpdateTrainerPanel()
    if not KG.db or not KG.ShowTrainerPanel then return end
    local class = KG.MyClass()
    local list = KG.Abilities(class)
    if not list then return end
    local byName = {}
    for _, a in ipairs(list) do
        byName[strlower(KG.AbilityName(a))] = a
        byName[strlower(a.en)] = byName[strlower(a.en)] or a
    end
    local key, skip, other, total = {}, {}, 0, 0
    local ok, services = pcall(trainerServices)
    if not ok then return end
    for _, s in ipairs(services) do
        if s.type == nil or s.type == "available" then
            total = total + 1
            local a = byName[strlower(s.name)]
            local mark = a and KG.TeachMark(class, a) or 0
            local label = s.name .. ((s.rank and (a and #a.ranks > 1 or not a)) and (" (Rang " .. s.rank .. ")") or "")
            if mark == 1 then key[#key + 1] = label
            elseif mark == 2 then skip[#skip + 1] = label
            else other = other + 1 end
        end
    end
    if total == 0 then KG.HideTrainerPanel() return end
    if not KG.HasTeach(class) then
        KG.ShowTrainerPanel({}, {}, other, KG.db.role == "kid" and "Noch keine Empfehlung deiner Begleitung. Frage sie im Kindergarten unter \"Beim Lehrer\" an." or nil)
        return
    end
    KG.ShowTrainerPanel(key, skip, other)
end
