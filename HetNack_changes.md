# HetNack Changes

A log of changes made to the upstream NetHack 5.0 source as part of the
HetNack fork. Baseline: NetHack 5.0 commit `8fcc15a86`.

---

## 1. Rename NetHack -> HetNack (user-visible strings + binary)

Renamed user-visible occurrences of "NetHack" to "HetNack" and the binary
name from `nethack` to `hetnack`. The original NetHack copyright credit
is preserved on the title screen as required by the license.

### Build system (binary now `hetnack`)
- `sys/unix/Makefile.top` — `GAME = nethack` -> `hetnack`
- `sys/unix/Makefile.src` — `GAME = nethack` -> `hetnack`
- `sys/unix/Makefile.doc` — `GAME = nethack` -> `hetnack`

### Title / version banner
- `include/patchlevel.h` — `COPYRIGHT_BANNER_A` now reads
  `HetNack (based on NetHack, Copyright 1985-2026)`. The line below
  ("By Stichting Mathematisch Centrum and M. Stephenson.") is unchanged.
- `src/mdlib.c` — version-line format string `"%s NetHack%s Version ..."`
  -> `"%s HetNack%s Version ..."`. Output now reads
  `Unix HetNack Version 5.0.0-0 ...`.

### In-game strings (C source)
- `src/files.c` — fallback game name in `gamename`
- `src/version.c` — fallback `hname` literal
- `src/allmain.c` — hallucination quip "NetHack is filmed in front of..."
- `src/artifact.c` — fallback "rumors file closed for renovation" message
- `src/rumors.c` — same fallback message
- `src/cfgfiles.c` — "NetHack Defaults" config-file label
- `src/cmd.c` — `M-v` (extended version) command description
- `src/mdlib.c` — Lua-info help text and Library Windowing Shim label

### Help / data files (user-visible text)
- `dat/help` — 6 occurrences (intro and command-list text)
- `dat/cmdhelp` — 1 occurrence (M-v description)
- `dat/keyhelp` — 13 occurrences (keystroke handling text)
- `dat/rumors.fal` — 15 occurrences (false rumors that name the game)

### Intentionally NOT changed
- File-header `/* NetHack 5.0 ... */` comments and `$NHDT-` revision
  metadata throughout `src/` and `include/`.
- Original NetHack copyright credits, license text, and the
  "By Stichting Mathematisch Centrum and M. Stephenson." attribution.
- Internal symbols (`NETHACK_GIT_SHA`, `NETHACK_GIT_BRANCH`, etc.).
- Config-file path conventions (`.nethackrc`, `nethack.cnf`, `nethackini`).
- The historical 1987 reference string in `src/date.c`.
- Manpage source filename `sys/unix/nethack.6` (installed manpage takes
  the `$(GAME)` name automatically via Makefile substitution).
- All `dat/*.txt` flavor files whose only "NetHack" mentions were file
  headers (`bogusmon.txt`, `engrave.txt`, `epitaph.txt`).

### Verification
- `make all` builds cleanly; produces `src/hetnack` binary.
- `./hetnack --version` outputs `Unix HetNack Version 5.0.0-0 ...`.

---

## 2. Rename role Valkyrie -> Fighter

Renamed the player role display name "Valkyrie" to "Fighter" and the
filecode "Val" to "Fig". The mechanics are unchanged: the role still
uses Norse mythology, the same starting inventory, intrinsics, quest
leader (the Norn), nemesis (Lord Surtur), and quest artifact (Orb of
Fate). The valkyrie *monster type* (`PM_VALKYRIE`) is intentionally
left alone — it can still appear as an NPC and the role's underlying
implementation continues to use it.

### Source
- `src/role.c` — role display name `"Valkyrie"` -> `"Fighter"`,
  filecode `"Val"` -> `"Fig"`.

### Quest level files (renamed via `git mv`)
- `dat/Val-fila.lua` -> `dat/Fig-fila.lua`
- `dat/Val-filb.lua` -> `dat/Fig-filb.lua`
- `dat/Val-goal.lua` -> `dat/Fig-goal.lua`
- `dat/Val-loca.lua` -> `dat/Fig-loca.lua`
- `dat/Val-strt.lua` -> `dat/Fig-strt.lua`
- File-header comments in each updated to read `-- HetNack Fighter ...`
  with the new filename. Engine picks them up via the existing
  `???-*.lua` wildcard in `sys/unix/Makefile.top`.

### Help / data
- `dat/usagehlp` — `-p` example changed from `Val`/`Valkyrie` to
  `Fig`/`Fighter`.
- `include/optlist.h` — role example in option help changed from
  `Barbarian, Valkyrie` to `Wizard, Fighter`.
- `dat/data.base` — rank-table heading `Valkyrie ranks` -> `Fighter
  ranks`; added `fig* ranks` and `fighter` lookup keys (existing
  `valkyrie` key kept for monster lore).

### Intentionally NOT changed
- The `valkyrie` monster (`PM_VALKYRIE`, `include/monsters.h`) —
  remains a distinct NPC the player can encounter.
- Norse-mythology references attached to the role (Tyr/Odin/Loki gods,
  the Norn, Lord Surtur, fire ants/giants, Mjollnir handling).
- `ROLE_FEMALE` flag on the role — to be addressed in the gender-
  removal change so that the player isn't forced female.
- Internal C symbol `Valkyrie[]` (starting-inventory table) and other
  source comments referencing valkyrie mechanics.
- Lore/encyclopedia entries about valkyries in `dat/data.base`,
  T-shirt slogans in `src/read.c`, fake-player text in `src/mplayer.c`.
- Mac Xcode project (`sys/unix/NetHack.xcodeproj/project.pbxproj`) and
  Windows makefiles (`sys/windows/GNUmakefile`,
  `sys/windows/Makefile.nmake`) still list `Val-*.lua` by name; sync
  if those platforms are ever targeted.

### Verification
- `make` builds cleanly.
- Game banner displays `HetNack (based on NetHack, Copyright 1985-2026)`.
- Binary accepts `-pFig` on the command line (Fighter role recognized).
