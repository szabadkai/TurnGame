// === ENEMY HOVER COLOR SYSTEM ===

// SIMPLE TEST: Make all enemies red to verify this draw event is executing
var sprite_color = c_red; // Test: all enemies red

// Debug: Check if mouse is hovering over this enemy (improved coordinates)
var world_mouse_x = mouse_x;
var world_mouse_y = mouse_y;
var mouse_hovering = position_meeting(world_mouse_x, world_mouse_y, self);

// Check if any player has pistol equipped and is active
var pistol_active = false;
var active_player = noone;

with (obj_Player) {
    if (state == TURNSTATE.active && weapon_special_type == "ranged") {
        pistol_active = true;
        active_player = self;
        break;
    }
}

// If hovering and pistol active, check range
if (mouse_hovering && pistol_active && active_player != noone) {
    // Calculate simple distance for testing
    var dx = abs(active_player.x - x) / 16;
    var dy = abs(active_player.y - y) / 16;
    var distance = max(dx, dy);
    
    if (distance <= 4) {
        sprite_color = c_lime; // Green for in range
    } else {
        sprite_color = c_red;  // Red for out of range  
    }
} else if (pistol_active) {
    sprite_color = c_yellow; // Yellow when pistol active but not hovering
}

// Use the inherited drawing but with our color override
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

// Draw the sprite with hover color (normal color, red flash, or hover color)
if (damage_flash > 0) {
    draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, c_red, image_alpha);
} else {
    draw_sprite_ext(sprite_index, image_index, x, y, image_xscale, image_yscale, image_angle, sprite_color, image_alpha);
}

// Draw character name and HP above character (small font)
draw_set_color(c_white);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);
draw_text_transformed(x, y-10 , string(hp), 0.3, 0.3, 0);

// DEBUG: Show hover and pistol status
if (pistol_active) {
    draw_set_color(c_white);
    var debug_text = "H:" + (mouse_hovering ? "Y" : "N");
    draw_text_transformed(x, y + 15, debug_text, 0.25, 0.25, 0);
}

// Reset text alignment
draw_set_halign(fa_left);
draw_set_valign(fa_top);