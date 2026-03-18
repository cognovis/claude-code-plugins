# Bead Sizing & Slicing Guide

Regeln fuer optimale Bead-Groesse und -Struktur.

## Kern-Prinzip

> "Agents work best at the BEGINNING of their context windows."

**Fine-grained tasks** = bessere Agent-Entscheidungen + guenstigere Sessions.

## Sizing-Regeln

### 1. Ein Bead = Ein Concern

**Faustregel:** Wenn du "und" brauchst um den Scope zu beschreiben, ist es zu gross.

| Schlecht | Gut |
|----------|-----|
| "PVS Detection + CLI + GUI" | 3 separate Beads |
| "Feature X fuer alle Plattformen" | Je 1 Bead pro Plattform |
| "Backend + Frontend + Tests" | Je 1 Bead pro Layer |

### 2. Kohaesion bewahren

Zusammengehoeriges gehoert zusammen:
- Alle CLI-Commands fuer ein Feature → 1 Bead
- Alle Windows-spezifischen Checks → 1 Bead
- Alle macOS-spezifischen Checks → 1 Bead

**Nicht aufteilen** wenn:
- Gleiche Plattform
- Gleiche APIs
- Gleicher fachlicher Kontext

### 3. Layer trennen

```
Core Logic    →  1 Bead (die Kernfunktion)
CLI Layer     →  1 Bead (Commands die Core nutzen)
GUI Layer     →  1 Bead (UI die Core nutzt)
API Layer     →  1 Bead (Endpoints die Core nutzen)
```

### 4. Plattformen trennen

```
Feature X (Windows)  →  1 Bead
Feature X (macOS)    →  1 Bead
Feature X (Linux)    →  1 Bead
```

### 5. Dependencies explizit machen

```
Core (keine Deps)
  ↓
Layer 1 (depends on Core)
  ↓
Layer 2 (depends on Layer 1)
```

## Checklisten

### Vor `bd create`

```
[ ] Scope in einem Satz OHNE "und" beschreibbar?
[ ] Alles fuer gleiche Plattform?
[ ] Alles im gleichen Layer (Core/CLI/GUI)?
[ ] Fine-grained genug fuer einen Subagent?
[ ] Dependencies klar definiert?
```

### Wann aufteilen

```
[ ] Scope enthaelt "und" oder "sowie"
[ ] Mehrere Plattformen betroffen
[ ] Mehrere Layer gemischt (Core + CLI + GUI)
[ ] Subagent hatte Kontextprobleme
[ ] Verschiedene Teams koennten parallel arbeiten
```
