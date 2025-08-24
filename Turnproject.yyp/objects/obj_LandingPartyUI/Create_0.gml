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
            
            var starmap_manager = instance_find(obj_StarMapManager, 0);
            if (starmap_manager != noone) {
                starmap_manager.mark_system_visited(pending_system_id);
            }
        }
        
        // Update current location
        var starmap_manager = instance_find(obj_StarMapManager, 0);
        if (starmap_manager != noone) {
            starmap_manager.set_current_system(pending_system_id);
        }
        
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