local _, KG = ...

KG.CLASS_ORDER = { "HUNTER", "WARLOCK", "MAGE", "PALADIN", "PRIEST", "DRUID", "SHAMAN", "ROGUE", "WARRIOR" }

-- ease: 3 = sehr leicht, 2 = leicht, 1 = mittel, 0 = anspruchsvoll
KG.CLASSES = {
    HUNTER = { name = "Jäger", icon = "ClassIcon_Hunter", color = { 0.67, 0.83, 0.45 }, armor = "mail", ease = 3,
        pet = true, ranged = true,
        short = "Du schießt mit Bogen oder Gewehr aus der Ferne. Ein gezähmtes Tier kämpft für dich und fängt die Gegner ab.",
        pros = { "Dein Tier hält die Gegner von dir fern", "Sehr angenehm zu leveln, auch allein", "Fast jedes Tier lässt sich zähmen und benennen" },
        cons = { "Du brauchst Munition und Futter für dein Tier", "Im Nahkampf bist du schwach" },
        first = { "Dein Tier bekommst du mit Level 10 über eine Quest beim Jägerlehrer", "Kaufe beim Händler immer genug Pfeile oder Kugeln", "Füttere dein Tier, wenn sein Gesicht gelb oder rot wird", "Halte Abstand: schießen kannst du nur aus der Ferne" },
        help = { "Erinnere ans Munition kaufen und ans Füttern des Tiers", "Lass das Tier die Gegner zuerst angreifen, bevor geschossen wird", "Hilf bei der Zähm-Quest mit Level 10 und beim Aussuchen des Tiers" } },
    WARLOCK = { name = "Hexenmeister", icon = "ClassIcon_Warlock", color = { 0.53, 0.53, 0.93 }, armor = "cloth", ease = 2,
        pet = true, ranged = true,
        short = "Du wirkst dunkle Flüche, die Gegner langsam zermürben, und beschwörst Dämonen, die für dich kämpfen.",
        pros = { "Dein Dämon fängt die Gegner ab", "Sehr zäh: du kannst Leben in Mana tauschen und Leben stehlen", "Heilsteine und Beschwörungen helfen auch deiner Begleitung" },
        cons = { "Du brauchst Seelensplitter für einige Zauber", "Etwas mehr Tasten als beim Jäger" },
        first = { "Den Wichtel bekommst du gleich am Anfang, den Leerwandler mit Level 10 über eine Quest", "Lege zuerst deine Flüche auf den Gegner, dann Schattenblitz", "Seelensplitter bekommst du, wenn du Seelendieb auf einen sterbenden Gegner wirkst", "Ist das Mana leer, hilft Aderlass" },
        help = { "Erkläre die Reihenfolge: erst Flüche, dann Schattenblitz", "Achte darauf, dass immer ein paar Seelensplitter in der Tasche sind", "Hilf bei der Leerwandler-Quest mit Level 10" } },
    MAGE = { name = "Magier", icon = "ClassIcon_Mage", color = { 0.25, 0.78, 0.92 }, armor = "cloth", ease = 2,
        ranged = true,
        short = "Du schleuderst Feuer und Eis aus der Ferne, frierst Gegner fest und zauberst Essen und Wasser herbei.",
        pros = { "Viel Schaden aus der Ferne", "Gegner einfrieren und wegteleportieren", "Zaubert Essen, Wasser und später Portale für euch beide" },
        cons = { "Hält wenig aus, wenn Gegner herankommen", "Muss oft trinken" },
        first = { "Frostblitz verlangsamt Gegner: so kommen sie kaum an dich heran", "Mit Frostnova frierst du Gegner fest und gehst auf Abstand", "Zaubere dir Wasser und Brot, dann sparst du Gold" },
        help = { "Stell dich zwischen Gegner und Magier, er hält wenig aus", "Plane Trinkpausen ein", "Freu dich über kostenloses Essen und Wasser" } },
    PALADIN = { name = "Paladin", icon = "ClassIcon_Paladin", color = { 0.96, 0.55, 0.73 }, armor = "plate", ease = 2,
        tank = true, heal = true,
        short = "Ein Krieger des Lichts in schwerer Rüstung. Du kämpfst vorne, heilst dich selbst und stärkst deine Gruppe mit Segen.",
        pros = { "Hält sehr viel aus", "Kann sich und andere heilen", "Gottesschild rettet dich in brenzligen Momenten" },
        cons = { "Kämpft langsam und gemächlich", "In klassischen Regeln nur für die Allianz" },
        first = { "Halte immer ein Siegel und einen Segen aktiv", "Mit Richturteil löst du dein Siegel auf dem Gegner aus", "Wird es knapp: Gottesschild und dann heilen" },
        help = { "Erinnere an Siegel und Segen, sie laufen aus", "Paladine sind zäh: gut geeignet, um vorne zu stehen" } },
    PRIEST = { name = "Priester", icon = "ClassIcon_Priest", color = { 1, 1, 1 }, armor = "cloth", ease = 1,
        heal = true, ranged = true,
        short = "Der beste Heiler. Du schützt deine Begleitung mit Schilden und Heilzaubern oder zerstörst Gegner mit Schattenmagie.",
        pros = { "Hält die Gruppe am Leben wie keine andere Klasse", "Machtwort: Schild schützt dich und andere", "Im Duo sehr stark" },
        cons = { "Allein eher langsam", "Hält selbst wenig aus" },
        first = { "Machtwort: Schild vor dem Kampf auf dich oder deine Begleitung", "Schattenwort: Schmerz und dann den Zauberstab benutzen spart Mana", "Besorge dir früh einen Zauberstab" },
        help = { "Zieh die Gegner auf dich, damit der Priester in Ruhe heilen kann", "Ein Zauberstab ist das wichtigste frühe Geschenk" } },
    DRUID = { name = "Druide", icon = "ClassIcon_Druid", color = { 1, 0.49, 0.04 }, armor = "leather", ease = 1,
        tank = true, heal = true,
        short = "Ein Gestaltwandler der Natur: als Bär hältst du viel aus, als Katze teilst du aus, und heilen kannst du auch.",
        pros = { "Kann alles ein bisschen: schützen, heilen, Schaden", "Reisegestalt macht dich früh schneller", "Sehr abwechslungsreich" },
        cons = { "Viele Fähigkeiten und Gestalten zu lernen", "Bis Level 10 etwas zäh" },
        first = { "Die Bärengestalt bekommst du mit Level 10 über eine Quest", "Verjüngung vor dem Kampf hält dich am Leben", "Mit Level 20 kommt die Katzengestalt, mit 30 die Reisegestalt" },
        help = { "Hilf beim Sortieren der Leisten, jede Gestalt hat ihre eigene", "Hilf bei der Bären-Quest mit Level 10" } },
    SHAMAN = { name = "Schamane", icon = "ClassIcon_Shaman", color = { 0, 0.44, 0.87 }, armor = "mail", ease = 1,
        heal = true,
        short = "Du rufst die Elemente: Blitze und Schocks, Totems die euch stärken, und heilen kannst du auch.",
        pros = { "Vielseitig: Nahkampf, Zauber und Heilung", "Totems verstärken die ganze Gruppe", "Geisterwolf macht dich mit Level 20 schneller" },
        cons = { "Totems muss man immer wieder neu stellen", "In klassischen Regeln nur für die Horde" },
        first = { "Die Totems bekommst du über Quests bei deinem Lehrer", "Erdschock unterbricht zaubernde Gegner", "Blitzschlagschild immer aktiv halten" },
        help = { "Hilf bei den Totem-Quests", "Bleibt nah beieinander, Totems wirken nur im Umkreis" } },
    ROGUE = { name = "Schurke", icon = "ClassIcon_Rogue", color = { 1, 0.96, 0.41 }, armor = "leather", ease = 1,
        short = "Du schleichst unsichtbar an Gegner heran und schlägst mit zwei Waffen blitzschnell zu.",
        pros = { "Unsichtbar an Gegnern vorbeischleichen", "Viel Schaden im Nahkampf", "Kann Gegner betäuben und Kisten knacken" },
        cons = { "Hält wenig aus, wenn mehrere Gegner kommen", "Keine Selbstheilung" },
        first = { "Finsterer Stoß baut Combopunkte auf, Ausweiden verbraucht sie", "Verbände (Erste Hilfe) sind für dich besonders wichtig", "Greife möglichst von hinten und einen Gegner nach dem anderen an" },
        help = { "Heilen oder Gegner abfangen hilft dem Schurken enorm", "Erinnere an Erste Hilfe und Verbände" } },
    WARRIOR = { name = "Krieger", icon = "ClassIcon_Warrior", color = { 0.78, 0.61, 0.43 }, armor = "plate", ease = 0,
        tank = true,
        short = "Ein Kämpfer in schwerer Rüstung, der mitten im Getümmel steht und andere beschützt.",
        pros = { "Der klassische Beschützer in der Gruppe", "Trägt die schwerste Rüstung", "Mit Heiler an der Seite kaum aufzuhalten" },
        cons = { "Allein die schwerste Klasse zum Leveln", "Keine Selbstheilung, braucht gute Waffen" },
        first = { "Mit Sturmangriff springst du in den Kampf und bekommst Wut", "Eine gute Waffe ist wichtiger als alles andere", "Lerne Erste Hilfe: du hast keine Heilzauber" },
        help = { "Ein Krieger braucht dich: heile ihn oder kämpfe am selben Gegner", "Schenke ihm gute Waffen, das macht den größten Unterschied" } },
}

