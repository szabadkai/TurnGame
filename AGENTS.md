# Repository Guidelines

## Project Structure & Module Organization
- `Turnproject.yyp/`: GameMaker Studio project root.
- `objects/`: Gameplay objects and events (`obj_*`).
- `scripts/`: Reusable GML code (`scr_*`).
- `sprites/`, `fonts/`, `datafiles/`: Art, fonts, external data.
- `rooms/`: Playable rooms (`rm_*`).
- Root docs: contributor notes and manual tests (e.g., `test_*.md`).

## Build, Test, and Development Commands
- Open in IDE: open `Turnproject.yyp/Turnproject.yyp` with GameMaker Studio 2 (2023+).
- Run locally: press F5 (Run) to launch the default room.
- Debug: press F6 (Debug) and set breakpoints in object events/scripts.
- Build executable: IDE → Build → Create Executable.
- Optional CLI (if configured): `gms2 --project Turnproject.yyp/Turnproject.yyp --compile --output build/` (adjust runtime and output to your setup).

## Coding Style & Naming Conventions
- Indentation: 2 spaces, no tabs.
- Variables: `snake_case`; constants/macros: `UPPER_SNAKE_CASE`.
- Resource prefixes: `obj_` (objects), `scr_` (scripts), `spr_` (sprites), `rm_` (rooms), `snd_` (audio), `fnt_` (fonts).
- Script names: verb_noun (e.g., `scr_apply_damage`). Keep object events thin; call scripts.

## Testing Guidelines
- Automated tests: none yet. Use manual test docs under root (e.g., `test_level_system.md`).
- Add temporary test rooms as `rooms/rm_test_*` with helper `obj_test_*` objects; remove before release.
- Use the Debugger and on-screen overlays for assertions/logs during runs.

## Commit & Pull Request Guidelines
- Commits: short, imperative summaries (matches history: “weapon switching”, “leveling system”). Example: `fix: prevent null target in attack`.
- PRs: include purpose, linked issues, GIF/screenshot if visual, test steps, and notes on affected rooms/scripts/resources.
- Scope: one feature/fix per PR; avoid unrelated asset churn.

## Security & Configuration Tips
- Do not commit secrets; `datafiles/` is bundled—treat it as public at runtime.
- Let the IDE manage `Turnproject.yyp` and `Turnproject.resource_order`; avoid manual edits unless resolving merge conflicts.
