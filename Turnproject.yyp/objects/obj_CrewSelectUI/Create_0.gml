// obj_CrewSelectUI Create Event

// Initialize crew system
init_crew_system();

// Landing party selection
landing_party = array_create(0); // Initialize empty array
max_landing_party_size = 5;
ui_width = 450; // Increased width for better text fitting
ui_height = 400; // Increased height to accommodate 10 crew members

// Position the UI in the center of the screen
x = display_get_gui_width() / 2 - ui_width/2;  // Center horizontally
y = display_get_gui_height() / 2 - ui_height/2; // Center vertically

// UI state
ui_visible = true;
ui_alpha = 1;
ui_target_alpha = 1;

// System information
system_info = {};
pending_travel_room = -1;
pending_system_id = "";
pending_target_scene = "";

// Animation settings
fade_speed = 0.2;

function show_ui(system_data, target_room) {
    ui_visible = true;
    system_info = system_data;
    pending_travel_room = target_room;
    ui_target_alpha = 1.0;
    landing_party = array_create(0);
}

function hide_ui() {
    ui_target_alpha = 0;
}

function launch_mission() {
    show_debug_message("launch_mission() called - pending_travel_room: " + string(pending_travel_room) + ", pending_system_id: " + string(pending_system_id));
    hide_ui();
    
    if (pending_travel_room != -1 && pending_system_id != "") {
        show_debug_message("Launch conditions met - proceeding with mission launch...");
        // Convert selected indices to crew IDs
        var available_crew = get_available_crew();
        var selected_crew_ids = array_create(0);
        for (var i = 0; i < array_length(landing_party); i++) {
            var crew_index = landing_party[i];
            if (crew_index >= 0 && crew_index < array_length(available_crew)) {
                selected_crew_ids[array_length(selected_crew_ids)] = available_crew[crew_index].id;
            }
        }
        
        // Use default if none selected
        if (array_length(selected_crew_ids) == 0) {
            selected_crew_ids = get_default_landing_party();
        }
        
        global.landing_party = selected_crew_ids;
        
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