KG.ARMOR_NAMES = { cloth = "Stoff", leather = "Leder", mail = "Kette (bis Level 40 Leder)", plate = "Platte (bis Level 40 Kette)" }
KG.EASE_NAMES = { [3] = "sehr leicht", [2] = "leicht", [1] = "mittel", [0] = "anspruchsvoll" }

local ALL = { "HUNTER", "WARLOCK", "MAGE", "PALADIN", "PRIEST", "DRUID", "SHAMAN", "ROGUE", "WARRIOR" }
local function each(list, pts)
    local t = {}
    for _, k in ipairs(list) do t[k] = pts end
    return t
end

-- Antworten: p = Punkte je Klasse, why = Begründung ("Passt, weil du ...")
KG.QUIZ = {
    { key = "range", text = "Wie möchtest du am liebsten kämpfen?", hint = "Es gibt kein Richtig oder Falsch. Wähle, was sich für dich gut anhört.",
      answers = {
        { key = "bow", text = "Aus der Ferne, mit Bogen oder Gewehr", why = "mit Bogen oder Gewehr kämpfen möchtest", p = { HUNTER = 3 } },
        { key = "magic", text = "Aus der Ferne, mit Zaubern", why = "aus der Ferne zaubern möchtest", p = { MAGE = 3, WARLOCK = 3, PRIEST = 1, SHAMAN = 1, DRUID = 1 } },
        { key = "melee", text = "Mittendrin, mit Schwert, Axt oder Dolch", why = "mitten im Getümmel kämpfen möchtest", p = { WARRIOR = 3, PALADIN = 2, ROGUE = 3, SHAMAN = 1, DRUID = 1 } },
        { key = "any", text = "Das ist mir egal", p = {} },
      } },
    { key = "pet", text = "Möchtest du einen Begleiter, der für dich kämpft?", hint = "Ein Begleiter fängt die Gegner ab, während du aus sicherer Entfernung angreifst.",
      answers = {
        { key = "beast", text = "Ja, ein Tier, das ich selbst zähme", why = "ein eigenes Tier haben möchtest", p = { HUNTER = 4 } },
        { key = "demon", text = "Ja, einen Dämon, den ich beschwöre", why = "einen Dämon an deiner Seite möchtest", p = { WARLOCK = 4 } },
        { key = "either", text = "Ja, egal ob Tier oder Dämon", why = "einen Begleiter möchtest", p = { HUNTER = 3, WARLOCK = 3 } },
        { key = "none", text = "Nein, ich kämpfe lieber allein", why = "lieber ohne Begleiter kämpfst", p = each({ "MAGE", "PALADIN", "PRIEST", "DRUID", "SHAMAN", "ROGUE", "WARRIOR" }, 1) },
      } },
    { key = "role", text = "Was möchtest du in einer Gruppe am liebsten tun?", hint = "In Gruppen hat jeder eine Aufgabe.",
      answers = {
        { key = "dmg", text = "Gegner besiegen und Schaden machen", why = "vor allem Schaden machen möchtest", p = { HUNTER = 2, MAGE = 2, WARLOCK = 2, ROGUE = 2, WARRIOR = 1 } },
        { key = "heal", text = "Andere heilen und am Leben halten", why = "gern andere heilst", p = { PRIEST = 3, DRUID = 2, PALADIN = 2, SHAMAN = 2 } },
        { key = "tank", text = "Vorne stehen und die anderen beschützen", why = "andere beschützen möchtest", p = { WARRIOR = 3, PALADIN = 3, DRUID = 2 } },
        { key = "mix", text = "Mal dies, mal das", why = "Abwechslung magst", p = { DRUID = 3, SHAMAN = 2, PALADIN = 2 } },
      } },
    { key = "ease", text = "Wie viel möchtest du am Anfang lernen müssen?", hint = "Manche Klassen kommen mit wenigen Tasten aus, andere haben viele Möglichkeiten.",
      answers = {
        { key = "easy", text = "So einfach wie möglich", why = "es am Anfang einfach haben möchtest", p = { HUNTER = 3, WARLOCK = 2, PALADIN = 2, MAGE = 1 } },
        { key = "mid", text = "Ein bisschen Herausforderung ist in Ordnung", why = "ein bisschen Herausforderung magst", p = { MAGE = 2, SHAMAN = 2, WARLOCK = 1, PRIEST = 1, DRUID = 1, HUNTER = 1 } },
        { key = "hard", text = "Ich mag es knifflig", why = "es gern knifflig hast", p = { ROGUE = 2, DRUID = 2, WARRIOR = 2, PRIEST = 1 } },
      } },
    { key = "safety", text = "Was soll passieren, wenn es mal brenzlig wird?", hint = "Jede Klasse rettet sich auf ihre eigene Art.",
      answers = {
        { key = "tough", text = "Ich halte einfach viel aus", why = "viel aushalten möchtest", p = { WARRIOR = 2, PALADIN = 3, DRUID = 1, WARLOCK = 1 } },
        { key = "selfheal", text = "Ich heile mich selbst", why = "dich selbst heilen möchtest", p = { PALADIN = 2, PRIEST = 2, DRUID = 2, SHAMAN = 2, WARLOCK = 1 } },
        { key = "escape", text = "Ich entkomme und halte Abstand", why = "Gegnern lieber entkommst", p = { ROGUE = 2, MAGE = 3, HUNTER = 2, DRUID = 1 } },
        { key = "petTank", text = "Mein Begleiter fängt die Schläge ab", why = "einen Begleiter die Schläge abfangen lassen möchtest", p = { HUNTER = 3, WARLOCK = 3 } },
      } },
    { key = "mood", text = "Welche Stimmung gefällt dir am besten?", hint = "Hier geht es nur um den Geschmack.",
      answers = {
        { key = "nature", text = "Natur, Wildnis und Tiere", why = "Natur und Tiere magst", p = { HUNTER = 2, DRUID = 3, SHAMAN = 2 } },
        { key = "dark", text = "Dunkle Magie und Dämonen", why = "dunkle Magie magst", p = { WARLOCK = 3, PRIEST = 1 } },
        { key = "arcane", text = "Feuer, Eis und Zauberei", why = "Feuer und Eis magst", p = { MAGE = 3 } },
        { key = "light", text = "Licht, Glaube und glänzende Rüstung", why = "Licht und Rüstung magst", p = { PALADIN = 3, PRIEST = 2, WARRIOR = 1 } },
        { key = "sneak", text = "Schatten, Dolche und Heimlichkeit", why = "Heimlichkeit magst", p = { ROGUE = 3 } },
      } },
    { key = "duo", text = "Wie stellst du dir das Spielen zu zweit vor?", hint = "Ihr seid gemeinsam unterwegs. Was wäre deine Rolle?",
      answers = {
        { key = "side", text = "Wir kämpfen Seite an Seite", why = "Seite an Seite kämpfen möchtest", p = { WARRIOR = 1, PALADIN = 1, ROGUE = 1, SHAMAN = 1, DRUID = 1, HUNTER = 1, WARLOCK = 1 } },
        { key = "keep", text = "Ich halte uns beide am Leben", why = "euch beide am Leben halten möchtest", p = { PRIEST = 3, DRUID = 2, PALADIN = 2, SHAMAN = 2 } },
        { key = "back", text = "Ich bleibe hinten und helfe aus sicherer Entfernung", why = "lieber aus sicherer Entfernung hilfst", p = { HUNTER = 2, MAGE = 2, WARLOCK = 2, PRIEST = 1 } },
        { key = "any", text = "Weiß ich noch nicht", p = {} },
      } },
    { key = "extra", text = "Welches Extra fändest du am schönsten?", hint = "Kleine Besonderheiten, die den Alltag angenehmer machen.",
      answers = {
        { key = "travel", text = "Schneller reisen (Portale, Tiergestalt)", why = "schneller reisen möchtest", p = { MAGE = 2, DRUID = 2, SHAMAN = 1 } },
        { key = "conjure", text = "Essen, Wasser oder Heilsteine herbeizaubern", why = "nützliche Dinge herbeizaubern möchtest", p = { MAGE = 2, WARLOCK = 2 } },
        { key = "collect", text = "Tiere sammeln und ihnen Namen geben", why = "Tiere sammeln möchtest", p = { HUNTER = 3 } },
        { key = "none", text = "Brauche ich alles nicht", p = {} },
      } },
}

