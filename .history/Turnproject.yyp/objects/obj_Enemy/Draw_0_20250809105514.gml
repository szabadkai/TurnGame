// Check for damage to trigger flash
if (hp < last_hp) {
    damage_flash = 10; // Flash for 10 frames
    last_hp = hp;
}

// Reduce flash timer
if (damage_flash > 0) {
    damage_flash--;
}

// Draw the enemy sprite with appropriate tint
var sprite_color = c_white;
if (state == TURNSTATE.active) {
}
    sprite_color = c_yellow;  // Yellow tint for active turn

if (damage_flash > 0) {
    draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, c_red, image_alpha);
} else {
    draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, sprite_color, image_alpha);
}

// Draw HP text above character (small font)
draw_set_color(c_white);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text_transformed(x, y - 20, string(hp) + "/" + string(max_hp), 0.5, 0.5, 0);

// Reset text alignment
draw_set_halign(fa_left);
draw_set_valign(fa_top);






