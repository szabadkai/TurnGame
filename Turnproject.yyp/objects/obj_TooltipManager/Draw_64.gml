// obj_TooltipManager Draw GUI Event
// Render tooltip overlay

if (!tooltip_visible || tooltip_alpha <= 0) return;

// Calculate tooltip dimensions based on content
var line_height = 16;
var content_lines = [];

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
    
    // Handle both numeric and string threat values
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

// Tooltip dimensions are calculated in show_tooltip function
tooltip_height = (array_length(content_lines) * line_height) + (tooltip_padding * 2);

// Draw tooltip background
draw_set_color(tooltip_background_color);
draw_set_alpha(tooltip_background_alpha * tooltip_alpha);
draw_rectangle(tooltip_x, tooltip_y, tooltip_x + tooltip_width, tooltip_y + tooltip_height, false);

// Draw tooltip border
draw_set_color(tooltip_border_color);
draw_set_alpha(0.6 * tooltip_alpha);
draw_rectangle(tooltip_x, tooltip_y, tooltip_x + tooltip_width, tooltip_y + tooltip_height, true);

// Draw tooltip text
draw_set_color(tooltip_text_color);
draw_set_alpha(tooltip_alpha);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

for (var i = 0; i < array_length(content_lines); i++) {
    var text_x = tooltip_x + tooltip_padding;
    var text_y = tooltip_y + tooltip_padding + (i * line_height);
    
    // Highlight the system name
    if (i == 0) {
        draw_set_color(c_yellow);
    } else {
        draw_set_color(tooltip_text_color);
    }
    
    draw_text(text_x, text_y, content_lines[i]);
}

// Reset draw settings
draw_set_color(c_white);
draw_set_alpha(1.0);
draw_set_halign(fa_left);
draw_set_valign(fa_top);