---------------------------------------------------------------------------
-- Berufe
---------------------------------------------------------------------------

KG.PROF_ORDER = { "skinning", "herbalism", "mining", "leatherworking", "tailoring", "alchemy", "enchanting", "blacksmithing", "engineering" }
KG.SEC_ORDER = { "firstaid", "cooking", "fishing" }

-- ids = Eröffnungszauber je Rang (für Erkennung und Namen in der Spielsprache)
KG.PROFS = {
    skinning       = { name = "Kürschnerei", icon = "INV_Misc_Pelt_Wolf_01", gather = true, ids = { 8613, 8617, 8618, 10768 },
        desc = "Du häutest besiegte Tiere. Geht ganz nebenbei und bringt Gold." },
    herbalism      = { name = "Kräuterkunde", icon = "Trade_Herbalism", gather = true, ids = { 2366, 2368, 3570, 11993 },
        desc = "Du pflückst Kräuter, die dir auf der Minikarte angezeigt werden." },
    mining         = { name = "Bergbau", icon = "Trade_Mining", gather = true, ids = { 2575, 2576, 3564, 10248 },
        desc = "Du baust Erz ab, das dir auf der Minikarte angezeigt wird." },
    leatherworking = { name = "Lederverarbeitung", icon = "Trade_LeatherWorking", needs = "skinning", ids = { 2108, 3104, 3811, 10662 },
        desc = "Du nähst Leder- und Kettenrüstung aus Tierhäuten." },
    tailoring      = { name = "Schneiderei", icon = "Trade_Tailoring", ids = { 3908, 3909, 3910, 12180 },
        shared = "Taschen für euch beide",
        desc = "Du nähst Stoffrüstung und Taschen. Stoff lassen viele Gegner einfach fallen." },
    alchemy        = { name = "Alchemie", icon = "Trade_Alchemy", needs = "herbalism", ids = { 2259, 3101, 3464, 11611 },
        shared = "Tränke für euch beide",
        desc = "Du braust Heil- und Manatränke aus Kräutern." },
    enchanting     = { name = "Verzauberkunst", icon = "Trade_Engraving", ids = { 7411, 7412, 7413, 13920 },
        shared = "Verzauberungen für euch beide",
        desc = "Du zerlegst magische Gegenstände und verzauberst damit Ausrüstung." },
    blacksmithing  = { name = "Schmiedekunst", icon = "Trade_BlackSmithing", needs = "mining", ids = { 2018, 3100, 3538, 9785 },
        desc = "Du schmiedest Waffen und schwere Rüstung aus Erz." },
    engineering    = { name = "Ingenieurskunst", icon = "Trade_Engineering", needs = "mining", ids = { 4036, 4037, 4038, 12656 },
        desc = "Du baust Bomben, Gewehre, Zielfernrohre und verrückte Geräte." },
    firstaid       = { name = "Erste Hilfe", icon = "Spell_Holy_SealOfSacrifice", secondary = true, ids = { 3273, 3274, 7924, 10846 },
        desc = "Verbände aus Stoff heilen dich ohne Mana." },
    cooking        = { name = "Kochkunst", icon = "INV_Misc_Food_15", secondary = true, ids = { 2550, 3102, 3413, 18260 },
        desc = "Gekochtes Essen heilt und stärkt euch." },
    fishing        = { name = "Angeln", icon = "Trade_Fishing", secondary = true, ids = { 7620, 7731, 7732, 18248 },
        desc = "Entspannt Fische fangen, zum Kochen oder Verkaufen." },
}

