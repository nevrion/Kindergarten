local ADDON, KG = ...
_G.Kindergarten = KG

local PREFIX = "NevKG"
local VERSION = "KG1"

function KG.Print(msg)
    print("|cffffcc5cKindergarten:|r " .. msg)
end

local function SpellName(id)
    if C_Spell and C_Spell.GetSpellName then return C_Spell.GetSpellName(id) end
    if GetSpellInfo then return (GetSpellInfo(id)) end
end

function KG.ClassName(key)
    local c = KG.CLASSES[key]
    if not c then return "?" end
    return (LOCALIZED_CLASS_NAMES_MALE and LOCALIZED_CLASS_NAMES_MALE[key]) or c.name
end

function KG.ClassColor(key)
    local rc = RAID_CLASS_COLORS and RAID_CLASS_COLORS[key]
    if rc then return rc.r, rc.g, rc.b end
    local c = KG.CLASSES[key]
    if c then return c.color[1], c.color[2], c.color[3] end
    return 1, 1, 1
end

function KG.MyClass()
    local _, classFile = UnitClass("player")
    return classFile
end

function KG.MyName()
    return (UnitName("player")) or "?"
end

---------------------------------------------------------------------------
-- Berufe des eigenen Charakters erkennen
---------------------------------------------------------------------------

local function known(id)
    if IsPlayerSpell and IsPlayerSpell(id) then return true end
    if IsSpellKnown and IsSpellKnown(id) then return true end
end

