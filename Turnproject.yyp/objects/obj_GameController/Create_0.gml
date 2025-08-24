// Minimal event bus

function scr_event_bus_init() {
  if (!variable_global_exists("events")) {
    global.events = {};
  }
}

function scr_event_subscribe(_name, _handler) {
  scr_event_bus_init();
  if (!variable_struct_exists(global.events, _name)) {
    global.events[$ _name] = [];
  }
  array_push(global.events[$ _name], _handler);
}

function scr_event_emit(_name, _data) {
  scr_event_bus_init();
  if (!variable_struct_exists(global.events, _name)) return;
  var _list = global.events[$ _name];
  for (var i = 0; i < array_length(_list); i++) {
    var _fn = _list[i];
    try {
      _fn(_data);
    } catch (e) {
      show_debug_message("Event handler error for '" + string(_name) + "': " + string(e));
    }
  }
}



// Helper for logging
function scr_log(_message) {
  scr_event_emit("log", _message);
}

// Helper for autosave
function scr_autosave(_reason) {
  scr_event_emit("autosave", {reason: _reason});
}
// Persistent controller for global init and navigation/event bus

// Ensure single instance
if (instance_number(obj_GameController) > 1) {
  instance_destroy();
  return;
}

persistent = true;

// Initialize services
scr_event_bus_init();
scr_nav_init();

// Infer initial state from current room (no transition)
switch (room) {
  case Room_MainMenu: global.nav.state = GameState.MAIN_MENU; break;
  case Room_StarMap:  global.nav.state = GameState.STARMAP;   break;
  case Room_Dialog:   global.nav.state = GameState.DIALOG;    break;
  default:            global.nav.state = GameState.OVERWORLD; break;
}
// Subscribe to log and autosave events
scr_event_subscribe("log", function(_data) {
  var _msg = (variable_struct_exists(_data, "message") ? _data.message : string(_data));
  if (variable_global_exists("combat_log")) {
    global.combat_log(string(_msg));
  } else {
    show_debug_message(string(_msg));
  }
});

scr_event_subscribe("autosave", function(_data) {
  // centralize autosave policy here
  try {
    auto_save_progress();
    var _reason = variable_struct_exists(_data, "reason") ? _data.reason : "unknown";
    show_debug_message("Autosave event processed (reason: " + string(_reason) + ")");
  } catch (e) {
    show_debug_message("Autosave event failed: " + string(e));
  }
});

// Subscribe to save/load events
scr_event_subscribe("save_data_loaded", function(_data) {
  try {
    apply_loaded_save_data();
    show_debug_message("Save data application completed");
  } catch (e) {
    show_debug_message("Failed to apply save data: " + string(e));
  }
});

scr_event_subscribe("room_initialized", function(_data) {
  try {
    if (progress_dirty && room != Room_MainMenu) {
      auto_save_progress();
    }
  } catch (e) {
    show_debug_message("Room initialization auto-save failed: " + string(e));
  }
});

// === CONSOLIDATED GAMEMANAGER FUNCTIONS ===
// Auto-save configuration
auto_save_enabled = true;

// Progress tracking flags
progress_dirty = false;
last_save_time = 0;
save_in_progress = false;

// Initialize global systems function
function initialize_global_systems() {
    show_debug_message("Initializing global game systems...");
    
    // Initialize dialog system
    init_dialog_system();
    
    // Initialize star map system only if it doesn't exist
    if (!variable_global_exists("star_map_state")) {
        init_star_map();
    }
    
    // Initialize weapon system
    init_weapons();
    
    // Initialize global game settings if they don't exist
    if (!variable_global_exists("game_settings")) {
        global.game_settings = {
            difficulty: 1,
            auto_save: true,
            sound_enabled: true,
            music_enabled: true
        };
    }
    
    // Initialize progress tracking flags
    if (!variable_global_exists("game_progress")) {
        global.game_progress = {
            sessions_played: 0,
            total_playtime: 0,
            systems_unlocked: 1,
            dialogs_completed: 0,
            combats_won: 0,
            last_checkpoint: "system_001"
        };
    }
    
    show_debug_message("Global systems initialized");
}

// Auto-save game progress at key moments
function auto_save_progress() {
    if (!auto_save_enabled || save_in_progress) {
        return false;
    }
    
    // Don't auto-save if we're still in the initialization phase
    if (!variable_global_exists("star_map_state") || room == Room_MainMenu) {
        show_debug_message("Auto-save skipped - still initializing");
        return false;
    }
    
    if (progress_dirty) {
        save_in_progress = true;
        // Use active save slot instead of hardcoded slot 0
        var slot_to_use = variable_global_exists("active_save_slot") ? global.active_save_slot : 1;
        var success = save_game_to_slot(slot_to_use);
        
        if (success) {
            progress_dirty = false;
            last_save_time = get_timer();
            show_debug_message("Auto-save completed successfully");
        } else {
            show_debug_message("Auto-save failed!");
        }
        
        save_in_progress = false;
        return success;
    }
    
    return false;
}

// Mark progress as needing save
function mark_progress_dirty() {
    progress_dirty = true;
    show_debug_message("Progress marked as dirty - needs saving");
}

// Initialize systems after brief delay
alarm[0] = 1;