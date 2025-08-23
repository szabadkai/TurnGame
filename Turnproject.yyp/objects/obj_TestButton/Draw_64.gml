// Test Button Draw GUI Event

// Draw a simple test button
draw_set_color(c_blue);
draw_set_alpha(0.8);
draw_rectangle(100, 100, 200, 130, false);

draw_set_color(c_white);
draw_set_alpha(1);
draw_rectangle(100, 100, 200, 130, true);

draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text(150, 115, "TEST DIALOG");

draw_set_halign(fa_left);
draw_set_valign(fa_top);