-- Nutzen eines Herstellungsberufs für die Klasse selbst: 0 = kaum, 1 = wenig, 2 = gut, 3 = sehr gut
-- (Rüstungsart, Waffen, Taschen, Munition, Tränke). Maßstab ist das Leveln bis 60.
local function benefit(t3, t2, t1)
    local b = {}
    for _, k in ipairs(KG.CLASS_ORDER) do b[k] = 0 end
    for _, k in ipairs(t1 or {}) do b[k] = 1 end
    for _, k in ipairs(t2 or {}) do b[k] = 2 end
    for _, k in ipairs(t3 or {}) do b[k] = 3 end
    return b
end

KG.PROF_BENEFIT = {
    blacksmithing  = benefit({ "WARRIOR", "PALADIN" }, { "SHAMAN", "ROGUE" }, { "HUNTER", "DRUID" }),
    leatherworking = benefit({ "HUNTER", "ROGUE", "DRUID", "SHAMAN" }, nil, { "WARRIOR", "PALADIN" }),
    tailoring      = benefit({ "MAGE", "WARLOCK", "PRIEST" }, nil, { "HUNTER", "ROGUE", "DRUID", "SHAMAN", "WARRIOR", "PALADIN" }),
    alchemy        = benefit(nil, KG.CLASS_ORDER),
    enchanting     = benefit(nil, KG.CLASS_ORDER),
    engineering    = benefit({ "HUNTER" }, { "WARRIOR", "ROGUE", "MAGE" }, { "SHAMAN", "DRUID", "PRIEST", "WARLOCK", "PALADIN" }),
}

