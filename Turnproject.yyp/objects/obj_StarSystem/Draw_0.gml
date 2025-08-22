// obj_StarSystem Draw Event
// Render star system with appropriate visual state

// Update animation timers
glow_timer += 0.05;
if (locked_click_timer > 0) {
    locked_click_timer--;
}

// Debug: Show system info once per second
if (floor(glow_timer) % 60 == 0 && glow_timer - floor(glow_timer) < 0.05) {
    show_debug_message("Drawing system: " + system_name + " at (" + string(x) + "," + string(y) + ") unlocked: " + string(is_unlocked));
}

// Determine visual state and colors
var base_color = c_white;
var glow_color = c_white;
var alpha = 1.0;

if (!is_unlocked) {
    // Locked state - grayed out
    base_color = c_gray;
    alpha = 0.4;
} else if (is_current) {
    // Current location - animated glow
    base_color = c_yellow;
    glow_color = c_orange;
    alpha = 0.8 + 0.2 * sin(glow_timer * 2);
    current_scale = base_scale + 0.1 * sin(glow_timer);
} else if (is_visited) {
    // Visited system - subtle blue tint
    base_color = c_aqua;
    alpha = 0.9;
} else {
    // Unlocked but unvisited - bright white
    base_color = c_white;
    alpha = 1.0;
}

// Hover state modifications
if (hover_state) {
    if (is_unlocked) {
        // Unlocked hover - bright and enlarged
        current_scale = lerp(current_scale, base_scale + 0.2, 0.1);
        alpha = min(alpha + 0.2, 1.0);
    } else {
        // Locked hover - subtle pulse and red tint
        current_scale = lerp(current_scale, base_scale + 0.1, 0.1);
        alpha = min(alpha + 0.3, 0.8);
        // Add red warning pulse for locked systems
        var pulse_alpha = 0.3 + 0.2 * sin(glow_timer * 4);
        draw_set_color(c_red);
        draw_set_alpha(pulse_alpha);
        draw_circle(x, y, (12 * current_scale) + 4, true);
        draw_set_alpha(alpha); // Reset for main drawing
    }
} else {
    current_scale = lerp(current_scale, base_scale, 0.1);
}

// Draw star system
draw_set_color(base_color);
draw_set_alpha(alpha);

// Draw a 5-pointed star with enhanced effects
var radius = 12 * current_scale;
var star_rotation = glow_timer * 10; // Slow rotation for all stars

// Add subtle twinkling effect
var twinkle = 0.8 + 0.2 * sin(glow_timer * 3 + x * 0.1 + y * 0.1);
draw_set_alpha(alpha * twinkle);

// Draw main star shape
draw_star(x, y, radius, radius * 0.4, 5, star_rotation);

// Draw additional star rays for brighter stars
if (is_current || (is_unlocked && hover_state)) {
    draw_set_alpha(alpha * 0.6);
    draw_star(x, y, radius * 1.3, radius * 0.15, 8, star_rotation + 22.5); // 8-pointed background star
}

// Draw glow effect for current system
if (is_current) {
    draw_set_color(glow_color);
    draw_set_alpha(0.3 + 0.2 * sin(glow_timer * 2));
    
    // Multiple glow layers for depth
    draw_star(x, y, radius * 1.8, radius * 0.6, 5, star_rotation);
    draw_set_alpha(0.1 + 0.1 * sin(glow_timer * 2));
    draw_star(x, y, radius * 2.2, radius * 0.8, 5, star_rotation);
}

// Draw faction indicator (small colored star)
if (is_unlocked && faction_control > 0) {
    var faction_color = c_white;
    switch(faction_control) {
        case 1: faction_color = c_blue; break;    // Human - blue
        case 2: faction_color = c_green; break;   // Keth'mori - green
        case 3: faction_color = c_red; break;     // Swarm - red
    }
    
    draw_set_color(faction_color);
    draw_set_alpha(0.9);
    draw_star(x + radius - 6, y - radius + 6, 4, 2, 4, glow_timer * 20);
}

// Draw threat level indicators (small danger stars)
if (is_unlocked && threat_level > 1) {
    draw_set_color(c_red);
    draw_set_alpha(0.8);
    for (var i = 0; i < min(threat_level - 1, 4); i++) {
        var star_x = x - radius + 6 + (i * 6);
        var star_y = y + radius - 6;
        draw_star(star_x, star_y, 2, 1, 4, glow_timer * 30 + i * 90);
    }
}

// Draw visited marker (small green star)
if (is_visited) {
    draw_set_color(c_lime);
    draw_set_alpha(0.8 + 0.2 * sin(glow_timer * 4));
    draw_star(x - radius + 6, y - radius + 6, 3, 1.5, 5, glow_timer * 25);
}

// Draw locked click feedback animation
if (locked_click_timer > 0) {
    var feedback_progress = locked_click_timer / 60.0;
    var shake_intensity = feedback_progress * 3;
    var flash_alpha = 0.5 + 0.5 * sin(locked_click_timer * 0.8);
    
    // Screen shake effect for locked click position
    var shake_x = x + random_range(-shake_intensity, shake_intensity);
    var shake_y = y + random_range(-shake_intensity, shake_intensity);
    
    // Draw expanding red "access denied" star burst
    draw_set_color(c_red);
    draw_set_alpha(flash_alpha * feedback_progress);
    var denied_radius = radius + (1 - feedback_progress) * 20;
    draw_star(shake_x, shake_y, denied_radius, denied_radius * 0.3, 8, locked_click_timer * 10);
    
    // Draw lock symbol (simple cross)
    var lock_size = 6 * feedback_progress;
    draw_set_alpha(flash_alpha);
    draw_line_width(shake_x - lock_size, shake_y - lock_size, shake_x + lock_size, shake_y + lock_size, 2);
    draw_line_width(shake_x + lock_size, shake_y - lock_size, shake_x - lock_size, shake_y + lock_size, 2);
}

// Draw lock icon overlay for all locked systems
if (!is_unlocked) {
    var lock_alpha = 0.8;
    if (hover_state) {
        lock_alpha = 1.0;
    }
    
    draw_set_color(c_red);
    draw_set_alpha(lock_alpha);
    
    // Draw simple lock symbol (padlock shape)
    var lock_x = x + radius - 6;
    var lock_y = y - radius + 6;
    
    // Lock body (rectangle)
    draw_rectangle(lock_x - 3, lock_y, lock_x + 3, lock_y + 4, true);
    
    // Lock shackle (arc)
    draw_circle(lock_x, lock_y - 1, 2, true);
    draw_set_color(c_black);
    draw_set_alpha(lock_alpha);
    draw_circle(lock_x, lock_y - 1, 1, false);
}

// Reset draw settings
draw_set_color(c_white);
draw_set_alpha(1.0);