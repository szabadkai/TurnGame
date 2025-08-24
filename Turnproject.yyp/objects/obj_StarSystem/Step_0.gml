// obj_StarSystem Step Event
// Handle mouse interaction using distance-based detection

// Initialize keyboard selection state
if (!variable_instance_exists(id, "keyboard_selected")) {
    keyboard_selected = false;
}

// Define interaction radius
var interaction_radius = 20;

// Skip all interactions if crew selection UI is active
var crew_ui = instance_find(obj_CrewSelectUI, 0);
if (crew_ui != noone && crew_ui.ui_visible) {
    // Force hover state off when UI is blocking
    if (hover_state) {
        hover_state = false;
        var tooltip_manager = instance_find(obj_TooltipManager, 0);
        if (tooltip_manager != noone) {
            tooltip_manager.hide_tooltip();
        }
    }
    exit; // Skip all interaction logic
}

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
        show_debug_message("Clicked on unlocked system: " + system_name + " at X: " + string(x) + ", Y: " + string(y));
        
        // Play click sound effect (placeholder)
        // audio_play_sound(snd_confirm_click, 1, false);
        
        // Hide tooltip before showing confirmation
        var tooltip_manager = instance_find(obj_TooltipManager, 0);
        if (tooltip_manager != noone) {
            tooltip_manager.hide_tooltip();
        }
        
        show_debug_message("is_unlocked: " + string(is_unlocked));
        // Create and show landing party UI
        if (object_exists(obj_CrewSelectUI)) {
            var landing_party_ui = instance_create_layer(x, y, "Instances", obj_CrewSelectUI);
            show_debug_message("landing_party_ui instance: " + string(landing_party_ui));
            landing_party_ui.pending_system_id = system_id;
            landing_party_ui.pending_target_scene = target_scene;
            landing_party_ui.pending_travel_room = Room_Dialog;
            landing_party_ui.show_ui(hover_info, Room_Dialog);
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

// Function to trigger system selection via keyboard
function trigger_keyboard_selection() {
    if (is_unlocked) {
        show_debug_message("Keyboard selected system: " + system_name);
        
        // Hide tooltip before showing confirmation
        var tooltip_manager = instance_find(obj_TooltipManager, 0);
        if (tooltip_manager != noone) {
            tooltip_manager.hide_tooltip();
        }
        
        // Create and show landing party UI (same as mouse click)
        if (object_exists(obj_CrewSelectUI)) {
            var landing_party_ui = instance_create_layer(x, y, "Instances", obj_CrewSelectUI);
            landing_party_ui.pending_system_id = system_id;
            landing_party_ui.pending_target_scene = target_scene;
            landing_party_ui.pending_travel_room = Room_Dialog;
            landing_party_ui.show_ui(hover_info, Room_Dialog);
        }
    } else {
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
            tooltip_manager.show_tooltip(x, y, locked_feedback);
        }
    }
}
