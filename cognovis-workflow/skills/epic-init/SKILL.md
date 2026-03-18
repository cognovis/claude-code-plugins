---
name: epic-init
model: sonnet
description: Guided planning dialog for larger initiatives producing Beads epics with sub-tasks. Use when planning features or multi-task initiatives needing structured breakdown. Triggers on epic init, plan epic, create epic, plan feature, break down feature.
---

# Epic Init

Gefuehrter Planungsdialog fuer groessere Vorhaben. Produziert ein Beads-Epic mit Sub-Tasks.

Workflow: Ziel -> Zerlegung -> Constraints+WHY -> Handshake -> Beads anlegen

## When to Use

- Planning a new feature or initiative that needs structured task breakdown
- Breaking a large project into trackable sub-tasks with dependencies
- Starting a multi-session effort and want an epic with acceptance criteria
- Organizing work before kicking off implementation across multiple areas

## Do NOT

- Do NOT use for single-task work that doesn't need breakdown
- Do NOT create epics without acceptance criteria on sub-tasks

## Argumente

$ARGUMENTS

| Flag | Wirkung |
|------|---------|
| (keine) | Interaktiver Dialog ab Phase 1 |
| `"<Ziel>"` | Ziel vorbelegen, Phase 1 ueberspringen |

Beispiele:
```
/epic-init
/epic-init "FHIR Patient Intake implementieren"
/epic-init "CLI Tool fuer Log-Rotation"
```

---

## Workflow

### Phase 0: Kontext laden & Duplikat-Prüfung

**Pre-Check: bd Verfügbarkeit**

1. Prüfe ob `bd` installiert ist und `.beads/` existiert:
   ```bash
   which bd && test -d .beads && echo "beads ready"
   ```

   Falls `bd` nicht verfügbar oder `.beads/` fehlt:
   - Hinweis: "Beads ist noch nicht initialisiert in diesem Projekt."
   - Angebot: "Soll ich `bd init` ausführen um Beads einzurichten?"
   - Falls User zustimmt: `bd init` ausführen
   - Falls User ablehnt: Abbrechen mit "Verstanden — wir planen dann ohne Beads-Integration."

**Kontext laden:**

2. Lies `./CLAUDE.md` (Projekt-Kontext — Tech-Stack, Architektur, Konventionen)
3. Lade offene und aktive Beads (falls verfügbar):
   ```bash
   bd list --status=open
   bd list --status=in_progress
   ```

4. **Duplikat-Prüfung mit expliziten Kriterien:**

   Prüfe geladene Beads gegen neues Vorhaben anhand dieser Kriterien:

   **(a) Ähnliche Titel** — Keyword-Matching:
   - Gleiche oder sehr ähnliche Schlüsselwörter (z.B. "API" in beiden Titeln)
   - Prüfe mit `bd search "<keyword>"` für gründlichere Suche

   **(b) Überlappende Scope-Beschreibung:**
   - Betreffen beide die gleiche(n) Komponente(n) oder Module?
   - Bearbeiten beide den gleichen Codebereich?

   **(c) Gleiche Ziel-Dateien/Module:**
   - Listen beide die gleichen Dateien, Services oder APIs auf?

   **Falls Duplikat gefunden:** "Es gibt bereits [bead-id] '[titel]' — soll das hier integriert werden, oder sind das unterschiedliche Ansaetze?"

5. Fasse zusammen: "Projekt: **[Name]**, Stack: **[Stack]**, Offene Beads: **[Anzahl]**. Lass uns dein Vorhaben planen."

### Phase 1: Ziel

**Falls `$ARGUMENTS` ein Ziel enthaelt:** Ueberspringe diese Phase, verwende das Argument als Ziel.

**Sonst:**
- Frage: "Was willst du erreichen? Beschreib das Ziel in 1-2 Saetzen."
- Warte auf Antwort
- Bestaetige: "Verstanden: **[umformuliertes Ziel]**. Stimmt das?"
- Bei Korrektur: nochmal nachfragen bis klar

### Phase 2: Zerlegung & Task-Level Duplikat-Prüfung

Basierend auf Ziel + Projekt-Kontext, schlage eine Aufteilung vor:

