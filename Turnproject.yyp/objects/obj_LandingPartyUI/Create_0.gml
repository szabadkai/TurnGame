// obj_LandingPartyUI Create Event

// UI state
ui_visible = false;
ui_alpha = 0;
ui_target_alpha = 0;

// System information
system_info = {};
pending_travel_room = -1;
pending_system_id = "";
pending_target_scene = "";

// Landing party selection
landing_party = [];
max_landing_party_size = 4;

// Animation settings
fade_speed = 0.2;

function show_ui(system_data, target_room) {
    ui_visible = true;
    system_info = system_data;
    pending_travel_room = target_room;
    ui_target_alpha = 1.0;
    landing_party = [];
}

function hide_ui() {
    ui_target_alpha = 0;
}

function launch_mission() {
    hide_ui();
    
    if (pending_travel_room != -1 && pending_system_id != "") {
        global.landing_party = landing_party;
        
        // Mark as visited
        var star_system = noone;
        with (obj_StarSystem) {
            if (system_id == other.pending_system_id) {
                star_system = id;
                break;
            }
        }
        
        if (star_system != noone && !star_system.is_visited) {
            star_system.is_visited = true;
            star_system.update_visual_state();
            
            // Mark system as visited using global function
            mark_star_system_visited(pending_system_id);
        }
        
        // Update current location using global function
        set_current_star_system(pending_system_id);
        
        // Set dialog exit room
        set_dialog_exit_room(Room_StarMap);
        
        global.pending_scene_id = pending_target_scene;
        
        var _state = GameState.OVERWORLD;
        if (pending_travel_room == Room_Dialog)      _state = GameState.DIALOG;
        else if (pending_travel_room == Room_StarMap) _state = GameState.STARMAP;
        else if (pending_travel_room == Room_MainMenu) _state = GameState.MAIN_MENU;
        scr_nav_go(_state, { scene_id: pending_target_scene });
    }
}