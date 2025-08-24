// obj_PlacementUI Step Event
// Handle placement input and logic - Heroes 3 style

if (!placement_active || array_length(crew_to_place) == 0) return;

// Initialize input system if not already done
if (!variable_global_exists("input_bindings")) {
    init_input_system();
}

// Update input system
update_input_system();

// Update grid hover position for enhanced visual feedback (arena-based)
var mouse_in_arena = (mouse_x >= arena_left && mouse_x <= arena_right &&
                     mouse_y >= arena_top && mouse_y <= arena_bottom);
var mouse_in_zone = (mouse_x >= placement_zone_left && mouse_x < placement_zone_right &&
                    mouse_y >= placement_zone_top && mouse_y < placement_zone_bottom);

if (mouse_in_arena && mouse_in_zone && current_character_index < array_length(crew_to_place)) {
    // Store mouse position for hover highlighting (not snapped yet)
    grid_highlight_x = mouse_x;
    grid_highlight_y = mouse_y;
    
    // Get the grid position for actual placement
    var mouse_grid_pos = snap_to_grid(mouse_x, mouse_y);
    hover_valid = is_valid_placement_position(mouse_grid_pos.x, mouse_grid_pos.y, current_character_index);
    
    // Update hover preview character (positioned at grid center)
    var current_char = crew_to_place[current_character_index];
    if (!current_char.placed && hover_character_preview != noone) {
        update_hover_preview(current_char.crew_member);
        with (hover_character_preview) {
            x = mouse_grid_pos.x;  // Grid position
            y = mouse_grid_pos.y;  // Grid position
            visible = true;
            image_alpha = other.hover_valid ? 0.8 : 0.4;
        }
    }
} else {
    grid_highlight_x = -1;
    grid_highlight_y = -1;
    if (hover_character_preview != noone) {
        with (hover_character_preview) {
            visible = false;
        }
    }
}

// Update visual feedback alpha
selected_character_alpha += alpha_direction;
if (selected_character_alpha <= 0.3) {
    selected_character_alpha = 0.3;
    alpha_direction = 0.02;
} else if (selected_character_alpha >= 1.0) {
    selected_character_alpha = 1.0;
    alpha_direction = -0.02;
}

// Get navigation input
var nav = input_get_navigation();

// Tab key to cycle through characters
if (nav.next_tab) {
    current_character_index = (current_character_index + 1) % array_length(crew_to_place);
    show_debug_message("Switched to character: " + crew_to_place[current_character_index].crew_member.full_name);
} else if (nav.prev_tab) {
    current_character_index = (current_character_index - 1 + array_length(crew_to_place)) % array_length(crew_to_place);
    show_debug_message("Switched to character: " + crew_to_place[current_character_index].crew_member.full_name);
}

// Get current character being placed
var current_char = crew_to_place[current_character_index];

// Mouse input for placement
if (global.input_mouse.clicked) {
    var mouse_grid_pos = snap_to_grid(mouse_x, mouse_y);
    
    if (is_valid_placement_position(mouse_grid_pos.x, mouse_grid_pos.y, current_character_index)) {
        // Place current character with immediate visualization
        var old_x = current_char.placed ? current_char.final_x : -1;
        var old_y = current_char.placed ? current_char.final_y : -1;
        
        current_char.temp_x = mouse_grid_pos.x;
        current_char.temp_y = mouse_grid_pos.y;
        current_char.final_x = mouse_grid_pos.x;
        current_char.final_y = mouse_grid_pos.y;
        current_char.placed = true;
        
        // Update battle grid
        update_battle_grid(current_char, old_x, old_y, mouse_grid_pos.x, mouse_grid_pos.y);
        
        // Create immediate visual representation
        create_visual_instance(current_char, mouse_grid_pos.x, mouse_grid_pos.y);
        
        show_debug_message("Placed " + current_char.crew_member.full_name + " at (" + string(mouse_grid_pos.x) + "," + string(mouse_grid_pos.y) + ")");
        
        // Move to next unplaced character
        var found_next = false;
        for (var i = 0; i < array_length(crew_to_place); i++) {
            var next_index = (current_character_index + i + 1) % array_length(crew_to_place);
            if (!crew_to_place[next_index].placed) {
                current_character_index = next_index;
                found_next = true;
                break;
            }
        }
        
        if (!found_next) {
            // All characters placed
            check_placement_completion();
        }
    }
}

// Keyboard movement for current character (if already placed)
if (current_char.placed) {
    var move_x = 0;
    var move_y = 0;
    
    if (nav.left) {
        move_x = -grid_size;
    } else if (nav.right) {
        move_x = grid_size;
    }
    
    if (nav.up) {
        move_y = -grid_size;
    } else if (nav.down) {
        move_y = grid_size;
    }
    
    if (move_x != 0 || move_y != 0) {
        var new_x = current_char.final_x + move_x;
        var new_y = current_char.final_y + move_y;
        
        if (is_valid_placement_position(new_x, new_y, current_character_index)) {
            var old_x = current_char.final_x;
            var old_y = current_char.final_y;
            
            current_char.final_x = new_x;
            current_char.final_y = new_y;
            current_char.temp_x = new_x;
            current_char.temp_y = new_y;
            
            // Update battle grid
            update_battle_grid(current_char, old_x, old_y, new_x, new_y);
            
            // Update visual instance position immediately
            if (current_char.visual_instance != noone) {
                with (current_char.visual_instance) {
                    x = new_x;
                    y = new_y;
                }
            }
            
            show_debug_message("Moved " + current_char.crew_member.full_name + " to (" + string(new_x) + "," + string(new_y) + ")");
        }
    }
}

