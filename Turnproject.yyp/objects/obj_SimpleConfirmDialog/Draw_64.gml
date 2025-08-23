// Simple Confirmation Dialog Draw GUI Event

if (!show_visible || show_alpha <= 0) return;

// Draw overlay
draw_set_color(c_black);
draw_set_alpha(0.5 * show_alpha);
draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);

// Draw dialog
draw_set_color(c_black);
draw_set_alpha(0.8 * show_alpha);
draw_rectangle(dialog_x, dialog_y, dialog_x + dialog_width, dialog_y + dialog_height, false);

draw_set_color(c_white);
draw_set_alpha(show_alpha);
draw_rectangle(dialog_x, dialog_y, dialog_x + dialog_width, dialog_y + dialog_height, true);

// Draw text
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(dialog_x + dialog_width/2, dialog_y + dialog_height/2 - 20, "Travel to:");
draw_set_color(c_yellow);
draw_text(dialog_x + dialog_width/2, dialog_y + dialog_height/2, system_name + "?");
draw_set_color(c_white);
draw_text(dialog_x + dialog_width/2, dialog_y + dialog_height/2 + 30, "Enter/Y - Yes  |  Esc/N - No");

// Reset
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_alpha(1);
draw_set_color(c_white);