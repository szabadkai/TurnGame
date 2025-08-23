// obj_StarSystem Step Event
// Handle mouse interaction using distance-based detection

// Define interaction radius
var interaction_radius = 20;

// Check if mouse is within interaction range
var mouse_distance = point_distance(x, y, mouse_x, mouse_y);
var was_hovering = hover_state;

if (mouse_distance <= interaction_radius) {
    // Mouse is over this system
    if (!hover_state) {
        // Just entered hover state (works for both locked and unlocked)
        hover_state = true;
        show_debug_message("Mouse entered system: " + system_name + " (Locked: " + string(!is_unlocked) + ")");
        
        // Create appropriate tooltip based on lock status
        var tooltip_info = hover_info;
        if (!is_unlocked) {
            // Create locked system tooltip with teaser information
            tooltip_info = {
                name: system_name,
                type: system_type,
                faction: get_faction_name(faction_control),
                status: "LOCKED",
                threat: threat_level,
                scene_id: "Requires progression to unlock",
                locked_hint: get_unlock_hint()
            };
        }
        
        // Find tooltip manager and show tooltip
        var tooltip_manager = instance_find(obj_TooltipManager, 0);
        if (tooltip_manager != noone) {
            tooltip_manager.show_tooltip(mouse_x, mouse_y, tooltip_info);
        }
    }
    
    // Check for left click
    if (mouse_check_button_pressed(mb_left) && is_unlocked) {
        show_debug_message("Clicked on system: " + system_name + " (Unlocked: " + string(is_unlocked) + ")");
        
        // Play click sound effect (placeholder)
        // audio_play_sound(snd_confirm_click, 1, false);
        
        // Hide tooltip before showing confirmation
        var tooltip_manager = instance_find(obj_TooltipManager, 0);
        if (tooltip_manager != noone) {
            tooltip_manager.hide_tooltip();
        }
        
        // Try to use travel confirmation dialog (asset-checked by name)
        var use_confirmation_dialog = false;
        var confirmation_dialog = noone;
        var dialog_asset = asset_get_index("obj_TravelConfirmationDialog");
        if (dialog_asset != -1) {
            confirmation_dialog = instance_find(dialog_asset, 0);
            if (confirmation_dialog == noone) {
                confirmation_dialog = instance_create_layer(0, 0, "Instances", dialog_asset);
            }
            use_confirmation_dialog = (confirmation_dialog != noone);
        }
        
        if (use_confirmation_dialog) {
            // Prepare system info for confirmation dialog
            var system_data = {
                name: system_name,
                type: system_type,
                faction: get_faction_name(faction_control),
                threat: threat_level,
                scene_id: target_scene
            };
            
            // Show confirmation dialog with travel callback data
            confirmation_dialog.system_info = system_data;
            confirmation_dialog.pending_system_id = system_id;
            confirmation_dialog.pending_target_scene = target_scene;
            confirmation_dialog.show_travel_confirmation(system_data, Room_Dialog);
        } else {
            // Fallback to direct travel (original behavior)
            show_debug_message("Using direct travel - confirmation dialog not available");
            
            // Mark as visited if this is the first time
            if (!is_visited) {
                is_visited = true;
                update_visual_state();
                
                // Save this change to the star map state
                var starmap_manager = instance_find(obj_StarMapManager, 0);
                if (starmap_manager != noone) {
                    starmap_manager.mark_system_visited(system_id);
                }
            }
            
            // Update current location
            var starmap_manager = instance_find(obj_StarMapManager, 0);
            if (starmap_manager != noone) {
                starmap_manager.set_current_system(system_id);
            }
            
            // Set dialog exit room back to star map
            if (script_exists(set_dialog_exit_room)) {
                set_dialog_exit_room(Room_StarMap);
            }
            
            // Set up the dialog scene to start after room transition
            global.pending_scene_id = target_scene;
            show_debug_message("Starting direct transition to scene: " + target_scene);
            
            // Transition to dialog room
            room_goto(Room_Dialog);
        }
    }
    
    // Check for click on locked system - show engaging locked feedback
    if (mouse_check_button_pressed(mb_left) && !is_unlocked) {
        show_debug_message("System " + system_name + " is locked - showing access denied feedback");
        
        // Create dramatic locked system feedback
        locked_click_timer = 60; // 1 second of feedback animation
        
        // Show enhanced tooltip with unlock requirements
        var tooltip_manager = instance_find(obj_TooltipManager, 0);
        if (tooltip_manager != noone) {
            var locked_feedback = {
                name: system_name + " - ACCESS DENIED",
                type: system_type,
                faction: get_faction_name(faction_control),
                status: "LOCKED SYSTEM",
                threat: threat_level,
                scene_id: get_unlock_hint(),
                locked_hint: "Complete prerequisite missions to unlock"
            };
            tooltip_manager.show_tooltip(mouse_x, mouse_y, locked_feedback);
        }
        
        // Play locked sound effect (placeholder)
        // audio_play_sound(snd_access_denied, 1, false);
    }
    
} else {
    // Mouse is not over this system
    if (hover_state) {
        // Just left hover state
        hover_state = false;
        show_debug_message("Mouse left system: " + system_name);
        
        // Hide tooltip
        var tooltip_manager = instance_find(obj_TooltipManager, 0);
        if (tooltip_manager != noone) {
            tooltip_manager.hide_tooltip();
        }
    }
}