-- Liefert zwei Listen mit Berufs-Schlüsseln: Hauptberufe und Nebenberufe
function KG.DetectProfs()
    local names = {}
    if GetProfessions and GetProfessionInfo then
        for _, idx in pairs({ GetProfessions() }) do
            local n = idx and GetProfessionInfo(idx)
            if n then names[n] = true end
        end
    end
    if GetNumSkillLines and GetSkillLineInfo then
        for i = 1, GetNumSkillLines() do
            local n, header = GetSkillLineInfo(i)
            if n and not header then names[n] = true end
        end
    end
    local main, sec = {}, {}
    local function check(list, out)
        for _, key in ipairs(list) do
            local p = KG.PROFS[key]
            local found = names[p.name] or names[SpellName(p.ids[1]) or ""]
            for _, id in ipairs(p.ids) do
                if known(id) then found = true end
            end
            if found then out[#out + 1] = key end
        end
    end
    check(KG.PROF_ORDER, main)
    check(KG.SEC_ORDER, sec)
    return main, sec
end

-- Klasse, die für Empfehlungen zählt: die gewählte, sonst die des Charakters
function KG.EffectiveClass()
    return KG.db.chosenClass or KG.MyClass()
end

-- Hauptberufe, die für den Austausch zählen: gelernte, ergänzt um die gewählten
function KG.EffectiveProfs()
    local main, sec = KG.DetectProfs()
    local seen = {}
    for _, k in ipairs(main) do seen[k] = true end
    if #main < 2 and KG.db.chosenProfs then
        for _, k in ipairs(KG.db.chosenProfs) do
            if not seen[k] and #main < 2 then main[#main + 1] = k; seen[k] = true end
        end
    end
    return main, sec
end

---------------------------------------------------------------------------
-- Profil-Austausch (Addon-Nachricht, Code oder von Hand)
---------------------------------------------------------------------------

function KG.BuildProfile()
    local main, sec = KG.EffectiveProfs()
    return {
        role = KG.db.role == "parent" and "P" or "K",
        name = KG.MyName(),
        class = KG.EffectiveClass(),
        level = UnitLevel and UnitLevel("player") or 1,
        faction = UnitFactionGroup and UnitFactionGroup("player") or "",
        profs = main, sec = sec,
    }
end

function KG.Encode(t)
    return table.concat({
        VERSION, t.role or "K", (tostring(t.name or "?"):gsub("[|,]", "")), t.class or "", tostring(t.level or 1),
        (tostring(t.faction or ""):gsub("[|,]", "")), table.concat(t.profs or {}, ","), table.concat(t.sec or {}, ","),
    }, "|")
end

local function split(s, sep)
    local out, from = {}, 1
    while true do
        local i = s:find(sep, from, true)
        if not i then out[#out + 1] = s:sub(from) break end
        out[#out + 1] = s:sub(from, i - 1)
        from = i + 1
    end
    return out
end

-- Liest ein Profil; übernimmt nur bekannte Klassen und Berufe
function KG.Decode(str)
    local f = split(strtrim(str or ""), "|")
    if f[1] ~= VERSION or #f < 5 then return nil, "Das ist kein Kindergarten-Code." end
    if not KG.CLASSES[f[4] or ""] then return nil, "Der Code enthält keine gültige Klasse." end
    local t = { role = f[2] == "P" and "P" or "K", name = f[3] ~= "" and f[3]:sub(1, 40) or "?", class = f[4],
        level = math.max(1, math.min(80, tonumber(f[5]) or 1)), faction = f[6] or "", profs = {}, sec = {} }
    for _, k in ipairs(split(f[7] or "", ",")) do
        if KG.PROFS[k] and not KG.PROFS[k].secondary and #t.profs < 2 then t.profs[#t.profs + 1] = k end
    end
    for _, k in ipairs(split(f[8] or "", ",")) do
        if KG.PROFS[k] and KG.PROFS[k].secondary and #t.sec < 3 then t.sec[#t.sec + 1] = k end
    end
    return t
end

local function rawSend(msg, channel, target)
    if C_ChatInfo and C_ChatInfo.SendAddonMessage then
        C_ChatInfo.SendAddonMessage(PREFIX, msg, channel, target)
    elseif SendAddonMessage then
        SendAddonMessage(PREFIX, msg, channel, target)
    else
        return false
    end
    return true
end

KG.RawSend = rawSend

local function groupChannel()
    if IsInRaid and IsInRaid() then return "RAID" end
    if IsInGroup and IsInGroup() then return "PARTY" end
    if GetNumPartyMembers and GetNumPartyMembers() > 0 then return "PARTY" end
end

KG.GroupChannel = groupChannel

function KG.SendToGroup(silent)
    local ch = groupChannel()
    if not ch then
        if not silent then KG.Print("Ihr seid nicht in einer Gruppe. Ladet euch zuerst gegenseitig ein.") end
        return false
    end
    rawSend(KG.Encode(KG.BuildProfile()), ch)
    if not silent then KG.Print("Dein Profil wurde an die Gruppe geschickt.") end
    return true
end

function KG.SendWhisper(name)
    name = strtrim(name or "")
    if name == "" then KG.Print("Bitte einen Charakternamen eintragen.") return false end
    rawSend(KG.Encode(KG.BuildProfile()), "WHISPER", name)
    KG.Print("Dein Profil wurde an " .. name .. " geschickt.")
    return true
end

function KG.RequestFromGroup()
    local ch = groupChannel()
    if not ch then KG.Print("Ihr seid nicht in einer Gruppe. Ladet euch zuerst gegenseitig ein.") return false end
    rawSend(VERSION .. "|Q", ch)
    rawSend(KG.Encode(KG.BuildProfile()), ch)
    KG.Print("Anfrage geschickt. Hat deine Begleitung Kindergarten installiert, kommt gleich eine Antwort.")
    return true
end

function KG.SetPartner(t, source)
    t.source = source
    t.time = date and date("%d.%m. %H:%M") or ""
    KG.db.partner = t
    if KG.RefreshUI then KG.RefreshUI() end
end

local function onAddonMessage(prefix, text, channel, sender)
    if prefix ~= PREFIX or not KG.db then return end
    local short = sender and (Ambiguate and Ambiguate(sender, "short") or sender:match("^[^-]+")) or ""
    if short == KG.MyName() then return end
    local kind = text:match("^" .. VERSION .. "|(%a+)")
    if kind == "B" or kind == "BQ" then
        if KG.OnTalentMessage then KG.OnTalentMessage(kind, text, channel, sender, short) end
        return
    elseif kind == "L" or kind == "LQ" then
        if KG.OnTeachMessage then KG.OnTeachMessage(kind, text, channel, sender, short) end
        return
    end
    if text == VERSION .. "|Q" then
        if channel == "WHISPER" then rawSend(KG.Encode(KG.BuildProfile()), "WHISPER", sender)
        else KG.SendToGroup(true) end
        return
    end
    local t = KG.Decode(text)
    if not t then return end
    local old = KG.db.partner
    local changed = not old or KG.Encode(old) ~= KG.Encode(t)
    KG.SetPartner(t, "auto")
    if changed then
        KG.Print(("Profil von %s empfangen (%s, Level %d)."):format(t.name, KG.ClassName(t.class), t.level))
    end
end

---------------------------------------------------------------------------
-- Auswertung: Klassen
---------------------------------------------------------------------------

local function answerOf(q, key)
    for _, a in ipairs(q.answers) do
        if a.key == key then return a end
    end
end

-- Wie gut ergänzt Klasse c (Leser, "du") die Klasse o von name?
local function duo(c, o, name)
    local C, O = KG.CLASSES[c], KG.CLASSES[o]
    local s, good, warn = 0, {}, {}
    if c == o then
        s = s - 2
        warn[#warn + 1] = "Dieselbe Klasse wie " .. name .. ": ihr wollt dieselbe Beute und ergänzt euch kaum"
    elseif C.armor == O.armor then
        s = s - 1
        warn[#warn + 1] = "Dieselbe Rüstungsart wie " .. name .. " (" .. (KG.ARMOR_NAMES[C.armor]:match("^%S+")) .. "): ihr wollt oft dieselbe Beute"
    end
    if O.tank then
        if C.heal then s = s + 1.5; good[#good + 1] = name .. " steht vorne, du hältst euch am Leben"
        elseif C.ranged then s = s + 1; good[#good + 1] = name .. " hält die Gegner fest, du greifst aus der Ferne an" end
    elseif O.heal then
        if C.tank then s = s + 1.5; good[#good + 1] = "Du fängst die Gegner ab, " .. name .. " heilt"
        elseif C.pet then s = s + 1.5; good[#good + 1] = "Dein Begleiter fängt die Gegner ab, " .. name .. " heilt" end
    else
        if C.heal then s = s + 1.5; good[#good + 1] = name .. " macht Schaden, du hältst euch am Leben"
        elseif C.tank then s = s + 1; good[#good + 1] = "Du fängst die Gegner ab, " .. name .. " macht Schaden"
        elseif C.pet and not O.pet then s = s + 1; good[#good + 1] = "Dein Begleiter fängt die Gegner ab, ihr beide macht Schaden" end
    end
    return math.min(s, 2), good, warn
end

local function sortRows(rows)
    table.sort(rows, function(x, y)
        if x.pct ~= y.pct then return x.pct > y.pct end
        return KG.CLASSES[x.class].ease > KG.CLASSES[y.class].ease
    end)
    return rows
end

-- Einsteiger-Quiz: Antworten (key -> Antwortschlüssel) plus Begleitung
function KG.ScoreClasses(answers, partner)
    local rows = {}
    for _, cls in ipairs(KG.CLASS_ORDER) do
        local C = KG.CLASSES[cls]
        local score, max, good, warn = 0, 0, {}, {}
        for _, q in ipairs(KG.QUIZ) do
            local best = 0
            for _, a in ipairs(q.answers) do best = math.max(best, a.p[cls] or 0) end
            max = max + best
            local a = answerOf(q, answers[q.key])
            if a then
                local pts = a.p[cls] or 0
                score = score + pts
                if pts >= 2 and a.why then good[#good + 1] = "du " .. a.why end
            end
        end
        score = score + C.ease * 0.7
        max = max + 3 * 0.7
        local duoGood = {}
        if partner and KG.CLASSES[partner.class or ""] then
            local d, g, w = duo(cls, partner.class, partner.name or "deine Begleitung")
            score = score + d
            max = max + 2
            duoGood, warn = g, w
        end
        local pct = math.floor(100 * math.max(score, 0) / max + 0.5)
        rows[#rows + 1] = { class = cls, pct = math.max(3, math.min(100, pct)), good = good, duo = duoGood, warn = warn }
    end
    return sortRows(rows)
end

-- Eltern-Seite: welche Klasse passt am besten zur Klasse des Kindes?
function KG.ScoreForKid(kid)
    local rows = {}
    local name = kid.name or "dein Kind"
    for _, cls in ipairs(KG.CLASS_ORDER) do
        local C = KG.CLASSES[cls]
        local d, good, warn = duo(cls, kid.class, name)
        local score = 3 + d
        if C.heal then score = score + 1.5; good[#good + 1] = "Du kannst " .. name .. " heilen, wenn etwas schiefgeht" end
        if C.tank then score = score + 1; good[#good + 1] = "Du kannst Gegner von " .. name .. " fernhalten" end
        if cls == "MAGE" then score = score + 0.5; good[#good + 1] = "Du zauberst Essen, Wasser und später Portale für euch" end
        if cls == "WARLOCK" then score = score + 0.5; good[#good + 1] = "Du machst Heilsteine und kannst " .. name .. " herbeirufen" end
        local pct = math.floor(100 * math.max(score, 0) / 7.5 + 0.5)
        rows[#rows + 1] = { class = cls, pct = math.max(3, math.min(100, pct)), good = {}, duo = good, warn = warn }
    end
    return sortRows(rows)
end

function KG.QuizDone(quiz, answers)
    for _, q in ipairs(quiz) do
        if not answers[q.key] then return false end
    end
    return true
end

---------------------------------------------------------------------------
-- Auswertung: Berufe
---------------------------------------------------------------------------

local FEEDS = { mining = { "blacksmithing", "engineering" }, herbalism = { "alchemy" }, skinning = { "leatherworking" } }
local SELF_PTS = { [0] = -5, [1] = 0, [2] = 2, [3] = 4 }
local PARTNER_PTS = { [0] = 0, [1] = 0, [2] = 1.5, [3] = 3 }

local function benefitNote(prof, class, kind)
    local n = KG.PROF_BENEFIT_NOTE[prof] or {}
    if kind == "good" then return n[class] or n.good end
    return n.none
end

-- Nutzen einer Herstellung für eine Klasse (0 bis 3)
function KG.ProfBenefit(prof, class)
    local t = KG.PROF_BENEFIT[prof]
    return t and class and t[class] or 0
end

-- Bewertet alle Paare von Hauptberufen für classKey; partner = Profil der Begleitung (oder nil)
function KG.ScoreProfs(ans, classKey, partner)
    local pset = {}
    for _, k in ipairs(partner and partner.profs or {}) do pset[k] = true end
    local pname = partner and partner.name or "deine Begleitung"
    local pclass = partner and partner.class
    local cname = classKey and KG.ClassName(classKey) or "deine Klasse"
    local help = ans.goal == "help"
    local order, out = KG.PROF_ORDER, {}

    -- Nützlichkeit eines Herstellungsberufs: für dich und für die Begleitung
    local function craftUse(x)
        local self = KG.ProfBenefit(x, classKey)
        local other = partner and KG.ProfBenefit(x, pclass) or 0
        return self, other
    end

    for i = 1, #order do
        for j = i + 1, #order do
            local a, b = order[i], order[j]
            local s, good, warn = 0, {}, {}
            local function add(pts, txt, bad)
                s = s + pts
                if txt then
                    local t = bad and warn or good
                    t[#t + 1] = txt
                end
            end

            for _, x in ipairs({ a, b }) do
                local p = KG.PROFS[x]
                local y = (x == a) and b or a
                if p.gather then
                    if ans.style == "gather" or ans.style == "none" then add(2) end
                    if ans.goal == "gold" then add(2) end
                    if ans.effort == "low" then add(x == "skinning" and 2 or 1) end
                else
                    local mine, theirs = craftUse(x)
                    if ans.style == "craft" then add(1) end
                    if ans.style == "gather" or ans.style == "none" then add(-1) end
                    if ans.effort == "low" then add(x == "engineering" and -2 or -1)
                    elseif ans.effort == "high" then add(1) end

                    -- Was hast du selbst davon?
                    local pts = SELF_PTS[mine]
                    if mine >= 2 and ans.goal == "gear" then pts = pts * 1.5 end
                    if mine == 0 and ans.goal == "gear" then pts = pts - 1 end
                    add(pts)
                    if mine >= 2 then
                        add(0, p.name .. ": " .. (benefitNote(x, classKey, "good") or "nützlich für deine Klasse"))
                    elseif mine == 0 then
                        local why = benefitNote(x, classKey, "none")
                        add(0, p.name .. " bringt dir als " .. cname .. " kaum etwas" .. (why and (": " .. why) or ""), true)
                    end

                    -- Was hat die Begleitung davon?
                    if partner and not pset[x] then
                        local pp = PARTNER_PTS[theirs] * (help and 1.4 or 0.7)
                        add(pp)
                        if theirs >= 2 then
                            add(0, pname .. " (" .. KG.ClassName(pclass) .. ") kann deine " .. p.name .. " gut gebrauchen: " .. (benefitNote(x, pclass, "good") or "nützlich"))
                        end
                    end

                    if p.needs and y ~= p.needs then
                        if pset[p.needs] then
                            add(3, pname .. " hat " .. KG.PROFS[p.needs].name .. " und kann dir das Material für " .. p.name .. " liefern")
                        else
                            add(-3, "Für " .. p.name .. " fehlt dir " .. KG.PROFS[p.needs].name .. ": das Material müsstest du kaufen", true)
                        end
                    end
                end
                if partner then
                    if pset[x] then
                        if p.gather then add(-1, pname .. " sammelt schon mit " .. p.name, true)
                        else add(-5, pname .. " hat " .. p.name .. " schon, das braucht ihr nicht doppelt", true) end
                    elseif p.gather then
                        for _, craft in ipairs(FEEDS[x] or {}) do
                            if pset[craft] then
                                add(help and 6 or 4, "Du lieferst mit " .. p.name .. " das Material für " .. KG.PROFS[craft].name .. " von " .. pname)
                                break
                            end
                        end
                    elseif p.shared and KG.ProfBenefit(x, pclass) >= 1 then
                        add(help and 2 or 1, p.name .. ": " .. p.shared)
                    end
                end
            end

            local pa, pb = KG.PROFS[a], KG.PROFS[b]
            if pa.needs == b or pb.needs == a then
                local g, c = pa.gather and pa or pb, pa.gather and pb or pa
                local ckey = pa.gather and b or a
                local mine, theirs = craftUse(ckey)
                if mine >= 2 or theirs >= 2 then
                    add(4, g.name .. " liefert dir das Material für " .. c.name)
                    if ans.style == "both" then add(2) end
                elseif mine == 1 or theirs == 1 then
                    add(1, g.name .. " liefert das Material für " .. c.name)
                else
                    add(0, g.name .. " liefert zwar Material für " .. c.name .. ", aber damit stellst du nichts für dich her", true)
                end
            elseif a == "tailoring" and b == "enchanting" then
                local mine = KG.ProfBenefit("tailoring", classKey)
                if mine >= 2 then
                    add(3, "Schneiderei braucht keinen Sammelberuf, und was du nähst, kannst du entzaubern")
                    if ans.style == "craft" then add(1) end
                else
                    add(1, "Schneiderei braucht keinen Sammelberuf, und was du nähst, kannst du entzaubern")
                end
            elseif pa.gather and pb.gather then
                add(0, "Zwei Sammelberufe: kaum Aufwand, und das Material lässt sich gut verkaufen")
                if a == "herbalism" and b == "mining" then
                    add(-2, "Kräuter und Erz kannst du nicht gleichzeitig auf der Minikarte suchen", true)
                end
            elseif not pa.gather and not pb.gather then
                add(-3, "Zwei Herstellungsberufe kosten viel Gold und Zeit", true)
            end
            if #good == 0 then good[1] = "Solide Kombination ohne besondere Vorteile" end
            out[#out + 1] = { a = a, b = b, score = s, good = good, warn = warn }
        end
    end

    table.sort(out, function(x, y) return x.score > y.score end)
    for _, r in ipairs(out) do
        r.pct = math.max(3, math.min(100, math.floor(40 + 4.5 * r.score + 0.5)))
    end
    return out
end

function KG.SecondaryAdvice(classKey, partner)
    local C = KG.CLASSES[classKey or ""]
    local psec = {}
    for _, k in ipairs(partner and partner.sec or {}) do psec[k] = true end
    local pname = partner and partner.name or "deine Begleitung"
    local out = {}
    out[#out + 1] = { key = "firstaid", text = (C and not C.heal) and "Unbedingt lernen: du hast keine Heilzauber, Verbände retten dich" or "Praktisch: Verbände heilen ohne Mana" }
    if psec.cooking then
        out[#out + 1] = { key = "cooking", text = pname .. " kann schon kochen und euch versorgen. Für dich kein Muss" }
    else
        out[#out + 1] = { key = "cooking", text = classKey == "HUNTER" and "Lohnt sich: dein Tier frisst auch mit" or "Gekochtes Essen stärkt euch beide" }
    end
    out[#out + 1] = { key = "fishing", text = psec.fishing and (pname .. " angelt schon. Nur lernen, wenn es dir Spaß macht") or "Nur lernen, wenn es dir Spaß macht" }
    return out
end

---------------------------------------------------------------------------
-- Start
---------------------------------------------------------------------------

local lastAuto = 0
local f = CreateFrame("Frame")
f:RegisterEvent("ADDON_LOADED")
f:RegisterEvent("PLAYER_LOGIN")
f:RegisterEvent("CHAT_MSG_ADDON")
f:RegisterEvent("GROUP_ROSTER_UPDATE")
f:RegisterEvent("PLAYER_LEVEL_UP")
pcall(f.RegisterEvent, f, "CHARACTER_POINTS_CHANGED")
pcall(f.RegisterEvent, f, "TRAINER_SHOW")
pcall(f.RegisterEvent, f, "TRAINER_UPDATE")
pcall(f.RegisterEvent, f, "TRAINER_CLOSED")
f:SetScript("OnEvent", function(_, event, a1, a2, a3, a4)
    if event == "ADDON_LOADED" then
        if a1 ~= ADDON then return end
        KindergartenDB = KindergartenDB or {}
        local db = KindergartenDB
        db.quiz = db.quiz or {}
        db.profQuiz = db.profQuiz or {}
        db.todo = db.todo or {}
        db.trees = db.trees or {}
        db.builds = db.builds or {}
        db.teach = db.teach or {}
        db.scale = db.scale or 1
        KG.db = db
        if C_ChatInfo and C_ChatInfo.RegisterAddonMessagePrefix then C_ChatInfo.RegisterAddonMessagePrefix(PREFIX)
        elseif RegisterAddonMessagePrefix then RegisterAddonMessagePrefix(PREFIX) end
    elseif event == "PLAYER_LOGIN" then
        if not KG.db then return end
        if C_Timer and C_Timer.After then
            C_Timer.After(8, function() if KG.TeachReminder then KG.TeachReminder() end end)
        end
        if not KG.db.seen and C_Timer and C_Timer.After then
            C_Timer.After(4, function() if KG.ToggleUI and not KG.db.seen then KG.ToggleUI() end end)
        else
            KG.Print("|cffffff00/kg|r öffnet den Kindergarten.")
        end
    elseif event == "CHAT_MSG_ADDON" then
        onAddonMessage(a1, a2, a3, a4)
    elseif event == "TRAINER_SHOW" or event == "TRAINER_UPDATE" then
        if KG.db and KG.UpdateTrainerPanel then pcall(KG.UpdateTrainerPanel) end
    elseif event == "TRAINER_CLOSED" then
        if KG.HideTrainerPanel then KG.HideTrainerPanel() end
    elseif event == "PLAYER_LEVEL_UP" or event == "CHARACTER_POINTS_CHANGED" then
        if KG.db and KG.TalentPointsChanged then
            local function check()
                KG.TalentPointsChanged()
                if event == "PLAYER_LEVEL_UP" and KG.TeachReminder then KG.TeachReminder() end
            end
            if C_Timer and C_Timer.After then C_Timer.After(1.5, check) else check() end
        end
    elseif event == "GROUP_ROSTER_UPDATE" then
        if KG.db and KG.db.role and GetTime and GetTime() - lastAuto > 15 and groupChannel() then
            lastAuto = GetTime()
            KG.SendToGroup(true)
        end
    end
end)

SLASH_KINDERGARTEN1 = "/kg"
SLASH_KINDERGARTEN2 = "/kindergarten"
SlashCmdList["KINDERGARTEN"] = function(msg)
    msg = strlower(strtrim(msg or ""))
    if msg == "talente" and KG.TalentDump then KG.TalentDump() return end
    if KG.ToggleUI then KG.ToggleUI() end
end

BINDING_HEADER_KINDERGARTEN = "Kindergarten"
BINDING_NAME_KINDERGARTEN_TOGGLE = "Kindergarten öffnen oder schließen"
