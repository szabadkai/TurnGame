// === SHARED COMBAT ENTITY RENDERING ===
// This handles all common visual elements for Player and Enemy objects

// Early fallback if no sprite is assigned
var _has_sprite = (sprite_index != -1);

// Check for damage to trigger flash
if (hp < last_hp) {
    damage_flash = 10; // Flash for 10 frames
    last_hp = hp;
}

// Reduce flash timer
if (damage_flash > 0) {
    damage_flash--;
}

// Draw thick white outline around character if active
if (_has_sprite && state == TURNSTATE.active) {
    // Force blend mode to ensure white color shows properly
    gpu_set_blendmode(bm_normal);
    
    var outline_thickness = 2;
    
    // Draw outline in 8 directions - use additive blending for bright white
    gpu_set_blendmode(bm_add);
    for (var ox = -outline_thickness; ox <= outline_thickness; ox++) {
        for (var oy = -outline_thickness; oy <= outline_thickness; oy++) {
            if (ox != 0 || oy != 0) { // Skip center position
                draw_sprite_ext(sprite_index, image_index, x + ox, y + oy, 
                               image_xscale, image_yscale, image_angle, c_white, 1);
            }
        }
    }
    
    // Reset blend mode for normal drawing
    gpu_set_blendmode(bm_normal);
}

// Draw the sprite (normal color, red flash, or custom color), or a placeholder if missing
if (_has_sprite) {
    if (damage_flash > 0) {
        draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, c_red, image_alpha);
    } else {
        draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, sprite_color, image_alpha);
    }
} else {
    // Fallback placeholder: small rectangle where the character would be
    draw_set_color(damage_flash > 0 ? c_red : c_ltgray);
    draw_rectangle(x - 6, y - 6, x + 6, y + 6, false);
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
