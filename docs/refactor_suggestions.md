# Refactoring Suggestions & Rationale

Below are targeted, low-risk refactors to improve clarity, consistency, and maintainability without changing gameplay.

## High-Impact Targets
- Direction handling: `scripts/move/move.gml` uses `=` in conditionals. Replace chain of `if` with `switch` on an enum (e.g., `Dir.UP/DOWN/LEFT/RIGHT`) and use constants for `TILE_SIZE` and `obj_c_turn.turn_length/turn_speed`. Reduces bugs and duplication.
- Dice & logging utilities: Centralize dice rolling and logging (e.g., `scr_dice_roll("2d6")`, `scr_log(msg)`) used by `weapon_system.gml`. Removes ad‑hoc `roll_d20` vs `roll_weapon_damage` inconsistencies and repeated `variable_global_exists("combat_log")` checks.
- Dialog file IO: `scripts/dialog_system/dialog_system.gml` repeats path probing and JSON parsing across functions. Extract `scr_load_json_from_paths(paths[])` and store state in `global.dialog = { scene, node, state, base_path }`. Cuts duplication and failure modes.
- Turn manager checks: `objects/obj_TurnManager/Step_0.gml` mixes debug keys and periodic checks via `get_timer() mod ...`. Move to `scr_turn_debug_shortcuts()` and `scr_check_combat_end()`; schedule with an `Alarm` for determinism and simpler profiling.

## Consistency & Data Hygiene
- Weapon database: Replace manual `global.weapons[fixed_index]` with `array_push` or a map keyed by `id/name`. Avoid special-casing names (e.g., Rapier) by relying on `special_type`.
- Magic numbers/strings: Hoist to constants: `TILE_SIZE = 16`, `LAYER_COLLISION = "Tiles_Col"`, dialog states, menu states, weapon ranges. Keep them in one `scr_enums`/constants script.
- Object event thinness: Split large Step handlers (e.g., `obj_DialogManager`) into small scripts: `scr_dialog_handle_selection`, `scr_dialog_handle_choice_input`, `scr_dialog_progress`. Improves testability and reuse.
- Save system: Add `save_version` and `schema` guard; factor file read/write into helpers reused by dialog loader. Keep autosave triggers explicit (e.g., on level‑up, room change), not every frame check.

## Why This Is A Good Idea
- Fewer bugs: Enums/constants eliminate equality/assignment mistakes and magic numbers.
- Easier changes: Central utilities for dice, logging, and IO reduce edit‑surface.
- Clear ownership: Moving logic from events to scripts matches our style guide and improves readability.
- Safer persistence: Versioned saves prevent silent load failures as features evolve.
- Maintainable content: Data‑driven weapons/dialogs let designers expand without code churn.

## Deeper Structural Refactors (Architecture)

### 1) Resource Tree Layout (GMS2 conventions)
- Top-level folders: `Core/` (constants, utils), `Systems/` (turn, save, dialog, starmap, AI), `Features/` (Combat, Dialog, StarMap), `UI/`, `Content/` (datafiles), `Objects/Actors`, `Objects/Managers`, `Rooms/`.
- Examples: move `scripts/xp_system/*` to `Systems/XP/`, `scripts/weapon_system/*` to `Systems/Combat/Weapons/`, `objects/obj_TurnManager` to `Objects/Managers/TurnManager`.
- Benefits: predictable discovery, smoother onboarding, fewer circular references.

### 2) Game State & Room Navigation
- Introduce `global.game = { state, prev_state, payload, room_stack[] }` with explicit states: `MainMenu`, `Overworld`, `Combat`, `Dialog`, `Starmap`.
- Create `Systems/Navigation/scr_nav_go(state, payload)` and `scr_nav_back()` that map states → rooms and handle fades, safe cleanup, and payload passing via a transient `global.nav_payload`.
- Make a persistent `obj_GameController` in a tiny bootstrap room. All rooms include only domain managers (e.g., `obj_TurnManager` when in Combat). Controller owns state transitions.

### 3) Turn & Combat Pipeline
- Replace ad-hoc checks in `obj_TurnManager` with a phase machine: `BEGIN → PLAYER_TURN → ENEMY_TURN → RESOLVE → END` implemented in `Systems/Turn/scr_turn_update()`.
- Event bus: minimal dispatcher `scr_event_emit(event, data)` and subscriptions for combat log, UI, audio. Decouples systems from direct globals and reduces `variable_global_exists` checks.
- Data-driven actions: define action structs `{id, ap_cost, range, effect}`. Weapons select actions; pipeline resolves effects uniformly (hit check, damage, specials).

