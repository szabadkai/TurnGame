// obj_StarSystem Draw Event
// Render star system with appropriate visual state

// Update animation timers
glow_timer += 0.05;

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

// No old circle feedback - outlines handle all visual feedback now

// Use cached sprite asset for better performance
var sprite_asset = cached_sprite_asset;

// Draw glow effects around the star sprite
// The base star sprite is already drawn by the asset layer
// We just add glow effects on top

// Determine glow properties based on state
var glow_intensity = 0;
var glow_radius = 3; // 3px glow as requested
var glow_color_to_use = c_white;

// Set outline properties based on system state (ONLY when hovered or selected)
var outline_thickness = 2; // Default thickness (increased from 1px to 2px)
var show_outline = false;

if (hover_state || keyboard_selected) {
    show_outline = true;
    glow_intensity = 1.0; // Solid alpha, no transparency
    
    if (is_current) {
        // Current location - extra thick yellow outline
        glow_color_to_use = c_yellow;
        outline_thickness = 4; // Extra thick outline (increased from 2px to 4px)
    } else if (!is_unlocked) {
        // Locked system - red outline
        glow_color_to_use = c_red;
        outline_thickness = 2; // Base thickness (increased from 1px to 2px)
    } else if (is_visited) {
        // Visited system - blue outline
        glow_color_to_use = c_blue;
        outline_thickness = 2; // Base thickness (increased from 1px to 2px)
    } else if (is_unlocked) {
        // Unlocked unvisited - white outline
        glow_color_to_use = c_white;
        outline_thickness = 2; // Base thickness (increased from 1px to 2px)
    }
}

// Draw outline effect (edge only, transparent center)
if (show_outline && glow_intensity > 0) {
    var original_blend = gpu_get_blendmode();
    
    draw_set_color(glow_color_to_use);
    draw_set_alpha(glow_intensity);
    
    // Draw outline by drawing only the outer edge pixels
    // This creates a ring outline without filling the center
    for (var offset_x = -outline_thickness; offset_x <= outline_thickness; offset_x++) {
        for (var offset_y = -outline_thickness; offset_y <= outline_thickness; offset_y++) {
            // Only draw the outer perimeter
            if (abs(offset_x) == outline_thickness || abs(offset_y) == outline_thickness) {
                // Check if we're not at the corners to avoid thick corner artifacts
                if (!(abs(offset_x) == outline_thickness && abs(offset_y) == outline_thickness)) {
                    draw_sprite(sprite_asset, 0, x + offset_x, y + offset_y);
                }
            }
        }
    }
    
    // Add corner pixels for smoother outline
    draw_sprite(sprite_asset, 0, x - outline_thickness, y - outline_thickness);
    draw_sprite(sprite_asset, 0, x + outline_thickness, y - outline_thickness);
    draw_sprite(sprite_asset, 0, x - outline_thickness, y + outline_thickness);
    draw_sprite(sprite_asset, 0, x + outline_thickness, y + outline_thickness);
    
    gpu_set_blendmode(original_blend);
}

// Use cached sprite dimensions
var half_w = sprite_center_x;
var half_h = sprite_center_y;




// No locked click feedback animation - removed for cleaner experience

// Draw lock icon overlay for all locked systems
if (!is_unlocked) {
    var lock_alpha = 0.8;
    if (hover_state) {
        lock_alpha = 1.0;
    }
    
    draw_set_color(c_red);
    draw_set_alpha(lock_alpha);
    
    // Draw simple lock symbol (padlock shape) - centered on sprite
    // Account for sprite origin at (0,0) instead of center
    var lock_x = x + half_w;
    var lock_y = y + half_h;
    
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