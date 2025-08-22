// obj_TooltipManager Create Event
// Initialize tooltip system

// Tooltip state
tooltip_visible = false;
tooltip_x = 0;
tooltip_y = 0;
tooltip_content = {};
tooltip_alpha = 0;
tooltip_target_alpha = 0;

// Tooltip appearance settings
tooltip_padding = 8;
tooltip_width = 200;
tooltip_height = 0; // Calculated dynamically
tooltip_background_color = c_black;
tooltip_background_alpha = 0.8;
tooltip_border_color = c_white;
tooltip_text_color = c_white;

// Animation settings
fade_speed = 0.15;
follow_mouse = true;
mouse_offset_x = 15;
mouse_offset_y = -10;

show_debug_message("TooltipManager initialized");

// Calculate tooltip dimensions based on content
function calculate_tooltip_dimensions() {
    var line_height = 16;
    var content_lines = [];
    
    // Build content lines (same logic as Draw event)
    if (variable_struct_exists(tooltip_content, "name")) {
        array_push(content_lines, tooltip_content.name);
    }
    if (variable_struct_exists(tooltip_content, "type")) {
        array_push(content_lines, "Type: " + tooltip_content.type);
    }
    if (variable_struct_exists(tooltip_content, "faction")) {
        array_push(content_lines, "Control: " + tooltip_content.faction);
    }
    if (variable_struct_exists(tooltip_content, "status")) {
        array_push(content_lines, "Status: " + tooltip_content.status);
    }
    if (variable_struct_exists(tooltip_content, "threat")) {
        var threat_text = "Threat: ";
        var threat_value = tooltip_content.threat;
        
        if (is_string(threat_value)) {
            threat_text += threat_value;
        } else if (is_real(threat_value)) {
            for (var i = 0; i < threat_value; i++) {
                threat_text += "*";
            }
        }
        array_push(content_lines, threat_text);
    }
    if (variable_struct_exists(tooltip_content, "scene_id")) {
        array_push(content_lines, tooltip_content.scene_id);
    }
    if (variable_struct_exists(tooltip_content, "locked_hint")) {
        array_push(content_lines, tooltip_content.locked_hint);
    }
    
    // Calculate width based on longest line
    var max_text_width = 0;
    draw_set_font(-1); // Use default font
    for (var i = 0; i < array_length(content_lines); i++) {
        var text_width = string_width(content_lines[i]);
        if (text_width > max_text_width) {
            max_text_width = text_width;
        }
    }
    
    // Set dimensions
    tooltip_width = max_text_width + (tooltip_padding * 2);
    tooltip_height = (array_length(content_lines) * line_height) + (tooltip_padding * 2);
}

// Show tooltip with content
function show_tooltip(pos_x, pos_y, content_struct) {
    tooltip_visible = true;
    tooltip_content = content_struct;
    tooltip_target_alpha = 1.0;
    
    // Calculate tooltip width based on content
    calculate_tooltip_dimensions();
    
    // Position tooltip
    if (follow_mouse) {
        tooltip_x = pos_x + mouse_offset_x;
        tooltip_y = pos_y + mouse_offset_y;
    } else {
        tooltip_x = pos_x;
        tooltip_y = pos_y;
    }
    
    // Ensure tooltip stays within screen bounds
    if (tooltip_x + tooltip_width > room_width) {
        tooltip_x = room_width - tooltip_width - 10;
    }
    if (tooltip_y < 10) {
        tooltip_y = 10;
    }
    
    show_debug_message("Showing tooltip at " + string(tooltip_x) + "," + string(tooltip_y));
}

// Hide tooltip
function hide_tooltip() {
    tooltip_target_alpha = 0;
    // tooltip_visible will be set to false when alpha reaches 0 in Step event
}

// Update tooltip position (for mouse following)
function update_tooltip_position() {
    if (tooltip_visible && follow_mouse) {
        tooltip_x = mouse_x + mouse_offset_x;
        tooltip_y = mouse_y + mouse_offset_y;
        
        // Keep within screen bounds
        if (tooltip_x + tooltip_width > room_width) {
            tooltip_x = room_width - tooltip_width - 10;
        }
        if (tooltip_y < 10) {
            tooltip_y = 10;
        }
    }
}