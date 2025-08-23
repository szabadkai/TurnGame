# Repository Guidelines

## Project Structure & Module Organization
- `Turnproject.yyp/`: GameMaker Studio 2 project root (open this file in the IDE).
- `objects/`: Gameplay objects and events (`obj_*`). Keep events minimal; call scripts.
- `scripts/`: Reusable GML code (`scr_*`, e.g., `scr_apply_damage`).
- `sprites/`, `fonts/`, `datafiles/`: Art, fonts, and bundled external data.
- `rooms/`: Playable rooms (`rm_*`). Use `rooms/rm_test_*` for temporary tests.
- Root docs: contributor notes and manual tests like `test_*.md`.

## Build, Test, and Development Commands
- Open in IDE: `Turnproject.yyp/Turnproject.yyp` (GMS2 2023+).
- Run: press `F5` to launch the default room.
- Debug: press `F6`; set breakpoints in object events or scripts.
- Build executable: IDE → Build → Create Executable.
- Optional CLI: `gms2 --project Turnproject.yyp/Turnproject.yyp --compile --output build/` (adjust runtime/output for your setup).

## Coding Style & Naming Conventions
- Indentation: 2 spaces; no tabs.
- Variables: `snake_case`; constants/macros: `UPPER_SNAKE_CASE`.
- Resource prefixes: `obj_`, `scr_`, `spr_`, `rm_`, `snd_`, `fnt_`.
- Script names: `verb_noun` (e.g., `scr_draw_healthbar`).
- Keep object events thin; push logic into scripts for reuse and testability.

## Testing Guidelines
- Automated tests: none. Use manual test docs under root (`test_*.md`).
- Temporary test content: `rooms/rm_test_*` with helper `obj_test_*` objects; remove before release.
- Use the Debugger and on‑screen overlays (draw text) for assertions, logging, and variable inspection.

## Commit & Pull Request Guidelines
- Commits: short, imperative summaries (e.g., `fix: prevent null target in attack`). Scope one change per commit.
- PRs: include purpose, linked issues, GIF/screenshot if visual, test steps, and notes on affected rooms/scripts/resources.
- Avoid unrelated asset churn. Keep changes focused and consistent with existing style.

## Security & Configuration Tips
- Do not commit secrets. Treat `datafiles/` as public at runtime.
- Let the IDE manage `Turnproject.yyp` and `Turnproject.resource_order`; avoid manual edits except to resolve merge conflicts.

