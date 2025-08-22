// obj_CombatResultsUI Draw GUI Event
// Render combat results overlay

if (!ui_visible || ui_alpha <= 0) return;

// Update animations
bounce_timer += 0.1;
bounce_scale = 1.0 + 0.05 * sin(bounce_timer * 2);

// Draw overlay background
draw_set_color(c_black);
draw_set_alpha(0.7 * ui_alpha);
draw_rectangle(0, 0, room_width, room_height, false);

// Draw main UI panel
var panel_x = ui_x - (ui_width / 2);
var panel_y = ui_y - (ui_height / 2);

// Panel background
draw_set_color(c_black);
draw_set_alpha(0.9 * ui_alpha);
draw_rectangle(panel_x, panel_y, panel_x + ui_width, panel_y + ui_height, false);

// Panel border
draw_set_color(combat_result == "victory" ? c_green : c_red);
draw_set_alpha(ui_alpha);
draw_rectangle(panel_x, panel_y, panel_x + ui_width, panel_y + ui_height, true);
draw_rectangle(panel_x + 2, panel_y + 2, panel_x + ui_width - 2, panel_y + ui_height - 2, true);

// Draw result message (title)
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_set_color(combat_result == "victory" ? c_green : c_red);
draw_set_alpha(ui_alpha);

var title_y = ui_y - 60;
var title_scale = bounce_scale;
draw_text_transformed(ui_x, title_y, result_message, title_scale, title_scale, 0);

// Draw result details
draw_set_color(c_white);
draw_set_alpha(ui_alpha);
var details_y = ui_y - 20;
draw_text(ui_x, details_y, result_details);

// Draw XP information (if victory)
if (combat_result == "victory" && xp_awarded > 0) {
    var xp_y = ui_y + 10;
    draw_set_color(c_yellow);
    draw_text(ui_x, xp_y, "Experience Gained: " + string(xp_awarded) + " XP");
}

// Draw return button
var current_button_color = button_hover ? button_hover_color : button_color;
draw_set_color(current_button_color);
draw_set_alpha(ui_alpha);
draw_rectangle(button_x, button_y, button_x + button_width, button_y + button_height, false);

// Button border
draw_set_color(c_white);
draw_rectangle(button_x, button_y, button_x + button_width, button_y + button_height, true);

// Button text
draw_set_color(button_text_color);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(button_x + (button_width / 2), button_y + (button_height / 2), "Return to Star Map");

// Reset draw settings
draw_set_color(c_white);
draw_set_alpha(1.0);
draw_set_halign(fa_left);
draw_set_valign(fa_top);