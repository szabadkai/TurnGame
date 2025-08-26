// obj_StarSystem Create Event
// Initialize star system properties and visual state

// Core system properties - these will be set by StarMapManager during creation
// Initialize with safe defaults only if not already set
if (!variable_instance_exists(id, "system_id")) system_id = "unknown_system";
if (!variable_instance_exists(id, "system_name")) system_name = "Unknown System";
if (!variable_instance_exists(id, "system_type")) system_type = "Uncharted";
if (!variable_instance_exists(id, "target_scene")) target_scene = "";
if (!variable_instance_exists(id, "star_sprite")) star_sprite = "star1";
if (!variable_instance_exists(id, "is_unlocked")) is_unlocked = false;
if (!variable_instance_exists(id, "is_visited")) is_visited = false;
if (!variable_instance_exists(id, "is_current")) is_current = false;
if (!variable_instance_exists(id, "faction_control")) faction_control = 0;
if (!variable_instance_exists(id, "threat_level")) threat_level = 1;

// Cache sprite asset for performance (avoid repeated lookups)
cached_sprite_asset = asset_get_index(star_sprite);
if (cached_sprite_asset == -1) {
    cached_sprite_asset = asset_get_index("star1"); // Fallback
}

// Cache sprite dimensions for interaction calculations
sprite_w = sprite_get_width(cached_sprite_asset);
sprite_h = sprite_get_height(cached_sprite_asset);
sprite_center_x = sprite_w * 0.5;
sprite_center_y = sprite_h * 0.5;

// Visual state variables
hover_state = false;
keyboard_selected = false;
glow_timer = 0;
base_scale = 1.0;
current_scale = base_scale;

// Initialize tooltip information structure
update_visual_state();


// Helper function to get exploration status
function get_exploration_status() {
    if (!is_unlocked) return "Locked";
    if (is_current) return "Current Location";
    if (is_visited) return "Explored";
    return "Unexplored";
}


// Helper function to draw a star shape
function draw_star(center_x, center_y, outer_radius, inner_radius, points, rotation) {
    var angle_step = 360 / points;
    var half_step = angle_step / 2;
    
    // Create arrays for star points
    var star_x = array_create(points * 2);
    var star_y = array_create(points * 2);
    
    // Calculate star points (alternating outer and inner)
    for (var i = 0; i < points; i++) {
        var outer_angle = degtorad(rotation + i * angle_step);
        var inner_angle = degtorad(rotation + i * angle_step + half_step);
        
        // Outer point
        star_x[i * 2] = center_x + cos(outer_angle) * outer_radius;
        star_y[i * 2] = center_y - sin(outer_angle) * outer_radius;
        
        // Inner point
        star_x[i * 2 + 1] = center_x + cos(inner_angle) * inner_radius;
        star_y[i * 2 + 1] = center_y - sin(inner_angle) * inner_radius;
    }
    
    // Draw the star using triangles from center
    for (var i = 0; i < points * 2; i++) {
        var next_i = (i + 1) % (points * 2);
        draw_triangle(center_x, center_y, star_x[i], star_y[i], star_x[next_i], star_y[next_i], false);
    }
}

// Update visual appearance based on current state
function update_visual_state() {
    // Update hover info when state changes using data configuration
    hover_info = {
        name: system_name,
        type: system_type,
        faction: get_faction_name(faction_control),
        status: get_exploration_status(),
        threat: threat_level,
        scene_id: target_scene
    };
}