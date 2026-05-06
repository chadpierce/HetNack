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

---

## 3. Remove player gender (Option B: skip prompt + gender-neutral text)

The player no longer has a gender. The character-creation prompt for
male/female is gone, all roles are selectable by anyone, and player
pronouns are singular "they / them / their". Monsters keep their own
genders — only the player concept of gender was removed.

### Player pronouns
- `include/you.h` — `uhe()`, `uhim()`, `uhis()` macros now expand to
  the literal strings `"they"`, `"them"`, `"their"`. The old definitions
  indexed `genders[flags.female]`. Verb agreement may be off in a few
  third-person sentences ("they hits") since most NetHack text is
  second-person ("you hit") and isn't affected.

### Role gender restrictions
- `src/role.c` — every role's `allow` field had `ROLE_FEMALE` removed:
  - All roles that previously allowed both (`ROLE_MALE | ROLE_FEMALE`)
    now allow only `ROLE_MALE`. Because no role permits gender 1, the
    gender-selection menu sees a single valid option and is skipped.
  - The Fighter role (formerly Valkyrie) had `ROLE_FEMALE` standalone;
    swapped to `ROLE_MALE` so the role is still selectable.
  - The same edit pass affected race `allow` flags. Races now also
    list only `ROLE_MALE`. Harmless: races aren't picked by gender,
    and the player gender is fixed at 0 anyway.

### Rank and role-name alternates
- `src/role.c` — every gendered alternate `{ "X", "Y" }` rank or role
  name was reduced to `{ "X", 0 }`. Examples: `{ "Lord", "Lady" }` ->
  `{ "Lord", 0 }`; `{ "Hero", "Heroine" }` -> `{ "Hero", 0 }`;
  `{ "Priest", "Priestess" }` (also a role name) -> `{ "Priest", 0 }`.
  Since `flags.female` is always 0, the alternate field was never
  reachable; this is a cleanup so the source matches what runs.