### 4) Save/Load Architecture
- Single SaveService with versioning: `{ version, player, world, starmap, dialog, inventory, meta }`. Each subsystem registers `scr_save_<system>()` and `scr_load_<system>(data)` with the service, called from `SaveService.save()`/`load()`.
- Migrations: `scr_save_migrate(data)` to lift older versions forward. Store `last_room/state` and use Navigation to restore, not raw room instance dumps.
- Slots + autosave: explicit triggers (level-up, mission complete, room enter) through the event bus; no per-frame checks.

### 5) Dialog & Content System
- Keep JSON in `datafiles/dialogs/` with a schema. Add a validation helper `scr_json_validate(schema, data)` for early error reporting.
- Dialog runtime struct: `global.dialog = { scene, node_id, state, vars, index[] }`. `obj_DialogManager` delegates to `Systems/Dialog/*` functions; Step only orchestrates.
- Unify file IO: `scr_file_read_text(paths[])` used by both dialog and save. Remove path-probing duplication.

### 6) Input, UI, and Camera
- Input map: `Systems/Input/scr_input_is(action)` with bindings `{ Up: [vk_up, 'W'], ... }`. Objects query actions, not keys.
- UI layers: a single `obj_UIRoot` draws HUD; feature UIs are components called from it. Prefer 9-slice panels and `draw_gui` scaling. Keep fonts in `UI/Fonts` and text helpers in `Systems/UI/Text`.
- Camera service: `scr_cam_follow(target)` + shake/zoom utilities; avoids duplicate camera math in objects.

### 7) Data-Driven Registries
- Weapons, enemies, star systems registered in `Systems/Registry/*` with constructor helpers. Avoid magic indices; use keys and tags.
- Example: `Registry.weapons['pistol'] = { tags: ['ranged','dex'], range: 4, ... }` then compute stats via shared rules.

### 8) Testing & Debugging
- Dedicated `rooms/rm_test_*` and `Objects/Test/obj_TestHarness` that can spawn scenarios via commands.
- In-game debug overlay toggled by a build flag; shows FPS, turn phase, selected entity, last event.

### 9) Migration Plan (Phased)
- Phase 1: Add `Core/constants`, `Systems/Navigation`, `SaveService` skeleton; wire `obj_GameController`.
- Phase 2: Move Turn flow into `Systems/Turn`; emit events for log/UI; fix `scripts/move` conditional bug.
- Phase 3: Centralize file IO; refactor Dialog to runtime struct; validate JSON.
- Phase 4: Registry for weapons and star systems; remove fixed indices.
- Phase 5: Input map + UI root + camera service; prune object Step code.

Short pitch: This structure mirrors common GMS2 large-project practices—persistent controller, state-driven rooms, system scripts, and data-first content. It reduces coupling, makes saves durable via versioned subsaves, and lets designers extend content without touching logic.

## Implemented So Far (Incremental)
- Direction system: `Dir` enum and `move(direction)` switch are in place; fixed equality bug patterns and standardized movement constants.
- Layer constants: added `LAYER_COLLISION` macro and replaced hardcoded "Tiles_Col" in `weapon_system.gml` and `character_base`.
- Logging utility: added `scr_log(msg)` used in combat helpers; removes duplicate `global.combat_log` checks.
- Dice hygiene: corrected `damage_text_to_value` to use `==` and support more dice.
- Save versioning: writes `save_version: 1` and checks on load with a migration hook; slot info shows version.
- Stability fix: `obj_StarSystem` now resolves `obj_TravelConfirmationDialog` via `asset_get_index` and falls back gracefully.
- Event wiring: centralized `scr_log` now emits via `event_bus`; autosave requests are emitted on level-up and combat victory and handled in `obj_GameController`.

## Next Steps (Phase 1 scaffolding)
- Navigation service: added `nav_service` with `scr_nav_go/scr_nav_back` and `scr_nav_room_for_state`; scaffolded `obj_GameController` (persistent) to own state.
- Event bus: added `event_bus` with `scr_event_emit/scr_event_subscribe` for decoupled notifications.
- Shared IO: added `file_io` helpers to unify text read/write for Save and Dialog.
- Registries: added `registry_weapons` scaffold for ID-keyed weapons; integration will be incremental.

Notes: The new resources are scaffolded and safe—no room edits yet. To activate `obj_GameController`, drop one instance in your bootstrap room (e.g., `Room_MainMenu`) via the IDE so it persists across rooms.
