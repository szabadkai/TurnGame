// obj_TravelConfirmationDialog Create Event
// Modal confirmation dialog for star map travel

// Dialog state
dialog_visible = false;
dialog_alpha = 0;
dialog_target_alpha = 0;
dialog_state = "CONFIRMATION";

// Landing party selection
landing_party = [];
max_landing_party_size = 4;

// System information to display
system_info = {};
pending_travel_room = -1;
pending_system_id = "";
pending_target_scene = "";

// Dialog dimensions and positioning
dialog_width = 320;
dialog_height = 180;
dialog_x = 0;
dialog_y = 0;

// Visual settings
dialog_background_color = c_black;
dialog_background_alpha = 0.85;
dialog_border_color = c_white;
dialog_text_color = c_white;
dialog_title_color = c_yellow;
dialog_padding = 16;

// Button settings
button_width = 80;
button_height = 30;
button_spacing = 20;
button_y_offset = 120;

// Button states
confirm_button_hover = false;
cancel_button_hover = false;
button_hover_color = c_lime;
button_normal_color = c_gray;

// Animation settings
fade_speed = 0.2;

show_debug_message("TravelConfirmationDialog initialized");

// Show confirmation dialog
function show_travel_confirmation(system_data, target_room) {
    dialog_visible = true;
    system_info = system_data;
    pending_travel_room = target_room;
    dialog_target_alpha = 1.0;
    dialog_state = "CONFIRMATION";
    landing_party = [];
    
    // Center dialog on GUI screen
    dialog_x = (display_get_gui_width() - dialog_width) / 2;
    dialog_y = (display_get_gui_height() - dialog_height) / 2;
    
    show_debug_message("Showing travel confirmation for: " + system_info.name);
}

// Hide confirmation dialog
function hide_travel_confirmation() {
    dialog_target_alpha = 0;
    // dialog_visible will be set to false when alpha reaches 0 in Step event
}

// Confirm travel action
function confirm_travel() {
    hide_travel_confirmation();
    
    if (pending_travel_room != -1 && pending_system_id != "") {
        show_debug_message("Confirming travel to: " + system_info.name);
        
        // Mark as visited if this is the first time
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
            
            // Save this change to the star map state using global function
            mark_star_system_visited(pending_system_id);
        }
        
        // Update current location using global function
        set_current_star_system(pending_system_id);
        
        // Set dialog exit room back to star map
        set_dialog_exit_room(Room_StarMap);
        
        // Set up the dialog scene to start after room transition
        global.pending_scene_id = pending_target_scene;
        show_debug_message("Starting transition to scene: " + pending_target_scene);
        
        // Transition via navigation service (map room → state)
        var _state = GameState.OVERWORLD;
        if (pending_travel_room == Room_Dialog)      _state = GameState.DIALOG;
        else if (pending_travel_room == Room_StarMap) _state = GameState.STARMAP;
        else if (pending_travel_room == Room_MainMenu) _state = GameState.MAIN_MENU;
        scr_nav_go(_state, { scene_id: pending_target_scene });
    }
}

// Cancel travel action
function cancel_travel() {
    show_debug_message("Travel cancelled by user");
    hide_travel_confirmation();
}

// Check if mouse is over confirm button
function is_mouse_over_confirm_button() {
    var button_x = dialog_x + dialog_width/2 - button_width - button_spacing/2;
    var button_y = dialog_y + button_y_offset;
    
    return (mouse_x >= button_x && mouse_x <= button_x + button_width &&
            mouse_y >= button_y && mouse_y <= button_y + button_height);
}

// Check if mouse is over cancel button
function is_mouse_over_cancel_button() {
    var button_x = dialog_x + dialog_width/2 + button_spacing/2;
    var button_y = dialog_y + button_y_offset;
    
    return (mouse_x >= button_x && mouse_x <= button_x + button_width &&
            mouse_y >= button_y && mouse_y <= button_y + button_height);
}
