# Kindergarten

**Deutsch** | [English](#english)

Ein Begleit-Addon für **WoW Forever** (Interface 16001), das WoW-Einsteigern den Start erleichtert und ihrer erfahrenen Begleitung zeigt, wie sie am besten helfen kann. Gedacht für zwei Spieler, die gemeinsam leveln: einer ist neu im Spiel (das "Kind"), einer kennt es schon (die "Eltern"). Befehl im Spiel: `/kg`

**Status: Beta.** Das Addon wurde bisher nur offline gegen eine nachgebaute WoW-Schnittstelle getestet, nicht im Spiel selbst. Rückmeldungen sind willkommen, siehe [Fehler melden](#fehler-melden).

Die Oberfläche ist derzeit nur auf Deutsch verfügbar. Namen von Zaubern und Talenten kommen aus dem Spiel und folgen deiner Spielsprache.

## Inhalt

- [Was das Addon macht](#was-das-addon-macht)
- [Installation](#installation)
- [Schnellstart zu zweit](#schnellstart-zu-zweit)
- [Alleine ausprobieren](#alleine-ausprobieren)
- [Die Seiten im Einzelnen](#die-seiten-im-einzelnen)
- [Austausch zwischen euch](#austausch-zwischen-euch)
- [Bedienung und Controller](#bedienung-und-controller)
- [Datenquellen und Aktualisierung nach Patches](#datenquellen-und-aktualisierung-nach-patches)
- [Datenschutz](#datenschutz)
- [Bekannte Grenzen](#bekannte-grenzen)
- [Fehler melden](#fehler-melden)

## Was das Addon macht

Beim ersten Start wählst du deine Rolle:

- **Ich bin neu in WoW:** Du beantwortest ein paar einfache Fragen zu deinem Spielstil. Daraus entstehen eine Empfehlung für deine Klasse und deine Berufe, abgestimmt auf die Person, mit der du spielst. Du bekommst ein paar erste Schritte zum Abhaken, eine vorgegebene Skillung und Hinweise, was du beim Klassenlehrer mitnehmen sollst.
- **Ich begleite jemanden:** Du trägst ein, welche Klasse und Berufe dein Kind spielt. Das Addon zeigt dir, welche Klasse und welche Berufe bei dir am besten dazu passen, du planst die Talent-Skillung vor, markierst, was beim Lehrer wichtig ist, und bekommst Tipps passend zur Klasse.

Beide Seiten tauschen ihre Daten automatisch aus, sobald ihr in einer Gruppe seid. Ohne Gruppe geht es per Flüstern, per Text-Code oder von Hand.

## Installation

1. Unter [Releases](../../releases) die Datei `Kindergarten-x.y.z.zip` herunterladen.
2. Den Ordner `Kindergarten` aus dem Zip nach `World of Warcraft/<Spielversion>/Interface/AddOns/` kopieren.
3. Spiel starten. Beim ersten Login öffnet sich das Fenster von selbst. Danach öffnest du es mit `/kg`.

Das Addon muss bei **beiden** Spielern installiert sein, damit der automatische Austausch funktioniert. Es läuft aber auch, wenn nur einer es hat (dann ohne Austausch).

## Schnellstart zu zweit

1. **Beide** installieren das Addon und öffnen es mit `/kg`.
2. Das Kind wählt "Ich bin neu in WoW", die Eltern wählen "Ich begleite jemanden".
3. Ladet euch gegenseitig in eine Gruppe ein. Das Addon tauscht jetzt Klasse, Level und Berufe aus. Wenn nichts ankommt, hilft auf der Seite "Meine Begleitung" bzw. "Mein Kind" der Knopf "In der Gruppe anfragen".
4. Das Kind beantwortet die Fragen zum Spielstil und schaut sich Klasse und Berufe an. Die Eltern sehen im selben Moment, was zum Kind passt.
5. Die Eltern planen auf der Seite "Skillung planen" die Talente vor und markieren auf "Lehrer-Tipps", was beim Klassenlehrer wichtig ist. Beides schicken sie mit einem Knopf an das Kind.
6. Beim Leveln erinnert das Addon das Kind an freie Talentpunkte und neue Fähigkeiten beim Lehrer.

## Alleine ausprobieren

Du kannst fast alles auf einem einzelnen Charakter testen:

- Wähle auf der Willkommen-Seite eine Rolle. Du kannst sie jederzeit wechseln ("Alles zurücksetzen" unten links).
- Trage die Begleitung unter "Von Hand eintragen" ein (Klasse und Berufe anklicken). Dann siehst du, wie sich die Empfehlungen verändern.
- Für die Skillung: Trage als Kind dieselbe Klasse ein, die dein Charakter hat. Dann liest der Planer deine eigenen Talente und zeigt dir den Fortschritt. Vorsicht: Der Knopf "Diesen Punkt lernen" setzt den Talentpunkt wirklich.

Nicht alleine testbar ist der automatische Austausch in der Gruppe. Eigene Nachrichten ignoriert das Addon, und deinen eigenen Profil-Code lehnt es ab. Der Skillungs- und der Lehrer-Code lassen sich dagegen allein kopieren und wieder einfügen.

## Die Seiten im Einzelnen

Links in der Seitenleiste stehen die Schritte. Die Namen unterscheiden sich je nach Rolle (Kind / Eltern).

### Meine Begleitung / Mein Kind

Hier steht, mit wem du spielst. Drei Wege zum Eintragen: automatisch über die Gruppe, per Zuflüstern an einen Charakternamen oder per Code. Alternativ trägst du Klasse und Berufe von Hand ein.

### Mein Spielstil (nur Kind)

Acht kurze Fragen, zum Beispiel ob du lieber aus der Ferne oder mittendrin kämpfst, ob du einen Begleiter möchtest, welche Rolle du in der Gruppe magst und wie viel du am Anfang lernen willst. Es gibt kein Richtig oder Falsch.

### Meine Klasse / Passende Klasse

- **Kind:** Alle neun Klassen als Karten mit Prozentwert und Begründung ("Passt, weil du ..."). Ist die Klasse der Begleitung bekannt, fließt ein, wie gut ihr euch ergänzt (zum Beispiel Tank und Heiler). Dieselbe Klasse oder Rüstungsart wie die Begleitung gibt eine Warnung, weil ihr dieselbe Beute wollt.
- **Eltern:** Eine Rangliste, welche Klasse zu der Klasse des Kindes passt, und auf welchem Platz dein aktueller Charakter liegt. Dafür braucht es keine Fragen.

### Meine Berufe / Passende Berufe

Alle 36 Kombinationen der neun Hauptberufe werden bewertet. Dabei zählt:

- **Nutzen für die Klasse:** Für jeden Herstellungsberuf ist hinterlegt, was er welcher Klasse bringt (Rüstungsart, Waffen, Taschen, Munition, Tränke). Hat die Klasse kaum etwas davon, gibt es einen starken Abzug und eine Warnung. Ein Priester bekommt zum Beispiel keine Schmiedekunst empfohlen, es sei denn, die Begleitung trägt Plattenrüstung.
- **Material:** Ein Sammelberuf, der einen nützlichen Herstellungsberuf beliefert, wird aufgewertet.
- **Abstimmung mit der Begleitung:** Berufe, die die Begleitung schon hat, werden abgewertet. Sammelberufe, die ihre Herstellung beliefern, werden aufgewertet.
- **Deine Antworten:** Drei Fragen (sammeln oder herstellen, Ziel, Aufwand). Bei den Eltern entfallen sie, dort ist das Ziel "ergänzen".

Dazu gibt es Hinweise zu den Nebenberufen Erste Hilfe, Kochkunst und Angeln. Die Prozentwerte sind absolut. "Eher nicht" heißt wirklich eher nicht.

### Meine Skillung / Skillung planen

- **Eltern:** Die Talentbäume aller Klassen sind im Addon eingebaut, deshalb kannst du auch planen, wenn dein Kind gerade nicht online ist. Du klickst die Talente in der Reihenfolge an, in der sie gelernt werden sollen (Linksklick setzt einen Punkt, Rechtsklick nimmt ihn zurück). Das Addon erzwingt die echten Regeln: fünf Punkte pro Reihe, Voraussetzungen zuerst voll, höchstens 51 Punkte. Zu jedem Punkt steht das Level, bei dem er frei wird (Punkt 1 ist Level 10). Entfernst du einen Punkt, fallen davon abhängige spätere Punkte mit heraus.
- **Kind:** Du siehst die Skillung deiner Begleitung mit dem nächsten Punkt grün umrandet. Der Knopf "Diesen Punkt lernen" setzt ihn direkt. Hast du einen freien Talentpunkt, erinnert dich das Addon im Chat und mit einer kleinen Einblendung.
- Passt der eigene Talentbaum nach einem Patch nicht mehr zu den eingebauten Daten, nutzt das Addon den Baum aus dem Spiel und sagt es.

### Beim Lehrer / Lehrer-Tipps

- **Eltern:** Alle Klassenfähigkeiten mit Lernstufe und Rängen. Pro Fähigkeit stellst du Normal, Wichtig oder Auslassen ein.
- **Kind:** Du siehst die Markierungen und zu jeder Fähigkeit, ob sie schon gelernt ist, jetzt fällig ist oder erst später kommt. Bei jedem Level-Up meldet das Addon, was du als Wichtiges beim Lehrer abholen sollst. Am Lehrerfenster erscheint daneben ein kleines Fenster mit "Mitnehmen" und "Auslassen" für das, was der Lehrer wirklich anbietet.
- Fähigkeiten, deren erster Rang aus einem Talent kommt, werden erst gemeldet, wenn das Talent gelernt ist.

### Mein Plan / So hilfst du

- **Kind:** Deine Auswahl auf einen Blick (Klasse, Berufe, Begleitung) und erste Schritte zum Abhaken, passend zur Klasse.
- **Eltern:** Tipps, wie du deinem Kind passend zur Klasse hilfst, zum Beispiel an Munition und Futter für das Tier zu erinnern.

## Austausch zwischen euch

Das Addon versendet vier Arten von Daten: das Profil (Klasse, Level, Berufe), die Skillung, die Lehrer-Markierungen und die Anfragen danach.

- **Gruppe:** Automatisch beim Beitritt oder Wechsel der Gruppe und per Knopf. Die Nachrichten gehen nur an die eigene Gruppe oder den Schlachtzug.
- **Zuflüstern:** Das Profil lässt sich an einen Charakternamen schicken, auch ohne Gruppe.
- **Code:** Ohne Gruppe kopierst du einen Text-Code und schickst ihn per Chat oder Messenger. Die andere Person fügt ihn auf der passenden Seite ein. Der Import übernimmt nur bekannte Klassen, Berufe und Werte und führt nie fremden Code aus.
- **Von Hand:** Klasse und Berufe selbst anklicken.

Skillung und Lehrer-Markierungen werden nur von den Eltern an das Kind geschickt. Haben beide Addons einen anderen Datenstand (zum Beispiel nach einem Patch), meldet das Addon es, statt falsche Daten anzuzeigen.

## Bedienung und Controller

- **Fenster:** Mit `/kg` öffnen und schließen. Verschieben per Ziehen. Die Größe stufenlos von 60 bis 160 Prozent mit dem Anfasser unten rechts, Rechtsklick darauf setzt auf 100 Prozent zurück.
- **Tastenbelegung:** In den Tastenbelegungen des Spiels gibt es unter "AddOns" den Eintrag "Kindergarten öffnen oder schließen". Er lässt sich auch auf eine Controller-Taste legen.
- **Controller (eingebautes Gamepad-System):** Steuerkreuz wählt das nächste Feld, A bestätigt, B schließt (in einem Textfeld verlässt B zuerst das Feld), LB und RB wechseln den Schritt in der Seitenleiste. Ab dem ersten Druck erscheint eine Hinweiszeile in der Seitenleiste. Texteingaben (Name, Code) brauchen weiterhin eine Tastatur. Das Skalieren geht nur mit der Maus.
- **Diagnose:** `/kg talente` prüft, ob das Spiel die Talentbäume liefert und ob sie zu den eingebauten Daten passen. Das Ergebnis steht danach in der Datei `WTF/Account/<Kontoname>/SavedVariables/Kindergarten.lua`.

## Datenquellen und Aktualisierung nach Patches

Die Talentbäume und die Klassenfähigkeiten sind aus den Spieltabellen von WoW Forever abgeleitet, die [wago.tools](https://wago.tools) als Export anbietet (Produkt `wowf`, derzeit Build 1.60.1.70888). Sie liegen als `Kindergarten/TalentData.lua` und `Kindergarten/AbilityData.lua` im Addon. Namen und Symbole kommen zur Laufzeit aus dem Spiel.

Nach einem Patch lassen sich beide Dateien neu erzeugen (Python 3 und Internetzugang genügen):

```
python3 tools/gen_talents.py       # Talentbäume, optional mit Build-Nummer als Argument
python3 tools/gen_abilities.py     # Klassenfähigkeiten, optional mit Build-Nummer
```

Ohne Argument nehmen die Skripte den neuesten `wowf`-Build. Zur Lehrer-Liste: Wago führt keine Lehrer-Tabellen, deshalb ist sie aus den Lernstufen der Fähigkeiten abgeleitet. Vereinzelt stehen Einträge drin, die kein Lehrer anbietet (zum Beispiel Haltungs-Passive). Die Eltern stellen sie auf "Auslassen". Das Lehrerfenster zeigt ohnehin nur echte Angebote.

Die Nutzen-Tabelle der Berufe (`KG.PROF_BENEFIT` in `Kindergarten/Data.lua`) ist eine Einschätzung fürs Leveln bis Stufe 60 und darf angepasst werden.

## Datenschutz

Das Addon kennt keinen Server und sendet nichts ins Internet. Es speichert seine Daten lokal in `KindergartenDB` (SavedVariables, account-weit). Addon-Nachrichten gehen nur an deine Gruppe oder per Flüstern an den Namen, den du selbst eingibst.

## Bekannte Grenzen

- **Nicht im Spiel getestet.** Ungeklärt ist vor allem, ob WoW Forever die Gamepad-Tasten, die Talent-Schnittstelle (Fortschritt und "Diesen Punkt lernen") und die Lehrer-Schnittstelle (Fenster neben dem Lehrer) so liefert wie angenommen. Fehlt etwas davon, bleibt der Rest nutzbar: Die Talentbäume und Fähigkeiten sind eingebaut, das Planen geht immer.
- Die Oberfläche ist nur auf Deutsch.
- Klassenempfehlungen und Berufe-Nutzen sind Einschätzungen, keine Wahrheiten. Die Klassentexte folgen den klassischen Regeln.
- Eine Lizenz ist noch nicht festgelegt.

## Fehler melden

Gib vor dem Test `/console scriptErrors 1` ein. Bei einem Lua-Fehler erscheint dann ein Fenster. Bitte den Text daraus als [Issue](../../issues) melden, dazu Klasse, Rolle (Kind oder Eltern) und Spielsprache.

---

<a name="english"></a>

# Kindergarten (English)

[Deutsch](#kindergarten) | **English**

A companion addon for **WoW Forever** (Interface 16001) that makes the start easier for newcomers and shows their experienced partner how best to help. It is meant for two players leveling together: one is new to the game (the "kid"), one knows it already (the "parent"). In-game command: `/kg`

**Status: beta.** So far the addon has only been tested offline against a mock of the WoW API, not in the game itself. Feedback is welcome, see [Reporting problems](#reporting-problems).

**Note:** The user interface is currently in German only. Spell and talent names come from the game and follow your client language.

## Contents

- [What it does](#what-it-does)
- [Installation](#installation)
- [Quick start for two](#quick-start-for-two)
- [Trying it alone](#trying-it-alone)
- [The pages in detail](#the-pages-in-detail)
- [Sharing between the two of you](#sharing-between-the-two-of-you)
- [Controls and controller](#controls-and-controller)
- [Data sources and updating after patches](#data-sources-and-updating-after-patches)
- [Privacy](#privacy)
- [Known limits](#known-limits)
- [Reporting problems](#reporting-problems)

## What it does

On first start you pick your role:

- **I am new to WoW (kid):** You answer a few simple questions about your play style. They turn into a recommendation for your class and your professions, tuned to the person you play with. You also get a few first steps to check off, a talent build handed to you, and hints on what to pick up at the class trainer.
- **I am accompanying someone (parent):** You enter the class and professions your kid plays. The addon shows which class and professions fit best next to theirs, you plan their talent build in advance, mark what matters at the trainer, and get tips for their class.

Both sides exchange their data automatically once you are in a group. Without a group it works by whisper, by text code, or by hand.

## Installation

1. Download `Kindergarten-x.y.z.zip` from [Releases](../../releases).
2. Copy the `Kindergarten` folder from the zip to `World of Warcraft/<game version>/Interface/AddOns/`.
3. Start the game. The window opens by itself on first login. After that, open it with `/kg`.

Both players need the addon for the automatic exchange to work. It also runs if only one of you has it (without the exchange).

## Quick start for two

1. **Both** install the addon and open it with `/kg`.
2. The kid picks "I am new to WoW", the parent picks "I am accompanying someone".
3. Invite each other to a group. The addon now exchanges class, level and professions. If nothing arrives, use "In der Gruppe anfragen" (request in group) on the "Meine Begleitung" / "Mein Kind" page.
4. The kid answers the play style questions and looks at class and professions. The parent sees at the same time what fits the kid.
5. The parent plans the talents on "Skillung planen" and marks what matters at the trainer on "Lehrer-Tipps". Both can be sent to the kid with one button.
6. While leveling, the addon reminds the kid about free talent points and new abilities at the trainer.

## Trying it alone

You can test almost everything on a single character:

- Pick a role on the welcome page. You can switch any time ("Alles zurücksetzen" at the bottom left).
- Enter the partner under "Von Hand eintragen" (click class and professions) to see how the recommendations change.
- For the talent build: as the kid, enter the same class your character has. The planner then reads your own talents and shows progress. Careful: the "Diesen Punkt lernen" (learn this point) button really spends the talent point.

What you cannot test alone is the automatic exchange in a group. The addon ignores its own messages and rejects your own profile code. The talent and trainer codes can be copied and pasted back in on your own.

## The pages in detail

The steps are listed in the sidebar. Their names differ by role (kid / parent).

### Meine Begleitung / Mein Kind (my companion / my kid)

Who you play with. Three ways to fill it in: automatically through the group, by whisper to a character name, or by code. Alternatively enter class and professions by hand.

### Mein Spielstil (my play style, kid only)

Eight short questions, for example whether you prefer ranged or melee, whether you want a pet, which role you like in a group and how much you want to learn at the start. There is no right or wrong.

### Meine Klasse / Passende Klasse (class)

- **Kid:** All nine classes as cards with a percentage and reasons ("Passt, weil du ..." - fits because you ...). If the partner's class is known, it counts how well you complement each other (for example tank and healer). The same class or armor type as the partner gives a warning, because you would compete for the same loot.
- **Parent:** A ranking of which class fits the kid's class best, and where your current character sits. No questions needed.

### Meine Berufe / Passende Berufe (professions)

All 36 combinations of the nine main professions are scored. What counts:

- **Benefit for the class:** For every crafting profession the addon knows what it gives each class (armor type, weapons, bags, ammunition, potions). If the class gets next to nothing from it, the score drops sharply and a warning appears. A priest, for example, is not recommended blacksmithing unless the partner wears plate armor.
- **Materials:** A gathering profession that supplies a useful crafting profession is rated higher.
- **Coordination with the partner:** Professions the partner already has are rated lower. Gathering professions that supply the partner's crafting are rated higher.
- **Your answers:** Three questions (gather or craft, goal, effort). For the parent they are skipped; the goal there is "complement".

There is also advice on the secondary professions First Aid, Cooking and Fishing. The percentages are absolute: "eher nicht" (rather not) really means rather not.

### Meine Skillung / Skillung planen (talent build)

- **Parent:** The talent trees of all classes are built into the addon, so you can plan even when your kid is offline. Click the talents in the order they should be learned (left click adds a point, right click takes it back). The addon enforces the real rules: five points per row, prerequisites maxed first, at most 51 points. Each point shows the level at which it unlocks (point 1 is level 10). Removing a point also removes later points that depend on it.
- **Kid:** You see your partner's build with the next point outlined in green. The "Diesen Punkt lernen" button learns it directly. When you have a free talent point, the addon reminds you in chat and with a small pop-up.
- If your own talent tree no longer matches the built-in data after a patch, the addon uses the tree from the game and tells you.

### Beim Lehrer / Lehrer-Tipps (trainer)

- **Parent:** All class abilities with learn level and ranks. For each ability choose Normal, Wichtig (important) or Auslassen (skip).
- **Kid:** You see the marks and, for each ability, whether it is learned, due now, or comes later. At every level-up the addon tells you what to pick up at the trainer if it is marked important. At the trainer window a small panel next to it shows "Mitnehmen" (take) and "Auslassen" (skip) for what the trainer actually offers.
- Abilities whose first rank comes from a talent are only reported once the talent is learned.

### Mein Plan / So hilfst du (plan / how you help)

- **Kid:** Your choices at a glance (class, professions, partner) and first steps to check off, matched to your class.
- **Parent:** Tips on how to help your kid for their class, for example reminding about ammunition and pet food.

## Sharing between the two of you

The addon sends four kinds of data: the profile (class, level, professions), the talent build, the trainer marks, and requests for them.

- **Group:** Automatically when the group changes and by button. Messages go only to your own party or raid.
- **Whisper:** The profile can be sent to a character name, also without a group.
- **Code:** Without a group, copy a text code and send it by chat or messenger. The other person pastes it on the matching page. The import only accepts known classes, professions and values and never runs foreign code.
- **By hand:** Click class and professions yourself.

Talent build and trainer marks are only sent from the parent to the kid. If both addons have a different data version (for example after a patch), the addon says so instead of showing wrong data.

## Controls and controller

- **Window:** Open and close with `/kg`. Drag to move. Resize smoothly from 60 to 160 percent with the grip at the bottom right; a right click on it resets to 100 percent.
- **Key binding:** In the game's key bindings, under "AddOns", there is an entry "Kindergarten öffnen oder schließen" (open or close). It can also be bound to a controller button.
- **Controller (built-in gamepad system):** The d-pad moves to the next field, A confirms, B closes (inside a text field B leaves the field first), LB and RB switch the step in the sidebar. A hint line appears in the sidebar from the first press. Text input (name, code) still needs a keyboard. Resizing works with the mouse only.
- **Diagnostics:** `/kg talente` checks whether the game provides the talent trees and whether they match the built-in data. The result is written to `WTF/Account/<account name>/SavedVariables/Kindergarten.lua`.

## Data sources and updating after patches

The talent trees and class abilities are derived from the game tables of WoW Forever that [wago.tools](https://wago.tools) offers as an export (product `wowf`, currently build 1.60.1.70888). They live in the addon as `Kindergarten/TalentData.lua` and `Kindergarten/AbilityData.lua`. Names and icons come from the game at runtime.

After a patch both files can be regenerated (Python 3 and internet access are enough):

```
python3 tools/gen_talents.py       # talent trees, optionally with a build number as argument
python3 tools/gen_abilities.py     # class abilities, optionally with a build number
```

Without an argument the scripts take the newest `wowf` build. About the trainer list: Wago has no trainer tables, so it is derived from the learn levels of the abilities. A few entries may be in there that no trainer offers (for example stance passives). The parent sets them to "Auslassen". The trainer window only ever shows real offers anyway.

The profession benefit table (`KG.PROF_BENEFIT` in `Kindergarten/Data.lua`) is an estimate for leveling up to level 60 and may be adjusted.

## Privacy

The addon has no server and sends nothing to the internet. It stores its data locally in `KindergartenDB` (SavedVariables, account-wide). Addon messages go only to your group or by whisper to the name you enter yourself.

## Known limits

- **Not tested in the game.** The main open question is whether WoW Forever provides the gamepad buttons, the talent interface (progress and "Diesen Punkt lernen") and the trainer interface (panel next to the trainer) as assumed. If one of them is missing, the rest stays usable: talent trees and abilities are built in, so planning always works.
- The interface is German only.
- Class recommendations and profession benefits are estimates, not facts. The class texts follow classic rules.
- No license has been chosen yet.

## Reporting problems

Before testing, enter `/console scriptErrors 1`. On a Lua error a window then appears. Please report the text from it as an [issue](../../issues), together with class, role (kid or parent) and game language.