-- Warum ein Beruf einer Klasse nützt (gut) oder nicht nützt (kaum)
KG.PROF_BENEFIT_NOTE = {
    blacksmithing = {
        good = "Waffen und Rüstung, die deine Klasse tragen kann",
        WARRIOR = "Du schmiedest dir Waffen und Plattenrüstung selbst", PALADIN = "Du schmiedest dir Waffen und Plattenrüstung selbst",
        SHAMAN = "Waffen, Schilde und später Kettenrüstung", ROGUE = "Dolche, Schwerter und Schleifsteine für dich",
        none = "Platten- und Kettenrüstung und die meisten Waffen kann diese Klasse nicht nutzen",
    },
    leatherworking = {
        good = "Leder- und Kettenrüstung für deine Klasse",
        HUNTER = "Leder- und Kettenrüstung, dazu Köcher und Munitionstaschen", ROGUE = "Lederrüstung genau für deine Klasse",
        DRUID = "Lederrüstung genau für deine Klasse", SHAMAN = "Leder- und Kettenrüstung für deine Klasse",
        none = "Leder- und Kettenrüstung kann diese Klasse nicht tragen",
    },
    tailoring = { good = "Stoffrüstung und große Taschen für deine Klasse", none = "Stoffrüstung kann diese Klasse nicht tragen" },
    alchemy = { good = "Heil- und Manatränke, später Elixiere" },
    enchanting = { good = "Du verzauberst deine eigene Ausrüstung" },
    engineering = { good = "Gadgets, Bomben und nützliche Ausrüstung", HUNTER = "Gewehre, Zielfernrohre und Bomben", none = "Die Geräte nützen dieser Klasse kaum" },
}

