# Installation auf Windows

## Voraussetzungen

1. **Claude Code** installiert und im PATH
2. **beads** (`bd`) installiert: `npm install -g beads` oder via [Releases](https://github.com/steveyegge/beads)
3. **Dolt** installiert: https://docs.dolthub.com/introduction/installation
4. **git-cliff** installiert: `winget install orhun.git-cliff` oder via [Releases](https://github.com/orhun/git-cliff/releases)

Optional:
- **claude-updater**: `pip install claude-updater` (Pre-Launch Update-Check)

## Erstinstallation

### 1. Marketplace hinzufügen

In Claude Code eingeben:

```
/plugin marketplace add cognovis/claude-code-plugins
```

### 2. Plugin installieren

```
/plugin install cognovis-workflow@cognovis-claude-code-plugins
```

### 3. Claude Code neu starten

Skills und Agents werden erst beim nächsten Session-Start geladen.

### 4. Installation prüfen

```
/plugin
```

`cognovis-workflow` sollte in der Liste erscheinen. Dann testen:

```
/epic-init
```

Wenn der Dialog startet, ist alles korrekt installiert.

### 5. cld-Launcher einrichten (optional)

Den PowerShell-Launcher aus dem Plugin-Cache kopieren:

```powershell
# Plugin-Cache-Pfad finden
$pluginCache = "$env:USERPROFILE\.claude\plugins\cache"
$cldSource = Get-ChildItem -Path $pluginCache -Recurse -Filter "cld.ps1" | Select-Object -First 1

# In einen Ordner im PATH kopieren
$targetDir = "$env:USERPROFILE\.local\bin"
New-Item -ItemType Directory -Path $targetDir -Force
Copy-Item $cldSource.FullName "$targetDir\cld.ps1"
```

PowerShell-Alias in `$PROFILE` hinzufügen:

```powershell
# Profil öffnen
notepad $PROFILE

# Diese Zeile hinzufügen:
function cld { & "$env:USERPROFILE\.local\bin\cld.ps1" @args }
```

Nutzung:

```powershell
cld                     # Claude Code starten
cld -b <bead-id>        # Bead-Orchestrator in isoliertem Worktree
cld -b <bead-id> -v     # Mit verbose Output
```

## Update

Wenn eine neue Plugin-Version veröffentlicht wurde:

```
/plugin marketplace update cognovis-claude-code-plugins
```

Danach das Plugin neu installieren:

```
/plugin install cognovis-workflow@cognovis-claude-code-plugins
```

Claude Code neu starten, damit die neuen Skills/Agents geladen werden.

### cld-Launcher aktualisieren

Falls der `cld`-Launcher genutzt wird, nach dem Plugin-Update auch die lokale Kopie aktualisieren:

```powershell
$pluginCache = "$env:USERPROFILE\.claude\plugins\cache"
$cldSource = Get-ChildItem -Path $pluginCache -Recurse -Filter "cld.ps1" | Select-Object -First 1
Copy-Item $cldSource.FullName "$env:USERPROFILE\.local\bin\cld.ps1" -Force
```

## Fallback: Manuelle Installation

Falls die Plugin-Installation nicht funktioniert (bekannter Skill-Discovery-Bug):

```powershell
# Plugin-Cache finden
$pluginCache = "$env:USERPROFILE\.claude\plugins\cache"
$pluginDir = Get-ChildItem -Path $pluginCache -Recurse -Filter "cognovis-workflow" -Directory | Select-Object -First 1

# Skills und Agents manuell kopieren
Copy-Item -Recurse "$($pluginDir.FullName)\skills\*" "$env:USERPROFILE\.claude\skills\" -Force
Copy-Item -Recurse "$($pluginDir.FullName)\agents\*" "$env:USERPROFILE\.claude\agents\" -Force
Copy-Item -Recurse "$($pluginDir.FullName)\commands\*" "$env:USERPROFILE\.claude\commands\" -Force
```

Claude Code neu starten.

## Troubleshooting

| Problem | Lösung |
|---------|--------|
| `/epic-init` → "Unknown skill" | Claude Code neu starten. Falls weiterhin: manuelle Installation (siehe Fallback) |
| "Rate limit reached" | API-Limit erreicht — kurz warten und erneut versuchen |
| `bd` nicht gefunden | `bd` installieren und sicherstellen dass es im PATH ist: `bd --version` |
| `cld -b` → "claude not found" | Claude Code muss im PATH sein: `claude --version` |
| Plugin nicht in `/plugin` Liste | Marketplace nochmal adden: `/plugin marketplace add cognovis/claude-code-plugins` |
