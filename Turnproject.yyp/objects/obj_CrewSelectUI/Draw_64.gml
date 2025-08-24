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

// Draw instructions
draw_set_color(c_ltgray);
draw_set_halign(fa_center);
draw_text(x + ui_width/2, y + 35, "Click checkboxes to select crew members");

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

    // Draw checkbox
    var check_x = x + 10;
    draw_rectangle(check_x, member_y, check_x + 12, member_y + 12, true);
    if (is_selected) {
        draw_line(check_x, member_y, check_x + 12, member_y + 12);
        draw_line(check_x, member_y + 12, check_x + 12, member_y);
    }

    // Draw member name and status with proper text clipping
    var text_x = check_x + 20;
    var max_text_width = ui_width - 40; // Leave margin
    var member_text = member.full_name + " (" + member.status + ", " + string(member.hp) + " HP)";
    
    // Clip text if too long
    while (string_width(member_text) > max_text_width && string_length(member_text) > 10) {
        member_text = string_delete(member_text, string_length(member_text), 1);
    }
    if (string_width(member_text + "...") <= max_text_width && string_length(member_text) < string_length(member.full_name + " (" + member.status + ", " + string(member.hp) + " HP)")) {
        member_text += "...";
    }
    
    draw_text(text_x, member_y, member_text);
}

// Draw Launch button
var button_y = y + ui_height - 50;
var button_width = 120;
var launch_button_x = x + ui_width/2 - button_width/2;
draw_set_color(c_green);
draw_rectangle(launch_button_x, button_y, launch_button_x + button_width, button_y + 35, false);
draw_set_color(c_white);
draw_rectangle(launch_button_x, button_y, launch_button_x + button_width, button_y + 35, true);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(launch_button_x + button_width/2, button_y + 17, "Launch Mission");

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