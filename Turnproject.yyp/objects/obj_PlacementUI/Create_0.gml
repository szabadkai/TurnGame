// obj_PlacementUI Create Event
// Manages the initial placement phase for crew members - Heroes 3 style

// Arena boundaries aligned to 16-pixel grid (extended bottom)
// Characters are positioned at: 24, 72, 120, 152, 296 (x) and 88, 104, 136, 168 (y)
// To align with 16-pixel grid, arena should start at grid-aligned position
arena_left = 16;     // Start at 16-pixel boundary (grid position 1,0 = pixel 16)
arena_top = 80;      // Start at 16-pixel boundary (grid position 0,5 = pixel 80)
arena_right = 304;   // End at 16-pixel boundary
arena_bottom = 176;  // Original bottom boundary
arena_width = arena_right - arena_left;   // 288 pixels
arena_height = arena_bottom - arena_top;  // 96 pixels

// 16x16 grid system aligned to arena
grid_size = 16;
battle_grid_cols = ceil(arena_width / grid_size);   // 18 columns (288/16 = 18)
battle_grid_rows = ceil(arena_height / grid_size);  // 6 rows (96/16 = 6)

// Player placement area (left portion of arena)
player_cols = 6;  // Left portion for players
player_grid_left = 0;
player_grid_right = player_cols - 1;  // 0 to 5 (6 columns)
player_grid_top = 0;
player_grid_bottom = battle_grid_rows - 1;  // 0 to 5 (6 rows)

// Calculate pixel boundaries for player area (relative to arena)
placement_zone_left = arena_left + (player_grid_left * grid_size);
placement_zone_right = arena_left + ((player_grid_right + 1) * grid_size);
placement_zone_top = arena_top + (player_grid_top * grid_size);
placement_zone_bottom = arena_top + ((player_grid_bottom + 1) * grid_size);

show_debug_message("Player placement zone: (" + string(placement_zone_left) + "," + string(placement_zone_top) + ") to (" + string(placement_zone_right) + "," + string(placement_zone_bottom) + ")");

// Grid settings for Heroes 3 style placement
show_grid = true;
grid_alpha = 0.3;
grid_hover_alpha = 0.8;

// Battle grid array to track occupied positions (arena-based)
battle_grid = [];
for (var i = 0; i < battle_grid_cols; i++) {
    battle_grid[i] = [];
    for (var j = 0; j < battle_grid_rows; j++) {
        battle_grid[i][j] = noone;  // noone means empty, otherwise stores instance ID
    }
}

// UI state
placement_active = true;
current_character_index = 0;  // Which crew member is being placed
placement_completed = false;
placement_visualized = true  // Show immediate placement visualization

// Get crew members to place
crew_to_place = [];
if (variable_global_exists("landing_party")) {
    for (var i = 0; i < array_length(global.landing_party); i++) {
        var crew_id = global.landing_party[i];
        var crew_member = get_crew_member(crew_id);
        if (crew_member != undefined) {
            // Create placement data structure with immediate visualization
            var placement_data = {
                crew_member: crew_member,
                placed: false,
                temp_x: -1,
                temp_y: -1,
                final_x: -1,
                final_y: -1,
                player_instance: noone,
                visual_instance: noone  // Immediate visual representation
            };
            crew_to_place[array_length(crew_to_place)] = placement_data;
        }
    }
} else {
    // Fallback to default crew if no landing party selected
    show_debug_message("No landing party found, using default crew for placement");
    var default_crew = get_default_landing_party();
    for (var i = 0; i < array_length(default_crew); i++) {
        var crew_id = default_crew[i];
        var crew_member = get_crew_member(crew_id);
        if (crew_member != undefined) {
            var placement_data = {
                crew_member: crew_member,
                placed: false,
                temp_x: -1,
                temp_y: -1,
                final_x: -1,
                final_y: -1,
                player_instance: noone,
                visual_instance: noone  // Immediate visual representation
            };
            crew_to_place[array_length(crew_to_place)] = placement_data;
        }
    }
}

// Input state
mouse_pressed = false;
key_tab_pressed = false;

// Enhanced visual feedback for Heroes 3 style
selected_character_alpha = 1.0;
alpha_direction = -0.02;
grid_highlight_x = -1;
grid_highlight_y = -1;
hover_valid = false;
hover_character_preview = noone;

// Enhanced validation for battle grid positioning
function is_valid_placement_position(check_x, check_y, ignore_index) {
    // Convert pixel coordinates to grid coordinates
    var grid_x = floor((check_x - arena_left) / grid_size);
    var grid_y = floor((check_y - arena_top) / grid_size);
    
    // Check if position is within player placement area
    if (grid_x < player_grid_left || grid_x > player_grid_right ||
        grid_y < player_grid_top || grid_y > player_grid_bottom) {
        return false;
    }
    
    // Check if grid coordinates are within bounds
    if (grid_x < 0 || grid_x >= battle_grid_cols || grid_y < 0 || grid_y >= battle_grid_rows) {
        return false;
    }
    
    // Check if grid position is already occupied
    if (battle_grid[grid_x][grid_y] != noone) {
        // Check if it's occupied by the character we're moving (ignore_index)
        var occupied_by_current = false;
        if (ignore_index >= 0 && ignore_index < array_length(crew_to_place)) {
            var current_char = crew_to_place[ignore_index];
            if (current_char.placed) {
                var current_grid_x = floor((current_char.final_x - arena_left) / grid_size);
                var current_grid_y = floor((current_char.final_y - arena_top) / grid_size);
                if (current_grid_x == grid_x && current_grid_y == grid_y) {
                    occupied_by_current = true;
                }
            }
        }
        
        if (!occupied_by_current) {
            return false;  // Position is occupied by another character
        }
    }
    
    return true;
}

