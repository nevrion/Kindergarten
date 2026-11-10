local _, KG = ...

local W, H, SIDE = 940, 640, 230
local BODY_W = W - SIDE - 52
local FLAT = "Interface\\Buttons\\WHITE8X8"
local FONT = STANDARD_TEXT_FONT or "Fonts\\FRIZQT__.TTF"

local C = {
    bg = { 0.07, 0.065, 0.11, 0.98 }, side = { 0.10, 0.09, 0.16, 1 }, card = { 0.135, 0.125, 0.2, 1 },
    cardHover = { 0.18, 0.165, 0.26, 1 }, edge = { 0.24, 0.22, 0.34, 1 }, field = { 0.06, 0.055, 0.09, 1 },
    text = { 0.93, 0.92, 0.97 }, dim = { 0.62, 0.6, 0.72 },
    sun = { 1, 0.8, 0.36 }, mint = { 0.45, 0.87, 0.7 }, pink = { 0.98, 0.55, 0.68 }, sky = { 0.47, 0.74, 0.98 },
}

local ui, current
local pages = {}
local ShowPage

-- Alles Anklickbare meldet sich hier an, damit die Controller-Navigation es findet
local focusables = {}
local function Reg(w, kind)
    w.kgKind = kind
    focusables[#focusables + 1] = w
    return w
end

---------------------------------------------------------------------------
-- Bausteine
---------------------------------------------------------------------------

local function Flat(f, bg, edge)
    f:SetBackdrop({ bgFile = FLAT, edgeFile = FLAT, edgeSize = 1, insets = { left = 1, right = 1, top = 1, bottom = 1 } })
    f:SetBackdropColor(unpack(bg))
    f:SetBackdropBorderColor(unpack(edge or C.edge))
end

local function Text(parent, size, color, flags)
    local t = parent:CreateFontString(nil, "OVERLAY")
    t:SetFont(FONT, size, flags or "")
    t:SetTextColor(unpack(color or C.text))
    t:SetJustifyH("LEFT")
    t:SetJustifyV("TOP")
    if t.SetSpacing then t:SetSpacing(2) end
    return t
end

local function Card(parent, clickable)
    local c = CreateFrame(clickable and "Button" or "Frame", nil, parent, "BackdropTemplate")
    Flat(c, C.card)
    function c:Paint()
        if self.selected then
            self:SetBackdropColor(unpack(C.cardHover))
            self:SetBackdropBorderColor(unpack(C.sun))
        elseif self.hover then
            self:SetBackdropColor(unpack(C.cardHover))
            self:SetBackdropBorderColor(unpack(C.sky))
        else
            self:SetBackdropColor(unpack(C.card))
            self:SetBackdropBorderColor(unpack(C.edge))
        end
    end
    function c:SetSelected(b) self.selected = b and true or false; self:Paint() end
    if clickable then
        c:SetScript("OnEnter", function(self) self.hover = true; self:Paint() end)
        c:SetScript("OnLeave", function(self) self.hover = false; self:Paint() end)
        Reg(c, "btn")
    end
    return c
end

local function Btn(parent, text, w, h, kind, onClick)
    local b = CreateFrame("Button", nil, parent, "BackdropTemplate")
    b:SetSize(w, h or 28)
    local primary = kind == "primary"
    local base = primary and C.sun or C.card
    local hover = primary and { 1, 0.88, 0.55, 1 } or C.cardHover
    Flat(b, base, primary and C.sun or C.edge)
    b.label = Text(b, 12, primary and { 0.13, 0.1, 0.04 } or C.text)
    b.label:SetPoint("CENTER", 0, 0)
    b.label:SetText(text)
    function b:SetLabel(t) self.label:SetText(t) end
    b:SetScript("OnEnter", function(self) self:SetBackdropColor(unpack(hover)) end)
    b:SetScript("OnLeave", function(self) self:SetBackdropColor(unpack(base)) end)
    b:SetScript("OnDisable", function(self) self:SetAlpha(0.4) end)
    b:SetScript("OnEnable", function(self) self:SetAlpha(1) end)
    if onClick then b:SetScript("OnClick", onClick) end
    return Reg(b, "btn")
end

local function Edit(parent, w)
    local e = CreateFrame("EditBox", nil, parent, "BackdropTemplate")
    e:SetSize(w, 24)
    Flat(e, C.field)
    e:SetFont(FONT, 12, "")
    e:SetTextColor(unpack(C.text))
    e:SetAutoFocus(false)
    e:SetTextInsets(7, 7, 0, 0)
    e:SetScript("OnEscapePressed", e.ClearFocus)
    e:SetScript("OnEnterPressed", e.ClearFocus)
    e:SetScript("OnEditFocusGained", function(self) self:SetBackdropBorderColor(unpack(C.sun)) end)
    e:SetScript("OnEditFocusLost", function(self) self:SetBackdropBorderColor(unpack(C.edge)) end)
    return Reg(e, "edit")
end

local function Icon(parent, size, name)
    local t = parent:CreateTexture(nil, "ARTWORK")
    t:SetSize(size, size)
    if name then
        t:SetTexture("Interface\\Icons\\" .. name)
        t:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    end
    return t
end

local function SetClassIcon(tex, key)
    local coords = CLASS_ICON_TCOORDS and CLASS_ICON_TCOORDS[key]
    if coords then
        tex:SetTexture("Interface\\TargetingFrame\\UI-Classes-Circles")
        tex:SetTexCoord(unpack(coords))
    elseif KG.CLASSES[key] then
        tex:SetTexture("Interface\\Icons\\" .. KG.CLASSES[key].icon)
        tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
    end
end

local function SetProfIcon(tex, key)
    tex:SetTexture("Interface\\Icons\\" .. KG.PROFS[key].icon)
    tex:SetTexCoord(0.08, 0.92, 0.08, 0.92)
end

local function Bar(parent, w, h)
    local b = CreateFrame("Frame", nil, parent)
    b:SetSize(w, h)
    local bg = b:CreateTexture(nil, "BACKGROUND")
    bg:SetAllPoints()
    bg:SetColorTexture(1, 1, 1, 0.08)
    b.fill = b:CreateTexture(nil, "ARTWORK")
    b.fill:SetPoint("TOPLEFT", 0, 0)
    b.fill:SetPoint("BOTTOMLEFT", 0, 0)
    function b:Set(pct, r, g, bl)
        self.fill:SetWidth(math.max(1, w * math.max(0, math.min(100, pct)) / 100))
        self.fill:SetColorTexture(r or C.sun[1], g or C.sun[2], bl or C.sun[3], 1)
    end
    return b
end

local function Check(parent, onClick)
    local c = CreateFrame("CheckButton", nil, parent, "BackdropTemplate")
    c:SetSize(18, 18)
    Flat(c, C.field)
    c:SetCheckedTexture(FLAT)
    local t = c:GetCheckedTexture()
    t:SetVertexColor(unpack(C.mint))
    t:ClearAllPoints()
    t:SetPoint("TOPLEFT", 4, -4)
    t:SetPoint("BOTTOMRIGHT", -4, 4)
    c:SetScript("OnClick", function(self) onClick(self, self:GetChecked() and true or false) end)
    return Reg(c, "btn")
end

local function Tooltip(frame, fn)
    frame:HookScript("OnEnter", function(self)
        GameTooltip:SetOwner(self, "ANCHOR_RIGHT")
        fn(self)
        GameTooltip:Show()
    end)
    frame:HookScript("OnLeave", function() GameTooltip:Hide() end)
end

local function Colored(text, c)
    return ("|cff%02x%02x%02x%s|r"):format(math.floor(c[1] * 255 + 0.5), math.floor(c[2] * 255 + 0.5), math.floor(c[3] * 255 + 0.5), text)
end

local function ClassText(key)
    local r, g, b = KG.ClassColor(key)
    return Colored(KG.ClassName(key), { r, g, b })
end

local function ProfList(keys)
    local n = {}
    for _, k in ipairs(keys or {}) do n[#n + 1] = KG.PROFS[k].name end
    return #n > 0 and table.concat(n, ", ") or "keine"
end

local function IsParent() return KG.db.role == "parent" end

local function EmptyState(parent, text, btnText, onClick)
    local e = Card(parent, false)
    e:SetPoint("TOPLEFT", 0, 0)
    e:SetSize(BODY_W, 150)
    e.text = Text(e, 14, C.text)
    e.text:SetPoint("TOPLEFT", 24, -26)
    e.text:SetWidth(BODY_W - 48)
    e.text:SetText(text)
    e.btn = Btn(e, btnText, 240, 32, "primary", onClick)
    e.btn:SetPoint("BOTTOMLEFT", 24, 22)
    return e
end

---------------------------------------------------------------------------
-- Controller-Navigation (eingebautes Gamepad-System)
-- Steuerkreuz: nächstes Feld in der Richtung, A: bestätigen, B: schließen, LB/RB: Schritt wechseln
---------------------------------------------------------------------------

local Nav = { active = false }

local function navList()
    local t = {}
    for _, w in ipairs(focusables) do
        if w:IsVisible() and (w.kgKind == "edit" or (w:IsEnabled() and w:GetScript("OnClick"))) then
            local x, y = w:GetCenter()
            if x and y then t[#t + 1] = { w = w, x = x, y = y } end
        end
    end
    return t
end

function Nav.Set(w)
    Nav.focus = w
    if not Nav.ring then
        Nav.ring = CreateFrame("Frame", nil, ui, "BackdropTemplate")
        Nav.ring:SetBackdrop({ edgeFile = FLAT, edgeSize = 2 })
        Nav.ring:SetBackdropBorderColor(C.sun[1], C.sun[2], C.sun[3], 1)
    end
    if not w then Nav.ring:Hide() return end
    Nav.ring:SetParent(w)
    Nav.ring:ClearAllPoints()
    Nav.ring:SetPoint("TOPLEFT", w, "TOPLEFT", -3, 3)
    Nav.ring:SetPoint("BOTTOMRIGHT", w, "BOTTOMRIGHT", 3, -3)
    Nav.ring:SetFrameLevel((w:GetFrameLevel() or 1) + 10)
    Nav.ring:Show()
end

-- Startfeld: oberstes, dann linkestes Feld im Inhaltsbereich
function Nav.Default(list)
    local best
    for _, c in ipairs(list) do
        if not c.w.kgSide and not c.w.kgNoDefault then
            if not best or c.y > best.y + 2 or (math.abs(c.y - best.y) <= 2 and c.x < best.x) then best = c end
        end
    end
    return best and best.w or (list[1] and list[1].w)
end

function Nav.Fix()
    if not Nav.active then return end
    local f = Nav.focus
    if f and f:IsVisible() and (f.kgKind == "edit" or f:IsEnabled()) then return end
    Nav.Set(Nav.Default(navList()))
end

function Nav.Move(dx, dy)
    local list = navList()
    if #list == 0 then return end
    local cur, cx, cy = Nav.focus, nil, nil
    if cur and cur:IsVisible() then cx, cy = cur:GetCenter() end
    if not cx then Nav.Set(Nav.Default(list)) return end
    local best, bestScore
    for _, c in ipairs(list) do
        if c.w ~= cur then
            local ax, ay = c.x - cx, c.y - cy
            local along = ax * dx + ay * dy
            local across = math.abs(ax * dy) + math.abs(ay * dx)
            if along > 4 then
                local score = along + across * 2.5
                if not bestScore or score < bestScore then best, bestScore = c.w, score end
            end
        end
    end
    if best then Nav.Set(best) end
end

function Nav.Step(dir)
    local list, idx = {}, 1
    for _, b in ipairs(ui.steps) do
        if b:IsShown() and b:IsEnabled() then
            list[#list + 1] = b
            if b.step.key == current then idx = #list end
        end
    end
    local b = list[idx + dir]
    if b then
        Nav.focus = nil
        ShowPage(b.step.key)
    end
end

local NAV_BUTTONS = {
    PADDUP = function() Nav.Move(0, 1) end,
    PADDDOWN = function() Nav.Move(0, -1) end,
    PADDLEFT = function() Nav.Move(-1, 0) end,
    PADDRIGHT = function() Nav.Move(1, 0) end,
    PADLSHOULDER = function() Nav.Step(-1) end,
    PADRSHOULDER = function() Nav.Step(1) end,
    PAD1 = function()
        local w = Nav.focus
        if not w or not w:IsVisible() then Nav.Fix() return end
        if w.kgKind == "edit" then w:SetFocus()
        elseif w:IsEnabled() then w:Click() end
        Nav.Fix()
    end,
    PAD2 = function()
        local w = Nav.focus
        if w and w.kgKind == "edit" and w:HasFocus() then w:ClearFocus() else ui:Hide() end
    end,
}

-- Liefert true, wenn die Taste von der Navigation verbraucht wurde
function Nav.Handle(button)
    local fn = NAV_BUTTONS[button]
    if not fn then return false end
    if not Nav.active then
        Nav.active = true
        ui.padHint:Show()
        Nav.Fix()
        if button ~= "PAD2" then return true end
    end
    fn()
    return true
end
KG.NavHandle = Nav.Handle

---------------------------------------------------------------------------
-- Fragebogen (für Spielstil und Berufe)
---------------------------------------------------------------------------

local function QuizView(parent, quiz, getAnswers, onDone)
    local v = CreateFrame("Frame", nil, parent)
    v:SetAllPoints()
    v.idx = 1
    v.count = Text(v, 11, C.dim)
    v.count:SetPoint("TOPLEFT", 0, 0)
    v.bar = Bar(v, BODY_W, 6)
    v.bar:SetPoint("TOPLEFT", 0, -20)
    v.q = Text(v, 19, C.text)
    v.q:SetPoint("TOPLEFT", 0, -46)
    v.q:SetWidth(BODY_W)
    v.hint = Text(v, 12, C.dim)
    v.hint:SetPoint("TOPLEFT", v.q, "BOTTOMLEFT", 0, -8)
    v.hint:SetWidth(BODY_W)

    v.cards = {}
    for i = 1, 5 do
        local c = Card(v, true)
        c:SetSize(BODY_W, 50)
        c:SetPoint("TOPLEFT", 0, -140 - (i - 1) * 58)
        c.dot = c:CreateTexture(nil, "ARTWORK")
        c.dot:SetSize(12, 12)
        c.dot:SetPoint("LEFT", 18, 0)
        c.label = Text(c, 14, C.text)
        c.label:SetPoint("LEFT", 44, 0)
        c:SetScript("OnClick", function(self)
            getAnswers()[quiz[v.idx].key] = self.key
            if v.idx < #quiz then
                v.idx = v.idx + 1
                v:Render()
                if Nav.active then Nav.Set(v.cards[1]) end
            else
                onDone()
            end
        end)
        v.cards[i] = c
    end

    v.back = Btn(v, "Zurück", 110, 30, "ghost", function()
        if v.idx > 1 then v.idx = v.idx - 1; v:Render() end
    end)
    v.back:SetPoint("BOTTOMLEFT", 0, 0)

    function v:Render()
        local q = quiz[self.idx]
        local ans = getAnswers()
        self.count:SetText(("Frage %d von %d"):format(self.idx, #quiz))
        self.bar:Set(100 * (self.idx - 1) / #quiz)
        self.q:SetText(q.text)
        self.hint:SetText(q.hint or "")
        for i, c in ipairs(self.cards) do
            local a = q.answers[i]
            if a then
                c.key = a.key
                c.label:SetText(a.text)
                local sel = ans[q.key] == a.key
                c.dot:SetColorTexture(sel and C.sun[1] or 1, sel and C.sun[2] or 1, sel and C.sun[3] or 1, sel and 1 or 0.18)
                c.hover = false
                c:SetSelected(sel)
                c:Show()
            else
                c:Hide()
            end
        end
        self.back:SetShown(self.idx > 1)
    end

    function v:Start(fromBeginning)
        self.idx = 1
        if not fromBeginning then
            local ans = getAnswers()
            for i, q in ipairs(quiz) do
                if not ans[q.key] then self.idx = i break end
            end
        end
        self:Render()
    end
    return v
end

---------------------------------------------------------------------------
-- Seite: Willkommen
---------------------------------------------------------------------------

pages.welcome = {
    title = function() return "Willkommen im Kindergarten" end,
    sub = function() return "Gemeinsam in die Welt von Azeroth: Schritt für Schritt, ohne Vorwissen." end,
    build = function(p)
        local intro = Text(p, 13, C.text)
        intro:SetPoint("TOPLEFT", 0, 0)
        intro:SetWidth(BODY_W)
        intro:SetText("Dieses Addon hilft beim Start: Es findet heraus, welche Klasse und welche Berufe zu dir passen, und stimmt alles mit deiner Begleitung ab. Wer bist du?")

        local function roleCard(x, role, icon, title, text, color)
            local c = Card(p, true)
            c:SetSize((BODY_W - 18) / 2, 250)
            c:SetPoint("TOPLEFT", x, -70)
            local stripe = c:CreateTexture(nil, "ARTWORK")
            stripe:SetPoint("TOPLEFT", 1, -1)
            stripe:SetPoint("TOPRIGHT", -1, -1)
            stripe:SetHeight(4)
            stripe:SetColorTexture(color[1], color[2], color[3], 1)
            local ic = Icon(c, 52, icon)
            ic:SetPoint("TOPLEFT", 22, -26)
            local t = Text(c, 18, color)
            t:SetPoint("TOPLEFT", 22, -92)
            t:SetText(title)
            local d = Text(c, 12, C.text)
            d:SetPoint("TOPLEFT", t, "BOTTOMLEFT", 0, -10)
            d:SetWidth((BODY_W - 18) / 2 - 44)
            d:SetText(text)
            c.mark = Text(c, 11, C.sun)
            c.mark:SetPoint("BOTTOMLEFT", 22, 16)
            c:SetScript("OnClick", function()
                KG.db.role = role
                KG.RefreshUI()
                ShowPage("partner")
            end)
            c.role = role
            return c
        end
        p.cards = {
            roleCard(0, "kid", "INV_Misc_Book_09", "Ich bin neu in WoW",
                "Du bekommst ein paar einfache Fragen gestellt. Daraus entsteht eine Empfehlung für deine Klasse und deine Berufe, abgestimmt auf die Person, die mit dir spielt.", C.mint),
            roleCard((BODY_W - 18) / 2 + 18, "parent", "Spell_Holy_PrayerOfHealing", "Ich begleite jemanden",
                "Du kennst das Spiel schon und nimmst jemanden an die Hand. Du siehst, was dein Kind gewählt hat, welche Klasse und Berufe bei dir am besten dazu passen und wie du helfen kannst.", C.sky),
        }

        p.note = Text(p, 11, C.dim)
        p.note:SetPoint("TOPLEFT", 0, -340)
        p.note:SetWidth(BODY_W)
        p.note:SetText("Tipp: Am besten installiert ihr beide das Addon. Dann tauscht es Klasse und Berufe automatisch aus, sobald ihr in einer Gruppe seid. Öffnen kannst du es jederzeit mit /kg.")

        p.reset = Btn(p, "Alles zurücksetzen", 170, 26, "ghost", function(self)
            if not self.armed then
                self.armed = true
                self:SetLabel("Wirklich? Nochmal klicken")
                return
            end
            self.armed = false
            self:SetLabel("Alles zurücksetzen")
            local db = KG.db
            db.role, db.chosenClass, db.chosenProfs, db.partner = nil, nil, nil, nil
            db.quiz, db.profQuiz, db.todo = {}, {}, {}
            KG.RefreshUI()
        end)
        p.reset:SetPoint("BOTTOMLEFT", 0, 0)
    end,
    refresh = function(p)
        for _, c in ipairs(p.cards) do
            local sel = KG.db.role == c.role
            c.mark:SetText(sel and "Ausgewählt" or "")
            c.hover = false
            c:SetSelected(sel)
        end
        p.reset.armed = false
        p.reset:SetLabel("Alles zurücksetzen")
        p.reset:SetShown(KG.db.role ~= nil)
    end,
}

---------------------------------------------------------------------------
-- Seite: Begleitung / Mein Kind
---------------------------------------------------------------------------

pages.partner = {
    title = function() return IsParent() and "Mein Kind" or "Meine Begleitung" end,
    sub = function()
        return IsParent() and "Mit wem bist du unterwegs? Klasse und Berufe deines Kindes bestimmen, was bei dir am besten passt."
            or "Wer spielt mit dir? Klasse und Berufe deiner Begleitung fließen in deine Empfehlungen ein."
    end,
    build = function(p)
        local LW, RW = 300, BODY_W - 300 - 14
        local man = { profs = {}, sec = {} }
        p.man = man

        -- Status
        local st = Card(p, false)
        st:SetSize(LW, 150)
        st:SetPoint("TOPLEFT", 0, 0)
        st.head = Text(st, 11, C.dim)
        st.head:SetPoint("TOPLEFT", 14, -12)
        st.icon = st:CreateTexture(nil, "ARTWORK")
        st.icon:SetSize(40, 40)
        st.icon:SetPoint("TOPLEFT", 14, -34)
        st.name = Text(st, 16, C.text)
        st.name:SetPoint("TOPLEFT", 64, -34)
        st.line = Text(st, 12, C.text)
        st.line:SetPoint("TOPLEFT", 64, -56)
        st.profs = Text(st, 11, C.text)
        st.profs:SetPoint("TOPLEFT", 14, -86)
        st.profs:SetWidth(LW - 28)
        st.src = Text(st, 10, C.dim)
        st.src:SetPoint("BOTTOMLEFT", 14, 10)
        p.st = st

        -- Automatisch
        local au = Card(p, false)
        au:SetSize(LW, 150)
        au:SetPoint("TOPLEFT", 0, -162)
        local t1 = Text(au, 12, C.sun)
        t1:SetPoint("TOPLEFT", 14, -12)
        t1:SetText("Automatisch")
        local t2 = Text(au, 11, C.text)
        t2:SetPoint("TOPLEFT", 14, -32)
        t2:SetWidth(LW - 28)
        t2:SetText("Habt ihr beide das Addon und seid in einer Gruppe, tauscht es eure Daten von allein aus.")
        local ask = Btn(au, "In der Gruppe anfragen", LW - 28, 26, "primary", function() KG.RequestFromGroup() end)
        ask:SetPoint("TOPLEFT", 14, -78)
        p.wName = Edit(au, LW - 28 - 96)
        p.wName:SetPoint("TOPLEFT", 14, -112)
        local wBtn = Btn(au, "Zuflüstern", 90, 24, "ghost", function() KG.SendWhisper(p.wName:GetText()) end)
        wBtn:SetPoint("LEFT", p.wName, "RIGHT", 6, 0)
        Tooltip(p.wName, function() GameTooltip:SetText("Charaktername eintragen, um dein Profil ohne Gruppe zu schicken.", 1, 1, 1, 1, true) end)

        -- Code
        local co = Card(p, false)
        co:SetSize(LW, 170)
        co:SetPoint("TOPLEFT", 0, -324)
        local c1 = Text(co, 12, C.sun)
        c1:SetPoint("TOPLEFT", 14, -12)
        c1:SetText("Per Code")
        local c2 = Text(co, 11, C.text)
        c2:SetPoint("TOPLEFT", 14, -32)
        c2:SetWidth(LW - 28)
        c2:SetText("Ohne Gruppe: Code kopieren und per Chat oder Messenger schicken. Den Code der anderen Person hier einfügen.")
        p.code = Edit(co, LW - 28)
        p.code:SetPoint("TOPLEFT", 14, -90)
        p.code:SetMaxLetters(0)
        local mine = Btn(co, "Meinen Code zeigen", (LW - 34) / 2, 26, "ghost", function()
            p.code:SetText(KG.Encode(KG.BuildProfile()))
            p.code:SetFocus()
            p.code:HighlightText()
            p.codeInfo:SetText("Markiert: Strg+C kopiert den Code.")
        end)
        mine:SetPoint("TOPLEFT", 14, -122)
        local take = Btn(co, "Code übernehmen", (LW - 34) / 2, 26, "primary", function()
            local t, err = KG.Decode(p.code:GetText())
            if not t then p.codeInfo:SetText(Colored(err, C.pink)) return end
            if t.name == KG.MyName() then p.codeInfo:SetText(Colored("Das ist dein eigener Code.", C.pink)) return end
            p.code:SetText("")
            p.codeInfo:SetText("")
            KG.SetPartner(t, "code")
        end)
        take:SetPoint("LEFT", mine, "RIGHT", 6, 0)
        p.codeInfo = Text(co, 10, C.dim)
        p.codeInfo:SetPoint("BOTTOMLEFT", 14, 8)

        -- Von Hand
        local mn = Card(p, false)
        mn:SetSize(RW, 494)
        mn:SetPoint("TOPLEFT", LW + 14, 0)
        local IW = RW - 28
        local m1 = Text(mn, 12, C.sun)
        m1:SetPoint("TOPLEFT", 14, -12)
        m1:SetText("Von Hand eintragen")
        local m2 = Text(mn, 11, C.dim)
        m2:SetPoint("TOPLEFT", 14, -34)
        m2:SetText("Name")
        p.mName = Edit(mn, IW)
        p.mName:SetPoint("TOPLEFT", 14, -50)
        p.mName:SetMaxLetters(24)

        local m3 = Text(mn, 11, C.dim)
        m3:SetPoint("TOPLEFT", 14, -86)
        m3:SetText("Klasse")
        p.classTiles = {}
        local tw = (IW - 12) / 3
        for i, key in ipairs(KG.CLASS_ORDER) do
            local c = Card(mn, true)
            c:SetSize(tw, 32)
            c:SetPoint("TOPLEFT", 14 + ((i - 1) % 3) * (tw + 6), -104 - math.floor((i - 1) / 3) * 38)
            local ic = c:CreateTexture(nil, "ARTWORK")
            ic:SetSize(22, 22)
            ic:SetPoint("LEFT", 6, 0)
            SetClassIcon(ic, key)
            local l = Text(c, 11, C.text)
            l:SetPoint("LEFT", 34, 0)
            l:SetText(KG.ClassName(key))
            c.key = key
            c:SetScript("OnClick", function(self) man.class = self.key; pages.partner.paintManual(p) end)
            p.classTiles[i] = c
        end

        local m4 = Text(mn, 11, C.dim)
        m4:SetPoint("TOPLEFT", 14, -226)
        m4:SetText("Hauptberufe (höchstens zwei)")
        p.profChips = {}
        local function chip(key, x, y, set, max)
            local c = Card(mn, true)
            c:SetSize(tw, 24)
            c:SetPoint("TOPLEFT", x, y)
            local l = Text(c, 10, C.text)
            l:SetPoint("CENTER", 0, 0)
            l:SetText(KG.PROFS[key].name)
            c.key, c.set = key, set
            c:SetScript("OnClick", function(self)
                if set[key] then
                    set[key] = nil
                else
                    local n = 0
                    for _ in pairs(set) do n = n + 1 end
                    if n >= max then return end
                    set[key] = true
                end
                pages.partner.paintManual(p)
            end)
            Tooltip(c, function() GameTooltip:SetText(KG.PROFS[key].name .. "\n" .. KG.PROFS[key].desc, 1, 1, 1, 1, true) end)
            p.profChips[#p.profChips + 1] = c
        end
        for i, key in ipairs(KG.PROF_ORDER) do
            chip(key, 14 + ((i - 1) % 3) * (tw + 6), -244 - math.floor((i - 1) / 3) * 29, man.profs, 2)
        end
        local m5 = Text(mn, 11, C.dim)
        m5:SetPoint("TOPLEFT", 14, -340)
        m5:SetText("Nebenberufe")
        for i, key in ipairs(KG.SEC_ORDER) do
            chip(key, 14 + (i - 1) * (tw + 6), -358, man.sec, 3)
        end

        p.mInfo = Text(mn, 10, C.pink)
        p.mInfo:SetPoint("BOTTOMLEFT", 14, 50)
        local save = Btn(mn, "Speichern", IW, 30, "primary", function()
            if not man.class then p.mInfo:SetText("Bitte zuerst eine Klasse auswählen.") return end
            local t = { role = IsParent() and "K" or "P", name = strtrim(p.mName:GetText()), class = man.class, level = 1, faction = "", profs = {}, sec = {} }
            if t.name == "" then t.name = IsParent() and "Dein Kind" or "Deine Begleitung" end
            for _, k in ipairs(KG.PROF_ORDER) do if man.profs[k] then t.profs[#t.profs + 1] = k end end
            for _, k in ipairs(KG.SEC_ORDER) do if man.sec[k] then t.sec[#t.sec + 1] = k end end
            p.mInfo:SetText("")
            KG.SetPartner(t, "manual")
        end)
        save:SetPoint("BOTTOMLEFT", 14, 14)
    end,
    paintManual = function(p)
        for _, c in ipairs(p.classTiles) do c.hover = false; c:SetSelected(p.man.class == c.key) end
        for _, c in ipairs(p.profChips) do c.hover = false; c:SetSelected(c.set[c.key]) end
    end,
    refresh = function(p)
        local t, st, man = KG.db.partner, p.st, p.man
        st.head:SetText(IsParent() and "DEIN KIND" or "DEINE BEGLEITUNG")
        if t then
            SetClassIcon(st.icon, t.class)
            st.icon:Show()
            st.name:SetText(t.name)
            st.line:SetText(ClassText(t.class) .. (t.level > 1 and (", Level " .. t.level) or ""))
            st.profs:SetText("Hauptberufe: " .. ProfList(t.profs) .. "\nNebenberufe: " .. ProfList(t.sec))
            local src = { auto = "Automatisch empfangen", code = "Per Code übernommen", manual = "Von Hand eingetragen" }
            st.src:SetText((src[t.source] or "") .. (t.time and t.time ~= "" and (" am " .. t.time) or ""))
        else
            st.icon:Hide()
            st.name:SetText("Noch niemand eingetragen")
            st.line:SetText("")
            st.profs:SetText("Nutze einen der Wege unten oder trage die Daten rechts von Hand ein.")
            st.src:SetText("")
        end
        for k in pairs(man.profs) do man.profs[k] = nil end
        for k in pairs(man.sec) do man.sec[k] = nil end
        man.class = t and t.class or nil
        for _, k in ipairs(t and t.profs or {}) do man.profs[k] = true end
        for _, k in ipairs(t and t.sec or {}) do man.sec[k] = true end
        if not p.mName:HasFocus() then p.mName:SetText(t and t.name or "") end
        pages.partner.paintManual(p)
    end,
}

---------------------------------------------------------------------------
-- Seite: Spielstil-Fragen
---------------------------------------------------------------------------

pages.quiz = {
    title = function() return "Mein Spielstil" end,
    sub = function() return "Acht kurze Fragen. Klicke einfach an, was am besten zu dir passt." end,
    build = function(p)
        p.view = QuizView(p, KG.QUIZ, function() return KG.db.quiz end, function()
            KG.RefreshUI()
            ShowPage("class")
        end)
    end,
    refresh = function(p) p.view:Start(KG.QuizDone(KG.QUIZ, KG.db.quiz)) end,
}

---------------------------------------------------------------------------
-- Seite: Klasse
---------------------------------------------------------------------------

local function ClassCard(parent)
    local c = Card(parent, true)
    c:SetSize((BODY_W - 34) / 3, 448)
    local IW = (BODY_W - 34) / 3 - 28
    c.stripe = c:CreateTexture(nil, "ARTWORK")
    c.stripe:SetPoint("TOPLEFT", 1, -1)
    c.stripe:SetPoint("TOPRIGHT", -1, -1)
    c.stripe:SetHeight(4)
    c.rank = Text(c, 11, C.dim)
    c.rank:SetPoint("TOPLEFT", 12, -14)
    c.tag = Text(c, 10, C.sun)
    c.tag:SetPoint("TOPRIGHT", -12, -14)
    c.icon = c:CreateTexture(nil, "ARTWORK")
    c.icon:SetSize(54, 54)
    c.icon:SetPoint("TOP", 0, -20)
    c.name = Text(c, 17, C.text)
    c.name:SetPoint("TOP", 0, -82)
    c.name:SetWidth(IW)
    c.name:SetJustifyH("CENTER")
    c.bar = Bar(c, IW, 6)
    c.bar:SetPoint("TOP", 0, -110)
    c.pct = Text(c, 10, C.dim)
    c.pct:SetPoint("TOP", 0, -121)
    c.pct:SetWidth(IW)
    c.pct:SetJustifyH("CENTER")
    c.ease = Text(c, 11, C.mint)
    c.ease:SetPoint("TOPLEFT", 14, -144)
    c.ease:SetWidth(IW)
    c.short = Text(c, 11, C.text)
    c.short:SetPoint("TOPLEFT", c.ease, "BOTTOMLEFT", 0, -6)
    c.short:SetWidth(IW)
    c.good = Text(c, 10.5, C.sun)
    c.good:SetPoint("TOPLEFT", c.short, "BOTTOMLEFT", 0, -8)
    c.good:SetWidth(IW)
    c.warn = Text(c, 10.5, C.pink)
    c.warn:SetPoint("TOPLEFT", c.good, "BOTTOMLEFT", 0, -6)
    c.warn:SetWidth(IW)
    c.pick = Btn(c, "", IW, 28, "primary", function(self)
        KG.db.chosenClass = self:GetParent().class
        KG.RefreshUI()
    end)
    c.pick:SetPoint("BOTTOM", 0, 12)
    Tooltip(c, function(self)
        local K = KG.CLASSES[self.class]
        if not K then return end
        local r, g, b = KG.ClassColor(self.class)
        GameTooltip:SetText(KG.ClassName(self.class), r, g, b)
        GameTooltip:AddLine("Stärken", C.mint[1], C.mint[2], C.mint[3])
        for _, s in ipairs(K.pros) do GameTooltip:AddLine("+ " .. s, 1, 1, 1, true) end
        GameTooltip:AddLine("Darauf musst du achten", C.pink[1], C.pink[2], C.pink[3])
        for _, s in ipairs(K.cons) do GameTooltip:AddLine("- " .. s, 1, 1, 1, true) end
        GameTooltip:AddLine("Rüstung: " .. KG.ARMOR_NAMES[K.armor], C.dim[1], C.dim[2], C.dim[3])
    end)
    return c
end

pages.class = {
    title = function() return IsParent() and "Passende Klasse" or "Meine Klasse" end,
    sub = function()
        return IsParent() and "Welche Klasse ergänzt dein Kind am besten? Fahre mit der Maus über eine Karte für Stärken und Schwächen."
            or "So gut passen die Klassen zu deinen Antworten. Fahre mit der Maus über eine Karte für mehr Infos."
    end,
    build = function(p)
        p.offset = 0
        p.emptyQuiz = EmptyState(p, "Beantworte zuerst die Fragen zu deinem Spielstil. Danach siehst du hier, welche Klassen am besten zu dir passen.", "Zu den Fragen", function() ShowPage("quiz") end)
        p.emptyKid = EmptyState(p, "Trage zuerst ein, welche Klasse dein Kind spielt. Danach siehst du hier, welche Klasse bei dir am besten dazu passt.", "Mein Kind eintragen", function() ShowPage("partner") end)

        p.res = CreateFrame("Frame", nil, p)
        p.res:SetAllPoints()
        p.intro = Text(p.res, 12, C.text)
        p.intro:SetPoint("TOPLEFT", 0, 0)
        p.intro:SetWidth(BODY_W)
        p.cards = {}
        for i = 1, 3 do
            local c = ClassCard(p.res)
            c:SetPoint("TOPLEFT", (i - 1) * ((BODY_W - 34) / 3 + 17), -36)
            p.cards[i] = c
        end
        p.prev = Btn(p.res, "<", 34, 28, "ghost", function() p.offset = math.max(0, p.offset - 3); pages.class.refresh(p) end)
        p.prev:SetPoint("BOTTOMLEFT", 0, 0)
        p.pager = Text(p.res, 11, C.dim)
        p.pager:SetPoint("LEFT", p.prev, "RIGHT", 10, 0)
        p.next = Btn(p.res, ">", 34, 28, "ghost", function() p.offset = math.min(6, p.offset + 3); pages.class.refresh(p) end)
        p.next:SetPoint("LEFT", p.prev, "RIGHT", 120, 0)
        p.again = Btn(p.res, "Fragen neu beantworten", 190, 28, "ghost", function()
            KG.db.quiz = {}
            KG.RefreshUI()
            ShowPage("quiz")
        end)
        p.again:SetPoint("BOTTOMRIGHT", 0, 0)
        p.toProfs = Btn(p.res, "Weiter zu den Berufen", 190, 28, "primary", function() ShowPage("profs") end)
        p.toProfs:SetPoint("RIGHT", p.again, "LEFT", -8, 0)
    end,
    refresh = function(p)
        local db, parent = KG.db, IsParent()
        local rows
        if parent then
            if db.partner then rows = KG.ScoreForKid(db.partner) end
        elseif KG.QuizDone(KG.QUIZ, db.quiz) then
            rows = KG.ScoreClasses(db.quiz, db.partner)
        end
        p.emptyQuiz:SetShown(not rows and not parent)
        p.emptyKid:SetShown(not rows and parent)
        p.res:SetShown(rows ~= nil)
        if not rows then return end

        local mine = KG.MyClass()
        if parent then
            local place = 0
            for i, r in ipairs(rows) do if r.class == mine then place = i end end
            p.intro:SetText(("%s spielt %s. Dein Charakter ist %s und liegt auf Platz %d von %d."):format(db.partner.name, ClassText(db.partner.class), ClassText(mine), place, #rows))
        elseif db.partner then
            p.intro:SetText(("Abgestimmt auf %s (%s)."):format(db.partner.name, ClassText(db.partner.class)))
        else
            p.intro:SetText("Noch keine Begleitung eingetragen. Mit ihr werden die Empfehlungen genauer.")
        end

        for i, c in ipairs(p.cards) do
            local r = rows[p.offset + i]
            c:SetShown(r ~= nil)
            if r then
                local K = KG.CLASSES[r.class]
                local cr, cg, cb = KG.ClassColor(r.class)
                c.class = r.class
                c.stripe:SetColorTexture(cr, cg, cb, 1)
                c.rank:SetText("Platz " .. (p.offset + i))
                SetClassIcon(c.icon, r.class)
                c.name:SetText(KG.ClassName(r.class))
                c.name:SetTextColor(cr, cg, cb)
                c.bar:Set(r.pct, cr, cg, cb)
                c.pct:SetText(r.pct .. " % Übereinstimmung")
                c.ease:SetText((parent and "Schwierigkeit: " or "Für Einsteiger: ") .. KG.EASE_NAMES[K.ease])
                c.short:SetText(K.short)

                local lines = {}
                if #r.good > 0 then
                    lines[1] = "Passt, weil " .. r.good[1] .. (r.good[2] and (" und " .. r.good[2]:gsub("^du ", "")) or "") .. "."
                end
                for j = 1, math.min(#r.duo, parent and 3 or 2) do lines[#lines + 1] = "+ " .. r.duo[j] end
                c.good:SetText(table.concat(lines, "\n"))
                c.warn:SetText(r.warn[1] and ("! " .. r.warn[1]) or "")

                local chosen = db.chosenClass == r.class
                c.tag:SetText(chosen and "Gewählt" or (r.class == mine and "Dein Charakter" or ""))
                c.pick:SetLabel(chosen and "Gewählt" or (parent and "Das spiele ich" or "Diese Klasse wählen"))
                c.hover = false
                c:SetSelected(chosen)
            end
        end
        p.pager:SetText(("%d bis %d von %d"):format(p.offset + 1, math.min(p.offset + 3, #rows), #rows))
        p.prev:SetEnabled(p.offset > 0)
        p.next:SetEnabled(p.offset + 3 < #rows)
        p.again:SetShown(not parent)
    end,
}

---------------------------------------------------------------------------
-- Seite: Berufe
---------------------------------------------------------------------------

local PARENT_PROF_ANSWERS = { style = "both", goal = "help", effort = "mid" }

local function ProfRow(parent)
    local c = Card(parent, true)
    c:SetSize(BODY_W, 98)
    c.i1 = Icon(c, 34)
    c.i1:SetPoint("TOPLEFT", 14, -14)
    c.i2 = Icon(c, 34)
    c.i2:SetPoint("LEFT", c.i1, "RIGHT", 6, 0)
    c.bar = Bar(c, 74, 5)
    c.bar:SetPoint("TOPLEFT", 14, -58)
    c.fit = Text(c, 10, C.dim)
    c.fit:SetPoint("TOPLEFT", 14, -68)
    c.name = Text(c, 15, C.text)
    c.name:SetPoint("TOPLEFT", 106, -12)
    c.good = Text(c, 11, C.mint)
    c.good:SetPoint("TOPLEFT", 106, -34)
    c.good:SetWidth(BODY_W - 106 - 130)
    c.warn = Text(c, 11, C.pink)
    c.warn:SetPoint("TOPLEFT", c.good, "BOTTOMLEFT", 0, -3)
    c.warn:SetWidth(BODY_W - 106 - 130)
    c.pick = Btn(c, "", 104, 28, "primary", function(self)
        local r = self:GetParent()
        KG.db.chosenProfs = { r.a, r.b }
        KG.RefreshUI()
    end)
    c.pick:SetPoint("RIGHT", -14, 0)
    Tooltip(c, function(self)
        if not self.a then return end
        for _, k in ipairs({ self.a, self.b }) do
            GameTooltip:AddLine(KG.PROFS[k].name, C.sun[1], C.sun[2], C.sun[3])
            GameTooltip:AddLine(KG.PROFS[k].desc, 1, 1, 1, true)
        end
    end)
    return c
end

pages.profs = {
    title = function() return IsParent() and "Passende Berufe" or "Meine Berufe" end,
    sub = function()
        return IsParent() and "Diese Berufe ergänzen dein Kind am besten: Material liefern, nichts doppelt lernen."
            or "Du kannst zwei Hauptberufe lernen. Hier siehst du, welche sich für dich lohnen."
    end,
    build = function(p)
        p.offset = 0
        p.view = QuizView(p, KG.PROF_QUIZ, function() return KG.db.profQuiz end, function() KG.RefreshUI() end)

        p.res = CreateFrame("Frame", nil, p)
        p.res:SetAllPoints()
        p.intro = Text(p.res, 12, C.text)
        p.intro:SetPoint("TOPLEFT", 0, 0)
        p.intro:SetWidth(BODY_W)
        p.rows = {}
        for i = 1, 3 do
            local r = ProfRow(p.res)
            r:SetPoint("TOPLEFT", 0, -44 - (i - 1) * 106)
            p.rows[i] = r
        end
        p.secHead = Text(p.res, 12, C.sun)
        p.secHead:SetPoint("TOPLEFT", 0, -368)
        p.secHead:SetText("Nebenberufe (kannst du alle zusätzlich lernen)")
        p.sec = {}
        for i = 1, 3 do
            local ic = Icon(p.res, 20)
            ic:SetPoint("TOPLEFT", 0, -390 - (i - 1) * 26)
            local t = Text(p.res, 11, C.text)
            t:SetPoint("LEFT", ic, "RIGHT", 8, 0)
            t:SetWidth(BODY_W - 30)
            p.sec[i] = { icon = ic, text = t }
        end
        p.prev = Btn(p.res, "<", 34, 28, "ghost", function() p.offset = math.max(0, p.offset - 3); pages.profs.refresh(p) end)
        p.prev:SetPoint("BOTTOMLEFT", 0, 0)
        p.pager = Text(p.res, 11, C.dim)
        p.pager:SetPoint("LEFT", p.prev, "RIGHT", 10, 0)
        p.next = Btn(p.res, ">", 34, 28, "ghost", function() p.offset = math.min(6, p.offset + 3); pages.profs.refresh(p) end)
        p.next:SetPoint("LEFT", p.prev, "RIGHT", 130, 0)
        p.again = Btn(p.res, "Fragen neu beantworten", 190, 28, "ghost", function()
            KG.db.profQuiz = {}
            KG.RefreshUI()
        end)
        p.again:SetPoint("BOTTOMRIGHT", 0, 0)
        p.toPlan = Btn(p.res, IsParent() and "Weiter: So hilfst du" or "Weiter zu meinem Plan", 190, 28, "primary", function() ShowPage("plan") end)
        p.toPlan:SetPoint("RIGHT", p.again, "LEFT", -8, 0)
    end,
    refresh = function(p)
        local db, parent = KG.db, IsParent()
        local done = parent or KG.QuizDone(KG.PROF_QUIZ, db.profQuiz)
        p.view:SetShown(not done)
        p.res:SetShown(done)
        if not done then p.view:Start() return end

        local cls = KG.EffectiveClass()
        local list = KG.ScoreProfs(parent and PARENT_PROF_ANSWERS or db.profQuiz, cls, db.partner)
        local learned = KG.DetectProfs()
        local intro = "Empfehlung für " .. ClassText(cls) .. "."
        if db.partner then
            intro = intro .. " " .. db.partner.name .. " hat: " .. ProfList(db.partner.profs) .. "."
        else
            intro = intro .. " Noch " .. (parent and "kein Kind" or "keine Begleitung") .. " eingetragen, deshalb ohne Abstimmung."
        end
        if #learned > 0 then intro = intro .. " Du hast schon gelernt: " .. ProfList(learned) .. "." end
        p.intro:SetText(intro)

        for i, c in ipairs(p.rows) do
            local r = list[p.offset + i]
            c:SetShown(r ~= nil)
            if r then
                c.a, c.b = r.a, r.b
                SetProfIcon(c.i1, r.a)
                SetProfIcon(c.i2, r.b)
                c.name:SetText(KG.PROFS[r.a].name .. " + " .. KG.PROFS[r.b].name)
                c.bar:Set(r.pct, C.mint[1], C.mint[2], C.mint[3])
                c.fit:SetText(r.pct >= 85 and "passt sehr gut" or (r.pct >= 60 and "passt gut" or "geht auch"))
                local good = {}
                for j = 1, math.min(2, #r.good) do good[j] = "+ " .. r.good[j] end
                c.good:SetText(table.concat(good, "\n"))
                c.warn:SetText(r.warn[1] and ("! " .. r.warn[1]) or "")
                local ch = db.chosenProfs
                local chosen = ch and ((ch[1] == r.a and ch[2] == r.b) or (ch[1] == r.b and ch[2] == r.a))
                c.pick:SetLabel(chosen and "Gewählt" or "Wählen")
                c.hover = false
                c:SetSelected(chosen)
            end
        end
        for i, s in ipairs(KG.SecondaryAdvice(cls, db.partner)) do
            SetProfIcon(p.sec[i].icon, s.key)
            p.sec[i].text:SetText(Colored(KG.PROFS[s.key].name .. ": ", C.sun) .. s.text)
        end
        p.pager:SetText(("%d bis %d"):format(p.offset + 1, p.offset + 3))
        p.prev:SetEnabled(p.offset > 0)
        p.next:SetEnabled(p.offset < 6)
        p.again:SetShown(not parent)
        p.toPlan:SetLabel(parent and "Weiter: So hilfst du" or "Weiter zu meinem Plan")
    end,
}

---------------------------------------------------------------------------
-- Seite: Skillung (Eltern planen, Kind bekommt den nächsten Punkt angezeigt)
---------------------------------------------------------------------------

local TREE_H = 380

local function TalentView(parent)
    local v = CreateFrame("Frame", nil, parent)
    v:SetSize(BODY_W, TREE_H)
    v.heads, v.btns = {}, {}

    local function button(tab, i)
        v.btns[tab] = v.btns[tab] or {}
        local b = v.btns[tab][i]
        if b then return b end
        b = CreateFrame("Button", nil, v, "BackdropTemplate")
        Flat(b, C.field)
        b.icon = b:CreateTexture(nil, "ARTWORK")
        b.icon:SetPoint("TOPLEFT", 2, -2)
        b.icon:SetPoint("BOTTOMRIGHT", -2, 2)
        b.icon:SetTexCoord(0.08, 0.92, 0.08, 0.92)
        b.rank = Text(b, 9, C.text, "OUTLINE")
        b.rank:SetPoint("BOTTOMRIGHT", -1, 2)
        b:RegisterForClicks("LeftButtonUp", "RightButtonUp")
        b.tab, b.idx = tab, i
        Reg(b, "btn")
        Tooltip(b, function(self)
            if self.live and GameTooltip.SetTalent then GameTooltip:SetTalent(self.tab, self.idx)
            else GameTooltip:SetText(self.tal.name, 1, 1, 1) end
            GameTooltip:AddLine(("Im Plan: %d von %d"):format(self.plan, self.tal.max), C.sun[1], C.sun[2], C.sun[3])
            if self.kid then GameTooltip:AddLine("Gelernt: " .. self.cur, C.mint[1], C.mint[2], C.mint[3]) end
        end)
        v.btns[tab][i] = b
        return b
    end

    -- st: planned, nextPick, kid, live, onClick(tab, idx, mouseButton, talent)
    function v:Render(tree, st)
        local ntab = #tree.tabs
        local colW = (BODY_W - (ntab - 1) * 12) / ntab
        local maxTier, maxCol = 1, 1
        for _, t in ipairs(tree.tabs) do
            for _, tal in ipairs(t.talents) do
                maxTier, maxCol = math.max(maxTier, tal.tier), math.max(maxCol, tal.col)
            end
        end
        local cell = math.max(20, math.min(42, math.floor((TREE_H - 24) / maxTier), math.floor(colW / maxCol)))
        for tab = 1, math.max(ntab, #self.heads) do
            local t = tree.tabs[tab]
            local head = self.heads[tab]
            if t and not head then
                head = Text(self, 12, C.sun)
                self.heads[tab] = head
            end
            local x0 = (tab - 1) * (colW + 12)
            local spent = 0
            for i, tal in ipairs(t and t.talents or {}) do
                local b = button(tab, i)
                b:SetSize(cell - 4, cell - 4)
                b:ClearAllPoints()
                b:SetPoint("TOPLEFT", x0 + (colW - maxCol * cell) / 2 + (tal.col - 1) * cell + 2, -(22 + (tal.tier - 1) * cell))
                b.icon:SetTexture(tal.icon or "Interface\\Icons\\INV_Misc_QuestionMark")
                local plan = st.planned[tab * 100 + i] or 0
                local cur = (st.kid and st.live) and KG.TalentRank(tab, i) or 0
                local isNext = st.nextPick and st.nextPick.tab == tab and st.nextPick.idx == i
                spent = spent + plan
                if st.kid then b.rank:SetText(plan > 0 and (cur .. "/" .. plan) or (cur > 0 and tostring(cur) or ""))
                else b.rank:SetText(plan > 0 and (plan .. "/" .. tal.max) or "") end
                b.rank:SetTextColor(unpack((st.kid and plan > 0 and cur >= plan) and C.mint or C.text))
                b:SetBackdropBorderColor(unpack(isNext and C.mint or (plan > 0 and C.sun or C.edge)))
                local idle = plan == 0 and cur == 0
                b.icon:SetDesaturated(idle)
                b.icon:SetAlpha(idle and 0.45 or 1)
                b.tal, b.plan, b.cur, b.live, b.kid = tal, plan, cur, st.live, st.kid
                if st.onClick then b:SetScript("OnClick", function(_, btn) st.onClick(tab, i, btn, tal) end)
                else b:SetScript("OnClick", nil) end
                b:Show()
            end
            for i, b in ipairs(self.btns[tab] or {}) do
                if not t or i > #t.talents then b:Hide() end
            end
            if head then
                head:SetShown(t ~= nil)
                if t then
                    head:ClearAllPoints()
                    head:SetPoint("TOPLEFT", x0, 0)
                    head:SetWidth(colW)
                    head:SetText(t.name .. "  " .. Colored(spent .. (spent == 1 and " Punkt" or " Punkte"), C.dim))
                end
            end
        end
    end
    return v
end

local function TalentClass()
    if IsParent() then return KG.db.partner and KG.db.partner.class end
    return KG.MyClass()
end

pages.talents = {
    title = function() return IsParent() and "Skillung planen" or "Meine Skillung" end,
    sub = function()
        return IsParent() and "Klicke die Talente in der Reihenfolge an, in der dein Kind sie lernen soll. Dann schickst du die Skillung rüber."
            or "Deine Begleitung gibt dir vor, welche Talente du lernst. Hier siehst du immer den nächsten Punkt."
    end,
    build = function(p)
        p.emptyKid = EmptyState(p, "Trage zuerst ein, welche Klasse dein Kind spielt. Danach kannst du hier die Skillung planen.", "Mein Kind eintragen", function() ShowPage("partner") end)
        p.noTree = EmptyState(p, "", "", function()
            if IsParent() then KG.RequestTree() else KG.TalentDump() end
        end)
        p.noTree:SetSize(BODY_W, 190)

        p.main = CreateFrame("Frame", nil, p)
        p.main:SetAllPoints()
        local ban = Card(p.main, false)
        ban:SetSize(BODY_W, 62)
        ban:SetPoint("TOPLEFT", 0, 0)
        p.msg = Text(ban, 12, C.text)
        p.msg:SetPoint("TOPLEFT", 14, -10)
        p.msg:SetWidth(BODY_W - 300)
        p.act2 = Btn(ban, "Leeren", 80, 28, "ghost", function()
            if not p.cls then return end
            KG.db.builds[p.cls] = nil
            KG.RefreshUI()
        end)
        p.act2:SetPoint("RIGHT", -12, 0)
        p.act1 = Btn(ban, "", 170, 28, "primary", function()
            if not p.cls then return end
            if IsParent() then
                local picks = KG.ParsePicks((KG.db.builds[p.cls] or {}).picks or "")
                table.remove(picks)
                if #picks > 0 then KG.SetBuild(p.cls, picks) else KG.db.builds[p.cls] = nil end
                KG.RefreshUI()
            elseif p.nextPick and LearnTalent then
                pcall(LearnTalent, p.nextPick.tab, p.nextPick.idx)
                if C_Timer and C_Timer.After then C_Timer.After(0.6, function() KG.RefreshUI() end) else KG.RefreshUI() end
            end
        end)
        p.act1:SetPoint("RIGHT", p.act2, "LEFT", -8, 0)

        p.view = TalentView(p.main)
        p.view:SetPoint("TOPLEFT", 0, -74)

        p.b1 = Btn(p.main, "", 210, 30, "primary", function()
            if IsParent() then KG.SendBuild(p.cls) else KG.RequestBuild() end
        end)
        p.b1:SetPoint("BOTTOMLEFT", 0, 0)
        p.code = Edit(p.main, BODY_W - 210 - 170 - 16)
        p.code:SetPoint("LEFT", p.b1, "RIGHT", 8, 0)
        p.code:SetMaxLetters(0)
        p.b2 = Btn(p.main, "", 170, 30, "ghost", function()
            if IsParent() then
                p.code:SetText(KG.EncodeBuild(p.cls) or "")
                p.code:SetFocus()
                p.code:HighlightText()
                p.info:SetText("Markiert: Strg+C kopiert den Code. Dein Kind fügt ihn auf seiner Skillungs-Seite ein.")
            else
                local class, build = KG.DecodeBuild(p.code:GetText())
                if not class then p.info:SetText(Colored(build, C.pink)) return end
                KG.db.builds[class] = build
                p.code:SetText("")
                KG.RefreshUI()
                if class ~= KG.MyClass() then
                    p.info:SetText(Colored("Diese Skillung ist für " .. KG.ClassName(class) .. ", dein Charakter ist " .. KG.ClassName(KG.MyClass()) .. ". Sie wird angezeigt, sobald du diese Klasse spielst.", C.pink))
                end
            end
        end)
        p.b2:SetPoint("LEFT", p.code, "RIGHT", 8, 0)
        p.info = Text(p.main, 10, C.dim)
        p.info:SetPoint("BOTTOMLEFT", 0, 36)
        p.info:SetWidth(BODY_W)
    end,
    refresh = function(p)
        local db, parent = KG.db, IsParent()
        local cls = TalentClass()
        p.cls = cls
        p.emptyKid:Hide()
        p.noTree:Hide()
        p.main:Hide()
        if not cls then p.emptyKid:Show() return end

        local tree, live = KG.TreeFor(cls)
        if not tree then
            if parent then
                p.noTree.text:SetText(("Die Talentbäume für %s liegen hier noch nicht vor. Seid ihr in einer Gruppe und hat %s das Addon, schickt es dir die Bäume auf Knopfdruck. Alternativ öffnest du diese Seite auf einem eigenen Charakter derselben Klasse."):format(KG.ClassName(cls), db.partner.name))
                p.noTree.btn:SetLabel("Talentbäume anfragen")
            else
                p.noTree.text:SetText("Die Talentbäume konnten nicht aus dem Spiel gelesen werden. Starte die Diagnose und gib die Datei an deine Begleitung weiter. Der Pfad steht danach im Chat.")
                p.noTree.btn:SetLabel("Diagnose starten")
            end
            p.noTree:Show()
            return
        end
        p.main:Show()

        local build = db.builds[cls]
        local picks = KG.ParsePicks(build and build.picks or "")
        local planned, nextPick = KG.BuildProgress(picks, (not parent and live) and KG.TalentRank or nil)
        p.nextPick = nextPick
        p.info:SetText("")

        if parent then
            local last = picks[#picks]
            local lastTal = last and tree.tabs[last.tab] and tree.tabs[last.tab].talents[last.idx]
            p.msg:SetText(("Skillung für %s (%s): %d Punkte verplant.%s\nLinksklick setzt einen Punkt, Rechtsklick nimmt ihn zurück."):format(
                db.partner.name, ClassText(cls), #picks, lastTal and (" Zuletzt: " .. lastTal.name .. ".") or ""))
            p.act1:SetLabel("Letzten Punkt zurück")
            p.act1:SetShown(#picks > 0)
            p.act2:SetShown(#picks > 0)
            p.b1:SetLabel("An mein Kind senden")
            p.b2:SetLabel("Code zeigen")
        else
            local free = KG.UnspentPoints()
            local tal = nextPick and tree.tabs[nextPick.tab] and tree.tabs[nextPick.tab].talents[nextPick.idx]
            if not build then
                p.msg:SetText("Noch keine Skillung erhalten. Bitte deine Begleitung, sie dir zu schicken, oder frage sie unten an.")
            elseif tal then
                p.msg:SetText((free > 0 and ("Du hast " .. Colored(free .. (free == 1 and " freien Punkt" or " freie Punkte"), C.mint) .. ". ") or "")
                    .. "Nächster Punkt: " .. Colored(tal.name, C.sun) .. " im Baum " .. tree.tabs[nextPick.tab].name
                    .. ".\nSkillung von " .. (build.author or "?") .. (build.time ~= "" and (", " .. build.time) or "") .. ". Das grün umrandete Talent ist als nächstes dran.")
            elseif nextPick then
                p.msg:SetText(Colored("Die Skillung passt nicht mehr zu deinen Talentbäumen, zum Beispiel nach einem Patch.", C.pink) .. "\nBitte deine Begleitung um eine neue Skillung.")
            else
                p.msg:SetText("Alle geplanten Punkte sind gesetzt. Gut gemacht!\nSkillung von " .. (build.author or "?") .. ".")
            end
            p.act1:SetLabel("Diesen Punkt lernen")
            p.act1:SetShown(tal ~= nil and free > 0 and live and LearnTalent ~= nil)
            p.act2:Hide()
            p.b1:SetLabel("Skillung anfragen")
            p.b2:SetLabel("Code übernehmen")
        end

        p.view:Render(tree, {
            planned = planned, nextPick = nextPick, kid = not parent, live = live,
            onClick = parent and function(tab, idx, btn, tal)
                local list = KG.ParsePicks((db.builds[cls] or {}).picks or "")
                if btn == "RightButton" then
                    for n = #list, 1, -1 do
                        if list[n].tab == tab and list[n].idx == idx then table.remove(list, n) break end
                    end
                else
                    local c = 0
                    for _, q in ipairs(list) do if q.tab == tab and q.idx == idx then c = c + 1 end end
                    if c < tal.max and #list < 200 then list[#list + 1] = { tab = tab, idx = idx } end
                end
                if #list > 0 then KG.SetBuild(cls, list) else db.builds[cls] = nil end
                KG.RefreshUI()
            end or nil,
        })
    end,
}

---------------------------------------------------------------------------
-- Seite: Mein Plan / So hilfst du
---------------------------------------------------------------------------

local PARENT_TIPS = {
    "Lass dein Kind selbst spielen und auch mal Fehler machen",
    "Erkläre immer nur eine Sache auf einmal",
    "Schenke Taschen: mehr Platz ist für Einsteiger Gold wert",
    "Levelt gemeinsam: gleiche Quests, gleiches Tempo, niemand rennt vor",
    "Zeige, wo der Klassenlehrer steht, und erinnere alle zwei Level daran",
}

pages.plan = {
    title = function() return IsParent() and "So hilfst du" or "Mein Plan" end,
    sub = function()
        return IsParent() and "Alles auf einen Blick, dazu Tipps passend zur Klasse deines Kindes."
            or "Deine Auswahl auf einen Blick und die ersten Schritte. Hake ab, was du schon kannst."
    end,
    build = function(p)
        local tw = (BODY_W - 24) / 3
        p.tiles = {}
        for i = 1, 3 do
            local c = Card(p, true)
            c:SetSize(tw, 96)
            c:SetPoint("TOPLEFT", (i - 1) * (tw + 12), 0)
            c.head = Text(c, 10, C.dim)
            c.head:SetPoint("TOPLEFT", 12, -10)
            c.icon = c:CreateTexture(nil, "ARTWORK")
            c.icon:SetSize(36, 36)
            c.icon:SetPoint("TOPLEFT", 12, -30)
            c.icon2 = c:CreateTexture(nil, "ARTWORK")
            c.icon2:SetSize(36, 36)
            c.icon2:SetPoint("LEFT", c.icon, "RIGHT", 4, 0)
            c.main = Text(c, 13, C.text)
            c.main:SetWidth(tw - 24)
            c.subt = Text(c, 10, C.dim)
            c.subt:SetPoint("BOTTOMLEFT", 12, 8)
            c.subt:SetWidth(tw - 24)
            p.tiles[i] = c
        end
        p.tiles[1]:SetScript("OnClick", function() ShowPage("class") end)
        p.tiles[2]:SetScript("OnClick", function() ShowPage("profs") end)
        p.tiles[3]:SetScript("OnClick", function() ShowPage("partner") end)

        p.listHead = Text(p, 12, C.sun)
        p.listHead:SetPoint("TOPLEFT", 0, -112)
        p.items = {}
        for i = 1, 11 do
            local row = CreateFrame("Frame", nil, p)
            row:SetSize(BODY_W, 28)
            row:SetPoint("TOPLEFT", 0, -132 - (i - 1) * 30)
            row.check = Check(row, function(self, v)
                if not row.key then return end
                KG.db.todo[row.key] = v or nil
                row.text:SetTextColor(unpack(v and C.dim or C.text))
            end)
            row.check:SetPoint("LEFT", 0, 0)
            row.text = Text(row, 12, C.text)
            row.text:SetPoint("LEFT", 28, 0)
            row.text:SetWidth(BODY_W - 34)
            row.text:SetJustifyV("MIDDLE")
            p.items[i] = row
        end
        p.send = Btn(p, "", 260, 30, "primary", function() KG.SendToGroup() end)
        p.send:SetPoint("BOTTOMLEFT", 0, 0)
        p.note = Text(p, 10, C.dim)
        p.note:SetPoint("LEFT", p.send, "RIGHT", 12, 0)
        p.note:SetWidth(BODY_W - 280)
    end,
    refresh = function(p)
        local db, parent = KG.db, IsParent()
        local t1, t2, t3 = p.tiles[1], p.tiles[2], p.tiles[3]
        local function place(c, two) c.main:ClearAllPoints(); c.main:SetPoint("TOPLEFT", two and 96 or 56, -32) end

        -- Kachel 1: Klasse
        local cls = db.chosenClass
        t1.head:SetText(parent and "DEINE KLASSE" or "MEINE KLASSE")
        t1.icon2:Hide()
        SetClassIcon(t1.icon, cls or KG.MyClass())
        place(t1)
        t1.main:SetText(ClassText(cls or KG.MyClass()))
        if cls and cls ~= KG.MyClass() then
            t1.subt:SetText("Dein Charakter ist " .. KG.ClassName(KG.MyClass()) .. ". Erstelle einen neuen, die Auswahl bleibt gespeichert.")
        else
            t1.subt:SetText(cls and "Gewählt" or "Noch nicht gewählt: das ist dein aktueller Charakter")
        end

        -- Kachel 2: Berufe
        t2.head:SetText(parent and "DEINE BERUFE" or "MEINE BERUFE")
        local pr = db.chosenProfs or (KG.DetectProfs())
        if pr and pr[1] then
            SetProfIcon(t2.icon, pr[1])
            t2.icon:Show()
            t2.icon2:SetShown(pr[2] ~= nil)
            if pr[2] then SetProfIcon(t2.icon2, pr[2]) end
            place(t2, pr[2] ~= nil)
            t2.main:SetText(KG.PROFS[pr[1]].name .. (pr[2] and ("\n" .. KG.PROFS[pr[2]].name) or ""))
            t2.subt:SetText(db.chosenProfs and "Gewählt. Lernen kannst du sie bei Berufslehrern in den Städten." or "Bereits gelernt")
        else
            t2.icon:Hide()
            t2.icon2:Hide()
            t2.main:ClearAllPoints()
            t2.main:SetPoint("TOPLEFT", 12, -32)
            t2.main:SetText("Noch nicht gewählt")
            t2.subt:SetText("Klicke hier für die Empfehlung")
        end

        -- Kachel 3: Begleitung
        local pt = db.partner
        t3.head:SetText(parent and "DEIN KIND" or "MEINE BEGLEITUNG")
        t3.icon2:Hide()
        if pt then
            SetClassIcon(t3.icon, pt.class)
            t3.icon:Show()
            place(t3)
            t3.main:SetText(pt.name .. "\n" .. ClassText(pt.class))
            t3.subt:SetText("Berufe: " .. ProfList(pt.profs))
        else
            t3.icon:Hide()
            t3.main:ClearAllPoints()
            t3.main:SetPoint("TOPLEFT", 12, -32)
            t3.main:SetText("Noch niemand eingetragen")
            t3.subt:SetText("Klicke hier zum Eintragen")
        end

        -- Liste
        local list = {}
        if parent then
            local K = pt and KG.CLASSES[pt.class]
            p.listHead:SetText(K and ("So hilfst du " .. pt.name .. " (" .. KG.ClassName(pt.class) .. ")") or "So hilfst du")
            for _, s in ipairs(K and K.help or {}) do list[#list + 1] = s end
            for _, s in ipairs(PARENT_TIPS) do list[#list + 1] = s end
        else
            local K = KG.CLASSES[cls or KG.MyClass()]
            p.listHead:SetText("Deine ersten Schritte")
            for _, s in ipairs(KG.FIRST_STEPS) do list[#list + 1] = s end
            for _, s in ipairs(K and K.first or {}) do list[#list + 1] = s end
        end
        for i, row in ipairs(p.items) do
            local s = list[i]
            row:SetShown(s ~= nil)
            if s then
                row.key = s
                local done = db.todo[s] and true or false
                row.check:SetChecked(done)
                row.text:SetText(s)
                row.text:SetTextColor(unpack(done and C.dim or C.text))
            end
        end
        p.send:SetLabel(parent and "Mein Profil an mein Kind schicken" or "Meine Auswahl an meine Begleitung schicken")
        p.note:SetText("Funktioniert, wenn ihr in einer Gruppe seid und beide das Addon habt. Sonst hilft der Code unter \"" .. (parent and "Mein Kind" or "Meine Begleitung") .. "\".")
    end,
}

---------------------------------------------------------------------------
-- Hauptfenster und Navigation
---------------------------------------------------------------------------

local STEPS = {
    { key = "welcome", kid = "Willkommen", parent = "Willkommen" },
    { key = "partner", kid = "Meine Begleitung", parent = "Mein Kind" },
    { key = "quiz", kid = "Mein Spielstil" },
    { key = "class", kid = "Meine Klasse", parent = "Passende Klasse" },
    { key = "profs", kid = "Meine Berufe", parent = "Passende Berufe" },
    { key = "talents", kid = "Meine Skillung", parent = "Skillung planen" },
    { key = "plan", kid = "Mein Plan", parent = "So hilfst du" },
}

local function StepDone(key)
    local db = KG.db
    if key == "welcome" then return db.role ~= nil end
    if key == "partner" then return db.partner ~= nil end
    if key == "quiz" then return KG.QuizDone(KG.QUIZ, db.quiz) end
    if key == "class" then return db.chosenClass ~= nil end
    if key == "profs" then return db.chosenProfs ~= nil end
    if key == "talents" then
        local cls = TalentClass()
        return cls ~= nil and db.builds[cls] ~= nil
    end
    return false
end

local function RefreshSidebar()
    local role = KG.db.role
    local n = 0
    for _, b in ipairs(ui.steps) do
        local label = b.step[role or "kid"]
        if label then
            n = n + 1
            b:ClearAllPoints()
            b:SetPoint("TOPLEFT", 12, -118 - (n - 1) * 44)
            b.num:SetText(StepDone(b.step.key) and "ok" or tostring(n))
            b.num:SetTextColor(unpack(StepDone(b.step.key) and C.mint or C.dim))
            b.label:SetText(label)
            b:SetEnabled(role ~= nil or b.step.key == "welcome")
            b.hover = false
            b:SetSelected(current == b.step.key)
            b:Show()
        else
            b:Hide()
        end
    end
    ui.role:SetText(role == "parent" and "Rolle: Begleitung" or (role == "kid" and "Rolle: neu in WoW" or ""))
end

function ShowPage(key)
    local def = pages[key]
    if not def then return end
    if key == "quiz" and IsParent() then key, def = "class", pages.class end
    current = key
    for k, d in pairs(pages) do
        if d.frame then d.frame:SetShown(k == key) end
    end
    if not def.frame then
        def.frame = CreateFrame("Frame", nil, ui.body)
        def.frame:SetAllPoints()
        def.build(def.frame)
    end
    def.frame:Show()
    ui.title:SetText(def.title())
    ui.sub:SetText(def.sub())
    def.refresh(def.frame)
    RefreshSidebar()
    if UIFrameFadeIn then UIFrameFadeIn(def.frame, 0.2, 0, 1) end
    Nav.Fix()
end

function KG.RefreshUI()
    if not ui or not ui:IsShown() then return end
    ShowPage(current or "welcome")
end

local function CreateMain()
    local f = CreateFrame("Frame", "KindergartenFrame", UIParent, "BackdropTemplate")
    Flat(f, C.bg, { 0.02, 0.02, 0.04, 1 })
    f:SetSize(W, H)
    f:SetScale(math.max(0.6, math.min(1.6, KG.db.scale or 1)))
    f:SetPoint("CENTER")
    f:SetFrameStrata("DIALOG")
    f:SetMovable(true)
    f:SetClampedToScreen(true)
    f:EnableMouse(true)
    f:RegisterForDrag("LeftButton")
    f:SetScript("OnDragStart", f.StartMoving)
    f:SetScript("OnDragStop", f.StopMovingOrSizing)
    tinsert(UISpecialFrames, "KindergartenFrame")
    ui = f

    -- Seitenleiste
    local side = CreateFrame("Frame", nil, f, "BackdropTemplate")
    Flat(side, C.side, { 0.02, 0.02, 0.04, 1 })
    side:SetPoint("TOPLEFT", 0, 0)
    side:SetPoint("BOTTOMLEFT", 0, 0)
    side:SetWidth(SIDE)
    local logo = Icon(side, 44, "INV_Misc_Gift_01")
    logo:SetPoint("TOPLEFT", 16, -20)
    local name = Text(side, 19, C.sun)
    name:SetPoint("TOPLEFT", logo, "TOPRIGHT", 10, -3)
    name:SetText("Kindergarten")
    local tag = Text(side, 10, C.dim)
    tag:SetPoint("TOPLEFT", name, "BOTTOMLEFT", 0, -4)
    tag:SetText("Gemeinsam starten")
    local dots = { C.sun, C.mint, C.pink, C.sky }
    for i, col in ipairs(dots) do
        local d = side:CreateTexture(nil, "ARTWORK")
        d:SetSize((SIDE - 32) / 4 - 3, 3)
        d:SetPoint("TOPLEFT", 16 + (i - 1) * ((SIDE - 32) / 4), -84)
        d:SetColorTexture(col[1], col[2], col[3], 1)
    end

    f.steps = {}
    for i, step in ipairs(STEPS) do
        local b = Card(side, true)
        b:SetSize(SIDE - 24, 38)
        b.step = step
        b.num = Text(b, 12, C.dim)
        b.num:SetPoint("LEFT", 12, 0)
        b.num:SetWidth(22)
        b.num:SetJustifyH("CENTER")
        b.num:SetJustifyV("MIDDLE")
        b.label = Text(b, 13, C.text)
        b.label:SetPoint("LEFT", 42, 0)
        b.label:SetJustifyV("MIDDLE")
        b.kgSide = true
        b:SetScript("OnClick", function(self) ShowPage(self.step.key) end)
        b:SetScript("OnDisable", function(self) self:SetAlpha(0.35) end)
        b:SetScript("OnEnable", function(self) self:SetAlpha(1) end)
        f.steps[i] = b
    end
    f.role = Text(side, 10, C.dim)
    f.role:SetPoint("BOTTOMLEFT", 16, 14)
    f.padHint = Text(side, 10, C.sun)
    f.padHint:SetPoint("BOTTOMLEFT", 16, 34)
    f.padHint:SetWidth(SIDE - 32)
    f.padHint:SetText("Controller: Steuerkreuz wählt aus, A bestätigt, B schließt, LB und RB wechseln den Schritt.")
    f.padHint:Hide()

    -- Kopf und Inhalt
    f.title = Text(f, 22, C.sun)
    f.title:SetPoint("TOPLEFT", SIDE + 26, -24)
    f.sub = Text(f, 12, C.dim)
    f.sub:SetPoint("TOPLEFT", f.title, "BOTTOMLEFT", 0, -6)
    f.sub:SetWidth(BODY_W - 40)
    local close = Btn(f, "X", 28, 28, "ghost", function() f:Hide() end)
    close:SetPoint("TOPRIGHT", -14, -14)
    close.kgNoDefault = true

    -- Eingebautes Gamepad-System: verbrauchte Tasten nicht an die Spielbelegung weiterreichen
    if f.EnableGamePadButton then
        f:EnableGamePadButton(true)
        f:SetScript("OnGamePadButtonDown", function(self, button)
            local used = Nav.Handle(button)
            if self.SetPropagateKeyboardInput and not (InCombatLockdown and InCombatLockdown()) then
                self:SetPropagateKeyboardInput(not used)
            end
        end)
    end

    f.body = CreateFrame("Frame", nil, f)
    f.body:SetPoint("TOPLEFT", SIDE + 26, -96)
    f.body:SetPoint("BOTTOMRIGHT", -26, 24)

    -- Größe ändern
    local function ApplyScale(ns)
        ns = math.max(0.6, math.min(1.6, ns))
        local es, left, top = f:GetEffectiveScale(), f:GetLeft(), f:GetTop()
        f:SetScale(ns)
        if left and top then
            local nes = f:GetEffectiveScale()
            f:ClearAllPoints()
            f:SetPoint("TOPLEFT", UIParent, "BOTTOMLEFT", left * es / nes, top * es / nes)
        end
        KG.db.scale = ns
    end
    local grip = CreateFrame("Button", nil, f)
    grip:SetSize(18, 18)
    grip:SetPoint("BOTTOMRIGHT", -3, 3)
    grip:SetNormalTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Up")
    grip:SetHighlightTexture("Interface\\ChatFrame\\UI-ChatIM-SizeGrabber-Down")
    grip:SetScript("OnMouseDown", function(self, btn) if btn == "LeftButton" then self.drag = true end end)
    grip:SetScript("OnMouseUp", function(self, btn)
        self.drag = false
        if btn == "RightButton" then ApplyScale(1) end
    end)
    grip:SetScript("OnUpdate", function(self)
        if not self.drag then return end
        local cx = GetCursorPosition()
        ApplyScale((cx - f:GetLeft() * f:GetEffectiveScale()) / (W * UIParent:GetEffectiveScale()))
    end)
    Tooltip(grip, function() GameTooltip:SetText("Ziehen: Fenstergröße ändern. Rechtsklick: zurück auf 100 %.", 1, 1, 1, 1, true) end)

    f:Hide()
end

function KG.ToggleUI()
    if not KG.db then return end
    if not ui then CreateMain() end
    if ui:IsShown() then ui:Hide() return end
    KG.db.seen = true
    ui:Show()
    local start = current
    if not start then
        local db = KG.db
        if not db.role then start = "welcome"
        elseif not db.partner then start = "partner"
        elseif db.role == "kid" and not KG.QuizDone(KG.QUIZ, db.quiz) then start = "quiz"
        elseif not db.chosenClass then start = "class"
        elseif not db.chosenProfs then start = "profs"
        else start = "plan" end
    end
    ShowPage(start)
end

function KG.OpenPage(key)
    if not KG.db then return end
    if not ui then CreateMain() end
    KG.db.seen = true
    ui:Show()
    ShowPage(key)
end

-- Kleine Einblendung oben am Bildschirm, Klick öffnet die Skillungs-Seite
local toast
local toastStamp = 0
function KG.ShowToast(text)
    if not toast then
        toast = CreateFrame("Button", "KindergartenToast", UIParent, "BackdropTemplate")
        Flat(toast, C.bg, C.sun)
        toast:SetSize(460, 58)
        toast:SetPoint("TOP", 0, -140)
        toast:SetFrameStrata("HIGH")
        toast.text = Text(toast, 12, C.text)
        toast.text:SetPoint("TOPLEFT", 14, -10)
        toast.text:SetWidth(432)
        toast:SetScript("OnClick", function(self)
            self:Hide()
            KG.OpenPage("talents")
        end)
    end
    toast.text:SetText(Colored("Kindergarten: ", C.sun) .. text .. " Klicke hier oder öffne /kg.")
    toast:Show()
    toastStamp = toastStamp + 1
    local stamp = toastStamp
    if C_Timer and C_Timer.After then
        C_Timer.After(25, function() if toastStamp == stamp then toast:Hide() end end)
    end
end
