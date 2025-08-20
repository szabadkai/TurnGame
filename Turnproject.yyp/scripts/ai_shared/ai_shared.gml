// Shared AI Functions - Reusable pathfinding and decision-making for all characters

// === TARGET SELECTION ===

function find_closest_target(seeker, target_object_type) {
    // Find the closest instance of target_object_type to the seeker
    var closest_target = noone;
    var closest_distance = 999;
    
    with (target_object_type) {
        if (hp > 0) {  // Only target living characters
            var dist = point_distance(other.x, other.y, x, y) / 16;  // Distance in tiles
            if (dist < closest_distance) {
                closest_distance = dist;
                closest_target = self;
            }
        }
    }
    
    return { target: closest_target, distance: closest_distance };
}

function find_best_target_by_priority(seeker, target_object_type) {
    // More advanced target selection considering HP, threat level, etc.
    var best_target = noone;
    var best_score = -1;
    
    with (target_object_type) {
        if (hp > 0) {  // Only target living characters
            var score = 0;
            var distance = point_distance(seeker.x, seeker.y, x, y) / 16;
            
            // Distance factor (closer is better)
            score += max(0, 10 - distance);
            
            // HP factor (lower HP = higher priority for finishing kills)
            var hp_percentage = hp / max_hp;
            if (hp_percentage <= 0.25) score += 20; // Critical HP - very high priority
            else if (hp_percentage <= 0.5) score += 10; // Low HP - high priority
            else if (hp_percentage <= 0.75) score += 5;  // Medium HP - moderate priority
            
            // Threat assessment (stronger targets are more dangerous)
            if (variable_instance_exists(id, "level")) score += level * 2;
            if (variable_instance_exists(id, "attack_bonus")) score += attack_bonus;
            
            // Status effects (vulnerable targets are easier)
            if (variable_instance_exists(id, "frozen_turns") && frozen_turns > 0) score += 15;
            if (variable_instance_exists(id, "burn_turns") && burn_turns > 0) score += 5;
            
            if (score > best_score) {
                best_score = score;
                best_target = self;
            }
        }
    }
    
    return best_target;
}

// === PATHFINDING ===

function get_direction_to_target(from_x, from_y, to_x, to_y) {
    // Get the primary direction from one position to another
    var dx = to_x - from_x;
    var dy = to_y - from_y;
    
    if (abs(dx) > abs(dy)) {
        return (dx > 0) ? Dir.RIGHT : Dir.LEFT;
    } else {
        return (dy > 0) ? Dir.DOWN : Dir.UP;
    }
}

function get_position_in_direction(start_x, start_y, direction, distance = 16) {
    // Calculate new position when moving in a direction
    var new_x = start_x;
    var new_y = start_y;
    
    switch (direction) {
        case Dir.RIGHT: new_x += distance; break;
        case Dir.LEFT:  new_x -= distance; break;
        case Dir.UP:    new_y -= distance; break;
        case Dir.DOWN:  new_y += distance; break;
    }
    
    return { x: new_x, y: new_y };
}

function can_move_to_position(mover, target_x, target_y) {
    // Check if a character can move to a specific position
    
    // Check for solid obstacles (walls, etc.)
    if (!place_free(target_x, target_y)) {
        return false;
    }
    
    // Check for other characters at that exact position
    var collision = false;
    with (character_base) {
        if (id != mover.id && x == target_x && y == target_y) {
            collision = true;
            break;
        }
    }
    
    if (collision) {
        return false;
    }
    
    // Additional check: make sure no character is already at the target position
    // This catches cases where characters might be moving simultaneously
    var occupied = false;
    with (obj_Player) {
        if (x == target_x && y == target_y) {
            occupied = true;
            break;
        }
    }
    
    if (!occupied) {
        with (obj_Enemy) {
            if (id != mover.id && x == target_x && y == target_y) {
                occupied = true;
                break;
            }
        }
    }
    
    return !occupied;
}

function find_valid_move_direction(mover, target_x, target_y) {
    // Find a valid direction to move toward a target, with fallback alternatives
    var primary_dir = get_direction_to_target(mover.x, mover.y, target_x, target_y);
    var new_pos = get_position_in_direction(mover.x, mover.y, primary_dir);
    
    // Try primary direction first
    if (can_move_to_position(mover, new_pos.x, new_pos.y)) {
        return primary_dir;
    }
    
    // Try alternative directions if primary is blocked
    var alt_directions = [];
    if (primary_dir == Dir.RIGHT || primary_dir == Dir.LEFT) {
        alt_directions = [Dir.UP, Dir.DOWN];
    } else {
        alt_directions = [Dir.LEFT, Dir.RIGHT];
    }
    
    for (var i = 0; i < array_length(alt_directions); i++) {
        var alt_dir = alt_directions[i];
        new_pos = get_position_in_direction(mover.x, mover.y, alt_dir);
        
        if (can_move_to_position(mover, new_pos.x, new_pos.y)) {
            return alt_dir;
        }
    }
    
    // If still blocked, try the opposite of primary direction as last resort
    var opposite_dir;
    switch (primary_dir) {
        case Dir.RIGHT: opposite_dir = Dir.LEFT; break;
        case Dir.LEFT:  opposite_dir = Dir.RIGHT; break;
        case Dir.UP:    opposite_dir = Dir.DOWN; break;
        case Dir.DOWN:  opposite_dir = Dir.UP; break;
        default: opposite_dir = noone; break;
    }
    
    if (opposite_dir != noone) {
        new_pos = get_position_in_direction(mover.x, mover.y, opposite_dir);
        if (can_move_to_position(mover, new_pos.x, new_pos.y)) {
            return opposite_dir;
        }
    }
    
    // No valid movement found
    return noone;
}

