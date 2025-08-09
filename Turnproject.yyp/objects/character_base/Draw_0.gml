// === SHARED COMBAT ENTITY RENDERING ===
// This handles all common visual elements for Player and Enemy objects

// Check for damage to trigger flash
if (hp < last_hp) {
    damage_flash = 10; // Flash for 10 frames
    last_hp = hp;
}

// Reduce flash timer
if (damage_flash > 0) {
    damage_flash--;
}

// Draw turn indicator ellipse under character if active
if (state == TURNSTATE.active) {
    draw_set_color(c_white);
    draw_ellipse(x - 7, y + 4, x + 7, y + 9, true);  // Outline
}

// Draw the sprite (normal color or red flash)
if (damage_flash > 0) {
    draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, c_red, image_alpha);
} else {
    draw_self();
}

// Draw character name and HP above character (small font)
draw_set_color(c_white);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
//draw_text_transformed(x, y - 16, character_name, 0.25, 0.25, 0);
draw_text_transformed(x, y - 10, string(hp), 0.3, 0.3, 0);

// Reset text alignment
draw_set_halign(fa_left);
draw_set_valign(fa_top);