KG.PROF_QUIZ = {
    { key = "style", text = "Was machst du unterwegs am liebsten?", hint = "Du kannst zwei Hauptberufe lernen. Sammelberufe sammeln Material, Herstellungsberufe machen daraus etwas.",
      answers = {
        { key = "gather", text = "Alles einsammeln, was ich finde" },
        { key = "craft", text = "Selbst Dinge herstellen" },
        { key = "both", text = "Beides: sammeln und daraus etwas machen" },
        { key = "none", text = "Am liebsten einfach spielen, Berufe sind Nebensache" },
      } },
    { key = "goal", text = "Was ist dir bei Berufen am wichtigsten?", hint = "Davon hängt ab, welche Berufe sich für dich lohnen.",
      answers = {
        { key = "gold", text = "Gold verdienen" },
        { key = "gear", text = "Ausrüstung für mich selbst" },
        { key = "help", text = "Meiner Begleitung helfen und uns ergänzen" },
        { key = "any", text = "Das ist mir egal" },
      } },
    { key = "effort", text = "Wie viel Aufwand darf es sein?", hint = "Manche Berufe laufen nebenbei, andere brauchen Zeit und Gold.",
      answers = {
        { key = "low", text = "Möglichst wenig" },
        { key = "mid", text = "Ganz normal" },
        { key = "high", text = "Gern viel, ich tüftle gern" },
      } },
}

-- Erste Schritte für alle Einsteiger
KG.FIRST_STEPS = {
    "Sprich Figuren mit einem gelben Ausrufezeichen an: sie geben dir Aufgaben (Quests)",
    "Ein gelbes Fragezeichen heißt: Aufgabe erledigt, hier abgeben",
    "Besuche alle zwei Level deinen Klassenlehrer und lerne neue Fähigkeiten",
    "Verkaufe graue Gegenstände beim Händler, sie sind nur zum Verkaufen da",
    "Mit Level 10 bekommst du Talentpunkte: Taste N öffnet die Talente",
    "Stirbst du, laufe als Geist zu deinem Körper zurück. Das ist nicht schlimm",
}