function find_flanking_position(mover, target_x, target_y) {
    // Find a position that's adjacent to the target but not directly in line
    // This helps enemies surround the player instead of clustering in one spot
    
    var adjacent_positions = [
        { x: target_x + 16, y: target_y, dir: Dir.RIGHT },  // Right of target
        { x: target_x - 16, y: target_y, dir: Dir.LEFT },   // Left of target
        { x: target_x, y: target_y - 16, dir: Dir.UP },     // Above target
        { x: target_x, y: target_y + 16, dir: Dir.DOWN }    // Below target
    ];
    
    // Shuffle the positions to add variety to enemy positioning
    for (var i = array_length(adjacent_positions) - 1; i > 0; i--) {
        var j = irandom(i);
        var temp = adjacent_positions[i];
        adjacent_positions[i] = adjacent_positions[j];
        adjacent_positions[j] = temp;
    }
    
    // Find the first available flanking position
    for (var i = 0; i < array_length(adjacent_positions); i++) {
        var pos = adjacent_positions[i];
        if (can_move_to_position(mover, pos.x, pos.y)) {
            // Check if we can reach this position
            var move_dir = find_valid_move_direction(mover, pos.x, pos.y);
            if (move_dir != noone) {
                return move_dir;
            }
        }
    }
    
    // No flanking position available, fall back to regular pathfinding
    return find_valid_move_direction(mover, target_x, target_y);
}

// === RANGE AND POSITIONING ===

function is_adjacent_to_target(from_x, from_y, to_x, to_y) {
    // Check if two positions are adjacent (within 1.5 tiles)
    var distance = point_distance(from_x, from_y, to_x, to_y) / 16;
    return (distance <= 1.5);
}

function get_distance_in_tiles(from_x, from_y, to_x, to_y) {
    // Get distance between two positions in tiles
    return point_distance(from_x, from_y, to_x, to_y) / 16;
}

function is_in_weapon_range(attacker, target) {
    // Check if target is within weapon range based on weapon type
    if (!variable_instance_exists(attacker, "weapon_special_type")) return false;
    
    var distance = get_distance_in_tiles(attacker.x, attacker.y, target.x, target.y);
    
    switch (attacker.weapon_special_type) {
        case "ranged":
            return (distance <= 4);  // 4 tile range for ranged weapons
        default:
            return is_adjacent_to_target(attacker.x, attacker.y, target.x, target.y);  // Melee range
    }
}

// === AI DECISION MAKING ===

function make_ai_decision(character, target_type = obj_Player) {
    // Main AI decision function that returns an action decision
    
    // Find the best target
    var target_info = find_closest_target(character, target_type);
    var target = target_info.target;
    var distance = target_info.distance;
    
    if (target == noone) {
        return { action: "wait", target: noone, direction: Dir.DOWN };
    }
    
    // Determine direction to face target
    var face_direction = get_direction_to_target(character.x, character.y, target.x, target.y);
    
    // Decide action based on distance and weapon capabilities
    if (is_in_weapon_range(character, target)) {
        // In range - attack
        return { action: "attack", target: target, direction: face_direction };
    } else {
        // Not in range - try to move closer with intelligent positioning
        var move_direction;
        
        // If close to target (within 3 tiles), use flanking to avoid clustering
        if (distance <= 3) {
            move_direction = find_flanking_position(character, target.x, target.y);
        } else {
            // If far from target, use direct pathfinding
            move_direction = find_valid_move_direction(character, target.x, target.y);
        }
        
        if (move_direction != noone) {
            return { action: "move", target: target, direction: move_direction };
        } else {
            // Can't move - wait (maybe target will come closer or other enemies will move)
            return { action: "wait", target: target, direction: face_direction };
        }
    }
}

// === COMBAT UTILITIES ===

function execute_ai_action(character, ai_decision) {
    // Execute an AI decision (move, attack, or wait)
    // This is a helper function that can be called from character Step events
    
    switch (ai_decision.action) {
        case "attack":
            if (ai_decision.target != noone && is_in_weapon_range(character, ai_decision.target)) {
                // Set up attack animation
                character.dir = ai_decision.direction;
                character.anim_state = State.ATTACK;
                character.sprite_index = character.spr_matrix[character.dir][character.anim_state];
                character.image_index = 0;
                character.image_speed = 1.0;
                character.is_anim = true;
                
                // Store target for attack resolution
                character.target_player = ai_decision.target;
                return true;
            }
            break;
            
        case "move":
            var new_pos = get_position_in_direction(character.x, character.y, ai_decision.direction);
            if (can_move_to_position(character, new_pos.x, new_pos.y)) {
                // Set up movement animation
                character.dir = ai_decision.direction;
                character.anim_state = State.RUN;
                character.sprite_index = character.spr_matrix[character.dir][character.anim_state];
                character.image_index = 0;
                character.image_speed = 1.0;
                character.is_anim = true;
                
                // Log movement
                if (variable_global_exists("combat_log")) {
                    var target_name = (ai_decision.target != noone) ? ai_decision.target.character_name : "target";
                    global.combat_log(character.character_name + " moves toward " + target_name + "!");
                }
                return true;
            }
            break;
            
        case "wait":
        default:
            // End turn
            if (variable_global_exists("combat_log")) {
                global.combat_log(character.character_name + " waits...");
            }
            character.moves = 0;
            character.alarm[0] = 1;
            return true;
    }
    
    return false;
}