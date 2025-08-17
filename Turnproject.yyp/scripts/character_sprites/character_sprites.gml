// Character Sprite System
// Provides sprite lookup based on character index, direction, and animation state

function get_character_sprite(character_index, direction, animation_state, weapon_special_type = "none") {
    // Clamp character_index to valid range (1-7)
    character_index = clamp(character_index, 1, 7);
    
    // Define direction constants matching the existing Dir enum
    var DIR_UP = 0;
    var DIR_DOWN = 1;  
    var DIR_LEFT = 2;
    var DIR_RIGHT = 3;
    
    // Define animation state constants matching existing State enum
    var STATE_IDLE = 0;
    var STATE_RUN = 1;
    var STATE_ATTACK = 2;
    
    // Create sprite lookup table based on character index
    var sprite_prefix = "chr" + string(character_index) + "_";
    
    // Direction suffixes
    var dir_suffix = "";
    switch(direction) {
        case DIR_UP: dir_suffix = "up"; break;
        case DIR_DOWN: dir_suffix = "down"; break;
        case DIR_LEFT: dir_suffix = "left"; break;
        case DIR_RIGHT: dir_suffix = "right"; break;
        default: dir_suffix = "down"; break;
    }
    
    // Animation state suffixes with weapon-aware logic
    var state_suffix = "";
    
    switch(animation_state) {
        case STATE_IDLE: 
            // For idle, only add weapon suffix for pistol (pistol has special idle sprites)
            if (weapon_special_type == "ranged") {
                state_suffix = "idle_pistol";
            } else {
                state_suffix = "idle";  // No weapon suffix for sword idle
            }
            break;
            
        case STATE_RUN: 
            if (weapon_special_type == "ranged") {
                state_suffix = "run_pistol";
            } else {
                state_suffix = "run_sword";
            }
            break;
            
        case STATE_ATTACK: 
            if (weapon_special_type == "ranged") {
                state_suffix = "attack_pistol";
            } else {
                state_suffix = "attack_sword";
            }
            break;
            
        default: 
            // Default to idle without weapon suffix
            state_suffix = "idle";
            break;
    }
    
    // Construct sprite name
    var sprite_name = sprite_prefix + state_suffix + "_" + dir_suffix;
    
    // Use asset_get_index to get the sprite resource ID
    var sprite_id = asset_get_index(sprite_name);
    
    // Fallback to sword/idle version if pistol sprite doesn't exist
    if (sprite_id == -1 && weapon_special_type == "ranged") {
        // Try falling back to sword version for run/attack, or plain idle for idle
        if (animation_state == STATE_IDLE) {
            state_suffix = "idle";
        } else if (animation_state == STATE_RUN) {
            state_suffix = "run_sword";
        } else if (animation_state == STATE_ATTACK) {
            state_suffix = "attack_sword";
        }
        sprite_name = sprite_prefix + state_suffix + "_" + dir_suffix;
        sprite_id = asset_get_index(sprite_name);
    }
    
    // Fallback to character 1 if sprite doesn't exist
    if (sprite_id == -1) {
        sprite_name = "chr1_" + state_suffix + "_" + dir_suffix;
        sprite_id = asset_get_index(sprite_name);
    }
    
    // Final fallback to dummy sprite if still not found
    if (sprite_id == -1) {
        sprite_id = dummy;
    }
    
    return sprite_id;
}

function init_character_sprite_matrix(character_index, weapon_special_type = "none") {
    // Create and return a sprite matrix for the given character index and weapon type
    // Matrix format: [direction][animation_state]
    
    var sprite_matrix = array_create(4);
    
    // Initialize each direction
    for (var dir = 0; dir < 4; dir++) {
        sprite_matrix[dir] = array_create(3);
        
        // Initialize each animation state for this direction
        for (var state = 0; state < 3; state++) {
            sprite_matrix[dir][state] = get_character_sprite(character_index, dir, state, weapon_special_type);
        }
    }
    
    return sprite_matrix;
}

function update_sprite_matrix(character_index, weapon_special_type) {
    // Update existing sprite matrix with new weapon type
    // This function should be called when weapons change
    return init_character_sprite_matrix(character_index, weapon_special_type);
}