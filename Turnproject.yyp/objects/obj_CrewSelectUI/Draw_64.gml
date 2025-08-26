// obj_CrewSelectUI Draw GUI Event

if (!ui_visible || ui_alpha <= 0) return;

// Get available crew from crew system
var available_crew = get_available_crew();

// Draw UI background
draw_set_color(c_black);
draw_set_alpha(0.8 * ui_alpha);
draw_rectangle(x, y, x + ui_width, y + ui_height, false);

// Draw UI border
draw_set_color(c_white);
draw_set_alpha(ui_alpha);
draw_rectangle(x, y, x + ui_width, y + ui_height, true);

// Draw title
draw_set_color(c_yellow);
draw_set_halign(fa_center);
draw_text(x + ui_width/2, y + 15, "Select Landing Party");

// Draw instructions - shortened to fit modal
draw_set_color(c_ltgray);
draw_set_halign(fa_center);
draw_text(x + ui_width/2, y + 35, "WASD: Navigate • Space: Select • Enter: Launch");

// Draw crew list
draw_set_color(c_white);
draw_set_halign(fa_left);
var list_y = y + 55;
for (var i = 0; i < array_length(available_crew); i++) {
    var member = available_crew[i];
    var member_y = list_y + (i * 20);
    
    // Check if member is selected (custom implementation instead of array_indexOf)
    var is_selected = false;
    for (var j = 0; j < array_length(landing_party); j++) {
        if (landing_party[j] == i) {
            is_selected = true;
            break;
        }
    }
    
    // Check if this is the keyboard-selected item
    var is_keyboard_selected = (variable_instance_exists(id, "selected_crew_index") && 
                               variable_instance_exists(id, "selected_button") &&
                               selected_button == 0 && selected_crew_index == i);
    
    // Draw keyboard selection highlight
    if (is_keyboard_selected) {
        draw_set_alpha(0.3 * ui_alpha);
        draw_set_color(c_yellow);
        draw_rectangle(x + 5, member_y , x + ui_width - 5, member_y + 16, false);
        draw_set_alpha(ui_alpha);
    }

    // Draw selection indicator (asterisk instead of checkbox)
    var indicator_x = x + 10;
    if (is_selected) {
        draw_set_color(c_yellow);
        draw_text(indicator_x, member_y, "*");
        draw_set_color(c_white);
    } else {
        draw_set_color(c_gray);
        draw_text(indicator_x, member_y, " ");
        draw_set_color(c_white);
    }

    // Draw member name and status with improved text clipping
    var text_x = indicator_x + 15;
    var max_text_width = ui_width - 50; // Leave sufficient margin
    var full_text = member.full_name + " (" + member.status + ", " + string(member.hp) + " HP)";
    var member_text = full_text;
    
    // Smart text clipping - preserve important information
    if (string_width(full_text) > max_text_width) {
        // Try shorter status first
        var short_status = member.status;
        if (member.status == "Healthy") short_status = "OK";
        if (member.status == "Lightly Injured") short_status = "Light";
        if (member.status == "Wounded") short_status = "Hurt";
        if (member.status == "Badly Wounded") short_status = "Bad";
        if (member.status == "Critically Injured") short_status = "Critical";
        
        member_text = member.full_name + " (" + short_status + ", " + string(member.hp) + "HP)";
        
        // If still too long, truncate name but keep status and HP
        if (string_width(member_text) > max_text_width) {
            var name_part = member.full_name;
            var status_part = " (" + short_status + ", " + string(member.hp) + "HP)";
            var status_width = string_width(status_part);
            var available_name_width = max_text_width - status_width - string_width("...");
            
            if (available_name_width > 0) {
                while (string_width(name_part) > available_name_width && string_length(name_part) > 1) {
                    name_part = string_delete(name_part, string_length(name_part), 1);
                }
                member_text = name_part + "..." + status_part;
            } else {
                // Last resort - just fit what we can
                member_text = full_text;
                while (string_width(member_text + "...") > max_text_width && string_length(member_text) > 5) {
                    member_text = string_delete(member_text, string_length(member_text), 1);
                }
                if (string_length(member_text) < string_length(full_text)) {
                    member_text += "...";
                }
            }
        }
    }
    
    draw_text(text_x, member_y, member_text);
}

// Draw Launch button
var button_y = y + ui_height - 50;
var button_width = 120;
var launch_button_x = x + ui_width/2 - button_width/2;

// Check if launch button is keyboard-selected
var is_button_selected = (variable_instance_exists(id, "selected_button") && selected_button == 1);

// Check if launch is enabled (crew selected)
var launch_enabled = (array_length(landing_party) > 0);

// Draw keyboard selection highlight for button (only if enabled)
if (is_button_selected && launch_enabled) {
    draw_set_alpha(0.3 * ui_alpha);
    draw_set_color(c_yellow);
    draw_rectangle(launch_button_x - 5, button_y - 3, launch_button_x + button_width + 5, button_y + 38, false);
    draw_set_alpha(ui_alpha);
}

// Draw button background - green if enabled, dark gray if disabled
draw_set_color(launch_enabled ? c_green : c_dkgray);
draw_rectangle(launch_button_x, button_y, launch_button_x + button_width, button_y + 35, false);

// Draw button border - white/yellow if enabled, gray if disabled  
if (launch_enabled) {
    draw_set_color(is_button_selected ? c_yellow : c_white);
} else {
    draw_set_color(c_gray);
}
draw_rectangle(launch_button_x, button_y, launch_button_x + button_width, button_y + 35, true);

// Draw button text - white if enabled, gray if disabled
draw_set_color(launch_enabled ? c_white : c_ltgray);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
var button_text = launch_enabled ? "Launch" : "Select Crew";
draw_text(launch_button_x + button_width/2, button_y + 17, button_text);

// Draw selected count
draw_set_color(c_yellow);
draw_set_halign(fa_center);
draw_set_valign(fa_top);
var selected_text = "Selected: " + string(array_length(landing_party)) + "/" + string(max_landing_party_size);
draw_text(x + ui_width/2, button_y - 25, selected_text);

// Reset draw settings
draw_set_color(c_white);
draw_set_alpha(1.0);
draw_set_halign(fa_left);
draw_set_valign(fa_top);