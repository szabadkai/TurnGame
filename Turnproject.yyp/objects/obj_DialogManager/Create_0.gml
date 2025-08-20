// obj_DialogManager Create Event
// Initialize dialog system and manage dialog state

// Initialize dialog system
init_dialog_system();
init_dialog_state();

// Load dialog scene index from JSON
load_dialog_index();

// Dialog manager state
current_scene_id = "";
ui_manager = noone;
dialog_ui = noone;
current_choice_buttons = [];

// UI properties
dialog_active = false;
transition_alpha = 1;
transition_speed = 0.05;

// Choice selection
selected_choice_index = 0;
choice_count = 0;

// Debug mode
dialog_debug = true;

// Preview caching
preview_scene_id = "";
preview_sprite = noone;

show_debug_message("DialogManager initialized");