"Ich sehe folgende Teile:
1. **[Komponente A]** — [Kurzbeschreibung]
2. **[Komponente B]** — [Kurzbeschreibung]
3. **[Komponente C]** — [Kurzbeschreibung]

Abhaengigkeiten: B haengt von A ab, C kann parallel zu B.

Passt das? Fehlt etwas? Soll ich etwas anders aufteilen?"

**Regeln:**
- Nutze Projekt-Kontext fuer informierte Vorschlaege
- Jede Komponente sollte grob 1-2 fokussierte Sessions umfassen
- Zeige Abhaengigkeiten zwischen Komponenten wo offensichtlich
- Warte auf User-Feedback und iteriere bei Bedarf
- **Groessen-Check:** Falls eine Komponente zu gross wirkt, weise darauf hin

**Nach Akzeptanz: Task-Level Duplikat-Prüfung**

Prüfe jede geplante Task gegen existierende Beads:
```bash
bd search "<task-keywords>"
```

Falls Duplikate gefunden: "Task **[Name]** überschneidet sich mit [bead-id] — soll diese Task trotzdem angelegt oder kombiniert werden?"

### Phase 3: Constraints + WHY

Fuer jede Komponente, frage nach Einschraenkungen:

"Gibt es fuer **[Komponente A]** Einschraenkungen oder bewusste Entscheidungen? Warum genau dieser Ansatz?"

**Regeln:**
- "Keine besonderen" ist eine valide Antwort
- Constraints die sich aus dem Projekt-Kontext ergeben, proaktiv vorschlagen

### Phase 4: Handshake

Praesentiere den KOMPLETTEN Plan:

```
## Vorhaben: [Ziel]

### Epic: [Titel]
[Ziel-Beschreibung mit Kontext]

### Tasks:
1. **[Task 1]** (P2, feature)
   - [Beschreibung mit Acceptance Criteria]
   - Constraints: [falls vorhanden]
   - Blocked by: —

2. **[Task 2]** (P2, task)
   - [Beschreibung mit Acceptance Criteria]
   - Constraints: [falls vorhanden]
   - Blocked by: Task 1
```

**Break Analysis (Pre-Mortem):**

"Bevor wir das finalisieren — wo koennte das schiefgehen?

**Abhaengigkeitsrisiken:**
- [z.B. Task 2 nimmt an, dass Task 1 ein bestimmtes Interface exponiert]

**Fehlende Annahmen:**
- [z.B. Setzt externes API X voraus — ist der Zugang eingerichtet?]

**Riskanteste Task:**
- [z.B. Task 3 hat die meisten Unbekannten weil...]"

Dann frage: "Stimmt das so? Soll ich Aenderungen vornehmen oder die Beads anlegen?"

**KRITISCH:** Warte auf explizite Bestaetigung.

### Phase 5: Beads erstellen

**Erst nach expliziter Bestaetigung:**

1. Epic erstellen:
   ```bash
   bd create --title="[Epic-Titel]" --type=feature --priority=2 --description="[Beschreibung]"
   ```

2. Sub-Tasks erstellen:
   ```bash
   bd create --title="[Task-Titel]" --type=task --priority=2 --parent=<epic-id> --description="[Beschreibung mit AK]"
   ```

3. Abhaengigkeiten setzen:
   ```bash
   bd dep add <task-id> <blocking-task-id>
   ```

4. Constraints als Notes speichern:
   ```bash
   bd update <id> --notes="Constraints: [...]"
   ```

5. Zusammenfassung: "Epic **[id]** mit **[n]** Sub-Tasks angelegt. `bd ready` zeigt dir was du anfangen kannst."

## Wichtige Verhaltensregeln

- **Sprache:** Durchgehend Deutsch
- **Handshake ist Pflicht:** Niemals Phase 5 ohne explizite Bestaetigung
- **Acceptance Criteria:** Muessen testbar/verifizierbar sein
- **Beads-Commands:** Ausschliesslich `bd` verwenden
- **Keine Dauer-Schaetzungen:** Nur relative Groessen
- **Iterativ:** Bei Unklarheiten lieber nachfragen als annehmen
- **Duplikat-Pruefung:** Zweistufig (Epic-Level in Phase 0, Task-Level in Phase 2)
- **Rollback bei Abbruch in Phase 5:** Bereits erstellte Beads anbieten zu löschen