// Enter key to confirm placement and start combat
if (nav.select && placement_completed) {
    finalize_placement();
}

function check_placement_completion() {
    placement_completed = true;
    for (var i = 0; i < array_length(crew_to_place); i++) {
        if (!crew_to_place[i].placed) {
            placement_completed = false;
            break;
        }
    }
    
    if (placement_completed) {
        show_debug_message("All characters placed! Press Enter to start combat.");
    }
}

// Function to create immediate visual representation on battle grid
function create_visual_instance(char_data, pos_x, pos_y) {
    if (char_data.visual_instance == noone) {
        char_data.visual_instance = instance_create_layer(pos_x, pos_y, "Instances", obj_Player);
        
        if (char_data.visual_instance != noone) {
            var crew_member = char_data.crew_member;
            with (char_data.visual_instance) {
                character_name = crew_member.full_name;
                crew_id = crew_member.id;
                character_index = crew_member.character_index;
                
                // Set basic stats for visual representation
                hp = crew_member.hp;
                max_hp = crew_member.max_hp;
                strength = crew_member.strength;
                dexterity = crew_member.dexterity;
                constitution = crew_member.constitution;
                intelligence = crew_member.intelligence;
                wisdom = crew_member.wisdom;
                charisma = crew_member.charisma;
                
                // Set XP and level progression data
                level = crew_member.level;
                xp = crew_member.xp;
                xp_to_next_level = crew_member.xp_to_next_level;
                asis_available = crew_member.asis_available;
                
                // Set equipment
                equipped_weapon_id = crew_member.equipped_weapon_id;
                
                // Initialize appearance and set inactive state
                spr_matrix = init_character_sprite_matrix(character_index);
                sprite_index = spr_matrix[0][0]; // idle down
                state = TURNSTATE.inactive;
                image_alpha = 0.9; // Slightly transparent to indicate placement phase
            }
            
            // Update battle grid with new instance
            var grid_coord = pixel_to_grid(pos_x, pos_y);
            battle_grid[grid_coord.x][grid_coord.y] = char_data.visual_instance;
            
            show_debug_message("Created visual instance for " + crew_member.full_name + " at grid (" + string(grid_coord.x) + "," + string(grid_coord.y) + ")");
        }
    }
}

function finalize_placement() {
    show_debug_message("Finalizing placement and starting combat...");
    
    // Convert visual instances to proper Player instances
    for (var i = 0; i < array_length(crew_to_place); i++) {
        var char_data = crew_to_place[i];
        var crew_member = char_data.crew_member;
        
        // Use existing visual instance or create new one
        var player_instance = char_data.visual_instance;
        if (player_instance == noone) {
            player_instance = instance_create_layer(char_data.final_x, char_data.final_y, "Instances", obj_Player);
        }
        
        if (player_instance != noone) {
            // Ensure all properties are set correctly
            with (player_instance) {
                character_name = crew_member.full_name;
                crew_id = crew_member.id;
                hp = crew_member.hp;
                max_hp = crew_member.max_hp;
                character_index = crew_member.character_index;
                
                // Set D&D stats
                strength = crew_member.strength;
                dexterity = crew_member.dexterity;
                constitution = crew_member.constitution;
                intelligence = crew_member.intelligence;
                wisdom = crew_member.wisdom;
                charisma = crew_member.charisma;
                
                // Set XP and level progression data
                level = crew_member.level;
                xp = crew_member.xp;
                xp_to_next_level = crew_member.xp_to_next_level;
                asis_available = crew_member.asis_available;
                
                // Set equipment
                equipped_weapon_id = crew_member.equipped_weapon_id;
                
                // Update combat stats and finalize for battle
                update_combat_stats();
                spr_matrix = init_character_sprite_matrix(character_index);
                sprite_index = spr_matrix[0][0]; // idle down
                state = TURNSTATE.inactive; // Will be set to active by TurnManager
                image_alpha = 1.0; // Full opacity for combat
            }
            
            char_data.player_instance = player_instance;
            char_data.visual_instance = noone; // Clear visual reference
            show_debug_message("Finalized Player instance for " + crew_member.full_name + " at (" + string(char_data.final_x) + "," + string(char_data.final_y) + ")");
        }
    }
    
    // Signal TurnManager to start combat phase
    var turn_manager = instance_find(obj_TurnManager, 0);
    if (turn_manager != noone) {
        turn_manager.placement_complete = true;
    }
    
    // Clean up hover preview
    if (hover_character_preview != noone) {
        instance_destroy(hover_character_preview);
        hover_character_preview = noone;
    }
    
    // Deactivate placement UI
    placement_active = false;
    instance_destroy();
}