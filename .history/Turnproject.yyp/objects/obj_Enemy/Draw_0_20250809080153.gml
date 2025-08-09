// Check for damage to trigger flash
if (hp < last_hp) {
    damage_flash = 10; // Flash for 10 frames
    last_hp = hp;
}

// Reduce flash timer
if (damage_flash > 0) {
    damage_flash--;
}

// Draw the enemy sprite with damage flash
if (damage_flash > 0) {
    draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, c_red, image_alpha);
} else {
    draw_self();
}

// Draw HP text above character
draw_set_color(c_white);
draw_set_halign(fa_center);
draw_text(x, y - 24, string(hp) + "/" + string(max_hp));

// Reset text alignment
draw_set_halign(fa_left);

//if (state = TURNSTATE.active) {
//draw_sprite(spr_active, 0, x, y);
//}