// Helper function to convert grid coordinates to pixel coordinates (arena-relative)
function grid_to_pixel(grid_x, grid_y) {
    return {
        x: arena_left + (grid_x * grid_size) + (grid_size / 2),
        y: arena_top + (grid_y * grid_size) + (grid_size / 2)
    };
}

// Helper function to convert pixel coordinates to grid coordinates (arena-relative)
function pixel_to_grid(pixel_x, pixel_y) {
    return {
        x: floor((pixel_x - arena_left) / grid_size),
        y: floor((pixel_y - arena_top) / grid_size)
    };
}

// Enhanced snap to battle grid (centers character in grid cell)
function snap_to_grid(pos_x, pos_y) {
    var grid_coord = pixel_to_grid(pos_x, pos_y);
    
    // Clamp to valid player placement area
    grid_coord.x = clamp(grid_coord.x, player_grid_left, player_grid_right);
    grid_coord.y = clamp(grid_coord.y, player_grid_top, player_grid_bottom);
    
    // Convert back to pixel coordinates
    var pixel_coord = grid_to_pixel(grid_coord.x, grid_coord.y);
    
    show_debug_message("Snap: (" + string(pos_x) + "," + string(pos_y) + ") -> grid(" + string(grid_coord.x) + "," + string(grid_coord.y) + ") -> pixel(" + string(pixel_coord.x) + "," + string(pixel_coord.y) + ")");
    return pixel_coord;
}

// Function to update battle grid when character is placed
function update_battle_grid(char_data, old_x, old_y, new_x, new_y) {
    // Clear old position
    if (old_x >= 0 && old_y >= 0) {
        var old_grid = pixel_to_grid(old_x, old_y);
        if (old_grid.x >= 0 && old_grid.x < battle_grid_cols && 
            old_grid.y >= 0 && old_grid.y < battle_grid_rows) {
            battle_grid[old_grid.x][old_grid.y] = noone;
        }
    }
    
    // Set new position
    if (new_x >= 0 && new_y >= 0) {
        var new_grid = pixel_to_grid(new_x, new_y);
        if (new_grid.x >= 0 && new_grid.x < battle_grid_cols && 
            new_grid.y >= 0 && new_grid.y < battle_grid_rows) {
            battle_grid[new_grid.x][new_grid.y] = char_data.visual_instance;
        }
    }
}

// Initialize battle grid with existing enemies
init_battle_grid_with_enemies();

// Create hover preview character (invisible initially)
create_hover_preview();

show_debug_message("PlacementUI initialized with " + string(array_length(crew_to_place)) + " crew members to place");
show_debug_message("Arena: (" + string(arena_left) + "," + string(arena_top) + ") to (" + string(arena_right) + "," + string(arena_bottom) + ")");
show_debug_message("Battle grid: " + string(battle_grid_cols) + "x" + string(battle_grid_rows) + " (" + string(grid_size) + "px cells)");

// Debug: Print crew member info
for (var i = 0; i < array_length(crew_to_place); i++) {
    var crew_data = crew_to_place[i];
    show_debug_message("Crew " + string(i) + ": " + crew_data.crew_member.full_name + " placed=" + string(crew_data.placed));
}

// Helper function to create hover preview character
function create_hover_preview() {
    if (hover_character_preview == noone && array_length(crew_to_place) > 0) {
        hover_character_preview = instance_create_layer(-100, -100, "Instances", obj_Player);
        with (hover_character_preview) {
            visible = false;
            state = TURNSTATE.inactive;
        }
    }
}

// Function to update hover preview character appearance
function update_hover_preview(crew_member) {
    if (hover_character_preview != noone) {
        with (hover_character_preview) {
            character_name = crew_member.full_name;
            character_index = crew_member.character_index;
            init_character_sprite_matrix(character_index);
            sprite_index = spr_matrix[0][0]; // idle down
        }
    }
}

// Function to populate battle grid with existing enemies
function init_battle_grid_with_enemies() {
    with (obj_Enemy) {
        var grid_coord = other.pixel_to_grid(x, y);
        if (grid_coord.x >= 0 && grid_coord.x < other.battle_grid_cols && 
            grid_coord.y >= 0 && grid_coord.y < other.battle_grid_rows) {
            other.battle_grid[grid_coord.x][grid_coord.y] = id;
            show_debug_message("Enemy at arena grid position (" + string(grid_coord.x) + "," + string(grid_coord.y) + ") pixel (" + string(x) + "," + string(y) + ")");
        } else {
            show_debug_message("Enemy outside arena at pixel (" + string(x) + "," + string(y) + ") -> grid (" + string(grid_coord.x) + "," + string(grid_coord.y) + ")");
        }
    }
}

show_debug_message("PlacementUI Create event completed successfully");