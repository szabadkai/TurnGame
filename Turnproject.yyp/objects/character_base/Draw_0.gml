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

// Draw turn indicator under character if active
if (state == TURNSTATE.active) {
    // Draw a filled, semi-transparent ellipse to look chunkier at zoom scale
    draw_set_color(c_white);
    var x1 = floor(x - 7);
    var y1 = floor(y + 4);
    var x2 = floor(x + 7);
    var y2 = floor(y + 9);
    draw_set_alpha(0.4);
    draw_ellipse(x1, y1, x2, y2, false); // filled
    draw_set_alpha(1);
}

// Draw the sprite (normal color, red flash, or custom color)
if (damage_flash > 0) {
    draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, c_red, image_alpha);
} else {
    draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, sprite_color, image_alpha);
}

// Draw character name and HP above character (small font)
draw_set_color(c_white);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
//draw_text_transformed(x, y - 16, character_name, 0.25, 0.25, 0);
draw_text_transformed(x, y-10 , string(hp), 0.3, 0.3, 0);

// Reset text alignment
draw_set_halign(fa_left);
draw_set_valign(fa_top);
