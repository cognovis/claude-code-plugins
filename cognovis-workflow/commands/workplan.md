# /workplan — Beads-Backlog analysieren und Arbeitsplan vorschlagen

Analysiere das Beads-Backlog und erstelle einen priorisierten Arbeitsplan.

Optional: $ARGUMENTS (z.B. `--label billing`, `--epic mira-xxx`, `--focus P0`)

## Phase 1: Daten sammeln

Führe diese Befehle parallel aus:

```bash
bd stats
bd list --status=in_progress -n 0
bd ready -n 50
bd blocked | head -40
bd list --priority 0 --status=open -n 0
bd list --priority 1 --status=open -n 0
```

Falls `$ARGUMENTS` Label oder Epic Filter enthält, passe die Queries entsprechend an.

## Phase 2: Analyse

Aus den gesammelten Daten:

1. **Dependency-Graph**: Welche Blocker, wenn gelöst, unblockieren am meisten?
2. **Epic-Fortschritt**: Wie weit sind Themenblöcke?
3. **Stale Work**: in_progress ohne Updates seit >2 Tagen?

## Phase 3: Autonomie-Scoring

Bewerte jedes Ready-Bead nach Autonomie-Eignung:

| Signal | Score | Grund |
|--------|-------|-------|
| Hat Akzeptanzkriterien | +2 | Agent weiß wann fertig |
| Hat Description | +1 | Agent hat Kontext |
| Typ bug/task | +1 | Gut abgegrenzt |
| Typ feature/epic | -1 | Braucht oft Entscheidungen |
| P0 | -1 | Zu wichtig für unbeaufsichtigt |
| Leaf-Node (keine Deps) | +1 | Kein Koordinationsrisiko |

Scoring:
- Score >= 3: `cld -b <id>` empfohlen (autonom)
- Score 1-2: Semi-autonom (Ergebnis prüfen)
- Score <= 0: Interaktiv (braucht Mensch)

Für Autonomie-Scoring: Lade Details der Top-10 Ready-Beads via `bd show <id>` (parallel), um Akzeptanzkriterien und Description zu prüfen.

## Phase 4: Output

Formatiere das Ergebnis als:

```markdown
## Workplan — [Projektname]

### Status
Open: X | Closed: Y (Z%) | Blocked: B | Ready: R

### Aktuell in Arbeit
(in_progress Beads mit Zeitstempel)

### Empfohlene nächste Aktionen

#### P0 — Jetzt
| ID | Titel | Autonomie | Grund |

#### P1 — Bald
| ID | Titel | Autonomie | Grund |

### Parallel startbar (cld -b)
```bash
cld -b <id1> &  # "Titel"
cld -b <id2> &  # "Titel"
```

### Kritischer Pfad (Blocker)
| Blocker | Unblockiert | Impact |

### Epic-Fortschritt
| Epic | Done/Total | % |

### Lücken
- [Epic X] fehlt: kein Bead für Schritt Y
```

## Phase 5: Aktionen anbieten

Frage den User:
- Soll ich ein Bead starten? (`bd update <id> --status=in_progress`)
- Parallel-Batch launchen? (mehrere `cld -b` commands)
- Einen Blocker untersuchen?