### Character description text
- `src/role.c` — character preview/confirmation strings ("`<name>` the
  `<alignment>` `<gender>` `<race>` `<role>`") had the gender field
  removed. Output is now "`<name>` the `<alignment>` `<race>` `<role>`",
  e.g., "Tester the lawful human Fighter".
- `src/end.c` — death-screen header: dropped the gender adjective from
  the "name, alignment gender race role" summary line.
- `src/polyself.c` — polymorph livelog fallback: replaced
  `genders[flags.female].adj` with `gu.urace.adj` so the message reads
  "polymorphed into a human <rank>" instead of "a male <rank>".

### Existing safety net
- The validator at `src/role.c` lines 2010-2015 already flips
  `flags.female` if it isn't valid for the chosen role/race. With
  `ROLE_FEMALE` gone everywhere, gender 1 is invalid, so the validator
  forces `flags.female = 0` no matter what the user passed (e.g.,
  `-gFem`, `OPTIONS=gender:female`, or a save file from before).

### Intentionally NOT changed
- The `genders[]` table in `src/role.c` is left intact. Monster gender
  still uses it via `mhe()`/`mhim()`/`mhis()`.
- The `flags.female` field itself remains in the flag struct — it's
  read by polymorph code, save/bones file naming, hi-score gendcode,
  egg-laying mechanics, and an artifact hallucination message
  (`src/artifact.c`). All of these continue to work with `flags.female`
  pinned to 0.
- The "Demigod" / "Demigoddess" ascension title in `src/end.c:1424`
  still branches on `flags.female`; with the field pinned to 0, every
  ascension is a "Demigod". Acceptable as a non-gendered noun.
- Niche polymorph descriptions ("male foo" / "female foo") still
  appear when polymorphed into a monster whose entry has neither
  `is_male` nor `is_female` set; those describe the monster form, not
  the player.

### Verification
- `make` builds cleanly (had to `rm src/role.o` once to defeat the
  vboxfs clock-skew make-up-to-date check; not a code issue).
- Game start no longer prompts for gender — goes straight from role to
  race to alignment.
- Confirmation line shows "Tester the lawful human Fighter" with no
  male/female word.

---

## 4. Remove eight roles (keep only Wizard, Fighter, Rogue, Ranger, Priest)

Removed Archeologist, Barbarian, Caveman, Healer, Knight, Monk,
Samurai, and Tourist as playable roles. The role-selection menu now
shows exactly five options.

### Role table
- `src/role.c` — deleted the eight role entries from the `roles[]`
  initializer (each role spans ~40 lines: display name, rank titles,
  pantheon gods, filecode, quest text keys, monster IDs for
  leader/nemesis/intermediates, quest artifact, allow-mask, base
  attributes, hit-point/energy progression, attribute spec).
- `include/hack.h` — `NUM_ROLES` reduced from 13 to 5. This sizes
  the `roles[]` array, the `role_filter.roles[]` array, and any other
  per-role lookup table.

### Quest level files
- `dat/{Arc,Bar,Cav,Hea,Kni,Mon,Sam,Tou}-{fila,filb,goal,loca,strt}.lua`
  removed (40 files via `git rm -f`). Quest files are picked up by the
  build's `???-*.lua` wildcard, so leaving them would have packaged
  unreachable content into `nhdat`. Remaining quest files: Fig (Fighter),
  Pri (Priest), Ran (Ranger), Rog (Rogue), Wiz (Wizard) — five roles.

### Plus a leftover from task #3
- `src/role.c` `build_plselection_prompt` — the auto-pick prompt was
  still building the string "race, role, gender and alignment". The
  whole gender-handling block in that function was replaced with a
  HetNack note and `(void)` casts to silence unused-variable
  warnings. Prompt now reads "race, role and alignment".

### Intentionally NOT changed
- The monster definitions in `include/monsters.h` for quest leaders,
  nemeses, and quest-line intermediates of the removed roles
  (`PM_LORD_CARNARVON`, `PM_PELIAS`, `PM_SHAMAN_KARNOV`, `PM_HIPPOCRATES`,
  `PM_KING_ARTHUR`, `PM_GRAND_MASTER`, `PM_LORD_SATO`, `PM_TWOFLOWER`,
  and their hostile counterparts and quest minions). They remain as
  monsters that can appear normally; the player just can't be them.
- The corresponding artifacts (`ART_HEART_OF_AHRIMAN`,
  `ART_PLATINUM_YENDORIAN_EXPRESS_CARD`, `ART_TSURUGI_OF_MURAMASA`,
  etc.) — they roll as random artifacts now.
- Starting-inventory tables in `src/u_init.c`
  (`Archeologist[]`, `Barbarian[]`, …) — left in place as dead code.
  No `roles[]` entry references them now, so the switch arm that calls
  them is unreachable. Cleanup is optional and can come later.
- Encyclopedia entries in `dat/data.base` for the removed classes —
  kept; the entries describe the concept (e.g., samurai history),
  which is independent of whether the player can choose them.
- Quest-leader / nemesis / quest-class names in `dat/themerms.lua`
  random-monster lists — kept (they refer to monsters, which exist).

### Verification
- `make` builds cleanly.
- Interactive role menu shows exactly five entries: Priest, Rogue,
  Ranger, Fighter, Wizard.
- No removed role name appears anywhere in the role-selection flow.

---

## 5. Finish stripping gender from character-creation UI + missed welcome strings

Follow-up to task #3. The first pass left several gender artifacts in
the interactive character-creation screens: a "gender:" row in the
status panel, a "Pick gender first" navigable entry on the role/race/
alignment menus, and the word "gender" in the auto-pick prompt.

### Character-creation UI
- `src/role.c` `role_selection_prolog()` — removed the `Sprintf(buf,
  "%12s ", "gender:") ... putstr(...)` block. The status panel now
  shows only name / role / race / alignment.
- `src/role.c` `role_menu_extra()` — early-return `if (which ==
  RS_GENDER)` so the function never appends a gender entry to the
  role/race/alignment menus.
- `src/role.c` `build_plselection_prompt()` — removed the
  `if (gr.role_pa[BP_GEND]) Strcat(buf, "gender")` block.
  `BP_GEND` was already never set after task #3, but this kills the
  trailing "gender" word for good.

### Welcome message rename (missed during task #1)
- `src/allmain.c` — `"welcome to NetHack!"` / `"welcome back to NetHack!"`
  -> `"welcome to HetNack!"` / `"welcome back to HetNack!"`.
- `src/mail.c` — junk-mail template `"Welcome to NetHack."` ->
  `"Welcome to HetNack."`.

### Verification
- Auto-pick prompt: "Shall I pick character's race, role and alignment
  for you?" — no "gender".
- Confirmation summary: "chad the lawful dwarven Fighter" — no
  male/female adjective.
- Interactive flow goes role -> race -> alignment, with no gender
  screen and no gender row in the status panel.
- In-game greeting: "Velkommen chad, welcome to HetNack! You are a
  lawful dwarven Fighter."
