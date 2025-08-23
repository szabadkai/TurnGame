// Enemy AI System - Advanced behavior for intelligent enemies

// === TARGET SELECTION FUNCTIONS ===

function find_best_target(enemy_instance) {
    // Find all players and evaluate them as targets
    var best_target = noone;
    var best_score = -1;
    
    with (obj_Player) {
        if (hp > 0) {  // Only target living players
            var target_score = evaluate_target_priority(enemy_instance, self);
            if (target_score > best_score) {
                best_score = target_score;
                best_target = self;
            }
        }
    }
    
    return best_target;
}

function evaluate_target_priority(enemy, target) {
    // Scoring system for target selection (higher = better target)
    score = 0;
    
    // 1. Distance factor (closer is better, but not too heavy)
    var distance = point_distance(enemy.x, target.x, enemy.y, target.y) / 16; // Convert to tiles
    score += max(0, 10 - distance); // Score decreases with distance
    
    // 2. HP factor (lower HP = higher priority for finishing kills)
    var hp_percentage = target.hp / target.max_hp;
    if (hp_percentage <= 0.25) score += 20; // Critical HP - very high priority
    else if (hp_percentage <= 0.5) score += 10; // Low HP - high priority
    else if (hp_percentage <= 0.75) score += 5;  // Medium HP - moderate priority
    
    // 3. Threat assessment (stronger players are more dangerous)
    score += target.level * 2; // Higher level = more threat
    score += target.attack_bonus; // Higher attack bonus = more threat
    
    // 4. Status effects (prioritize players who are vulnerable)
    if (target.frozen_turns > 0) score += 15; // Frozen players are easy targets
    if (target.burn_turns > 0) score += 5;    // Burning players are already taking damage
    
    return score;
}

// === PATHFINDING FUNCTIONS ===

function find_path_to_target(start_x, start_y, target_x, target_y) {
    // Simple pathfinding - returns next direction to move toward target
    var dx = target_x - start_x;
    var dy = target_y - start_y;
    
    // Convert to tile coordinates
    var tile_dx = dx / 16;
    var tile_dy = dy / 16;
    
    // Determine primary movement direction
    if (abs(tile_dx) > abs(tile_dy)) {
        // Move horizontally first
        if (tile_dx > 0) return Dir.RIGHT;
        else return Dir.LEFT;
    } else {
        // Move vertically first
        if (tile_dy > 0) return Dir.DOWN;
        else return Dir.UP;
    }
}

function can_move_in_direction(enemy, direction) {
    // Check if enemy can move in the specified direction
    var new_x = enemy.x;
    var new_y = enemy.y;
    
    switch (direction) {
        case Dir.RIGHT: new_x += 16; break;
        case Dir.LEFT:  new_x -= 16; break;
        case Dir.UP:    new_y -= 16; break;
        case Dir.DOWN:  new_y += 16; break;
    }
    
    // Check collision with walls and other characters
    return place_free_position(new_x, new_y, enemy);
}

function place_free_position(check_x, check_y, checker) {
    // Check if position is free using character base collision system
    // This now includes both object collision and tile collision
    
    with (checker) {
        if (!can_move_to(check_x, check_y)) {
            return false;
        }
    }
    
    // Check for other characters (players and enemies) at this position
    var collision = false;
    with (character_base) {
        if (id != checker.id && x == check_x && y == check_y) {
            collision = true;
            break;
        }
    }
    
    return !collision;
}

// === COMBAT POSITIONING FUNCTIONS ===

function get_optimal_combat_distance(enemy, target) {
    // Determine optimal distance based on weapon type
    var weapon = global.weapons[enemy.equipped_weapon_id];
    
    switch (weapon.special_type) {
        case "ranged":
            return 4; // Stay 4 tiles away for ranged weapons
        case "area_attack":
            return 1; // Get close for area attacks
        default:
            return 1; // Melee range for most weapons
    }
}

function is_in_attack_range(enemy, target) {
    // Check if target is within attack range
    var distance = point_distance(enemy.x, target.x, enemy.y, target.y) / 16;
    var weapon = global.weapons[enemy.equipped_weapon_id];
    
    if (weapon.special_type == "ranged") {
        return (distance <= 4 && has_line_of_sight(enemy, target));
    } else {
        return (distance <= 1.5); // Adjacent tiles for melee
    }
}

function has_line_of_sight(from_obj, to_obj) {
    // Simple line of sight check (for ranged weapons)
    // This is a basic implementation - you may want to make it more sophisticated
    return !collision_line(from_obj.x, from_obj.y, to_obj.x, to_obj.y, obj_Wall, false, true);
}

// === AI PERSONALITY FUNCTIONS ===

function get_ai_behavior_type(enemy) {
    // Determine AI behavior based on enemy type and weapon
    var weapon = global.weapons[enemy.equipped_weapon_id];
    
    // Base behavior on enemy name/type
    switch (enemy.character_name) {
        case "Goblin Scout":
            return "aggressive"; // Rush in quickly
        case "Orc Grunt":
            return "aggressive"; // Direct assault
        case "Skeleton":
            return "tactical";   // Calculated movements
        case "Bandit":
            return "defensive";  // Maintain distance if possible
        case "Wolf":
            return "aggressive"; // Pack hunter behavior
        default:
            return "aggressive";
    }
}

// === DECISION MAKING FUNCTIONS ===

function decide_enemy_action(enemy) {
    // Main AI decision function - returns action type: "move", "attack", or "wait"
    var target = find_best_target(enemy);
    
    if (target == noone) {
        return { action: "wait", target: noone, direction: Dir.DOWN };
    }
    
    var in_range = is_in_attack_range(enemy, target);
    var behavior = get_ai_behavior_type(enemy);
    var optimal_distance = get_optimal_combat_distance(enemy, target);
    var current_distance = point_distance(enemy.x, target.x, enemy.y, target.y) / 16;
    
    // Decision logic based on behavior type
    switch (behavior) {
        case "aggressive":
            if (in_range) {
                return { action: "attack", target: target, direction: get_direction_to_target(enemy, target) };
            } else {
                var move_dir = find_path_to_target(enemy.x, enemy.y, target.x, target.y);
                if (can_move_in_direction(enemy, move_dir)) {
                    return { action: "move", target: target, direction: move_dir };
                } else {
                    // Try alternative directions if primary path is blocked
                    var alt_dirs = get_alternative_directions(move_dir);
                    for (var i = 0; i < array_length(alt_dirs); i++) {
                        if (can_move_in_direction(enemy, alt_dirs[i])) {
                            return { action: "move", target: target, direction: alt_dirs[i] };
                        }
                    }
                    return { action: "wait", target: target, direction: Dir.DOWN };
                }
            }
            break;
            
        case "defensive":
            if (in_range && current_distance >= optimal_distance) {
                return { action: "attack", target: target, direction: get_direction_to_target(enemy, target) };
            } else if (current_distance < optimal_distance) {
                // Move away to maintain optimal distance
                var move_dir = get_retreat_direction(enemy, target);
                if (can_move_in_direction(enemy, move_dir)) {
                    return { action: "move", target: target, direction: move_dir };
                }
            } else if (!in_range) {
                // Move closer to get in range
                var move_dir = find_path_to_target(enemy.x, enemy.y, target.x, target.y);
                if (can_move_in_direction(enemy, move_dir)) {
                    return { action: "move", target: target, direction: move_dir };
                }
            }
            return { action: "wait", target: target, direction: Dir.DOWN };
            break;
            
        case "tactical":
            // More complex decision making for tactical enemies
            if (in_range) {
                return { action: "attack", target: target, direction: get_direction_to_target(enemy, target) };
            } else {
                var move_dir = find_tactical_position(enemy, target);
                if (can_move_in_direction(enemy, move_dir)) {
                    return { action: "move", target: target, direction: move_dir };
                } else {
                    return { action: "wait", target: target, direction: Dir.DOWN };
                }
            }
            break;
    }
    
    return { action: "wait", target: target, direction: Dir.DOWN };
}

// === HELPER FUNCTIONS ===

// Use shared get_direction_to_target() from ai_shared for direction calculations

function get_retreat_direction(from_obj, away_from_obj) {
    // Get direction to move away from target
    var dx = from_obj.x - away_from_obj.x;
    var dy = from_obj.y - away_from_obj.y;
    
    if (abs(dx) > abs(dy)) {
        return (dx > 0) ? Dir.RIGHT : Dir.LEFT;
    } else {
        return (dy > 0) ? Dir.DOWN : Dir.UP;
    }
}

function get_alternative_directions(primary_dir) {
    // Get alternative directions if primary path is blocked
    switch (primary_dir) {
        case Dir.RIGHT: return [Dir.UP, Dir.DOWN, Dir.LEFT];
        case Dir.LEFT:  return [Dir.UP, Dir.DOWN, Dir.RIGHT];
        case Dir.UP:    return [Dir.LEFT, Dir.RIGHT, Dir.DOWN];
        case Dir.DOWN:  return [Dir.LEFT, Dir.RIGHT, Dir.UP];
        default:        return [Dir.RIGHT, Dir.LEFT, Dir.UP, Dir.DOWN];
    }
}

function find_tactical_position(enemy, target) {
    // Find tactically advantageous position (for tactical AI)
    // This could involve flanking, surrounding, or positioning for special attacks
    
    // For now, implement basic flanking behavior
    var target_dir = get_direction_to_target(target, enemy);
    
    // Try to approach from the side rather than directly
    switch (target_dir) {
        case Dir.RIGHT:
        case Dir.LEFT:
            return choose(Dir.UP, Dir.DOWN);
        case Dir.UP:
        case Dir.DOWN:
            return choose(Dir.LEFT, Dir.RIGHT);
        default:
            return find_path_to_target(enemy.x, enemy.y, target.x, target.y);
    }
}

// === WEAPON SPECIAL EFFECTS ===

function handle_weapon_special_effects(attacker, target) {
    // Apply post-attack special effects based on weapon type
    var special = attacker.weapon_special_type;
    
    switch(special) {
        case "freeze":
            if (random(100) < 50) {  // 50% chance
                target.frozen_turns = 2;
                scr_log(target.character_name + " is FROZEN for 2 turns!");
            }
            break;
            
        case "burn":
            if (random(100) < 25) {  // 25% chance
                target.burn_turns = 3;
                scr_log(target.character_name + " is BURNING for 3 turns!");
            }
            break;
            
        case "chain_lightning":
            // Lightning chains to adjacent enemies/players
            apply_chain_lightning(attacker, target);
            break;
            
        case "area_attack":
            // War hammer hits all adjacent targets
            apply_area_attack(attacker);
            break;
    }
}

function apply_chain_lightning(caster, initial_target) {
    // Chain lightning effect - hits adjacent characters
    var chain_damage = 2;  // Base chain damage
    var chained_to = [];
    array_push(chained_to, initial_target.id);
    
    scr_log("Lightning chains from " + initial_target.character_name + "!");
    
    // Find adjacent characters to chain to
    with (character_base) {
        if (id != initial_target.id && id != caster.id && hp > 0) {
            var distance = point_distance(x, y, initial_target.x, initial_target.y);
            if (distance <= 24) {  // Adjacent or close
                hp -= chain_damage;
                array_push(chained_to, id);
                
                if (variable_global_exists("combat_log")) {
                    global.combat_log(character_name + " takes " + string(chain_damage) + " chain lightning damage!");
                }
                
                // Only chain once to prevent infinite loops
                break;
            }
        }
    }
}

function apply_area_attack(attacker) {
    // Area attack hits all adjacent characters
    var area_damage = 1;  // Reduced damage for area effect
    
    if (variable_global_exists("combat_log")) {
        global.combat_log(attacker.character_name + "'s attack hits all adjacent foes!");
    }
    
    with (character_base) {
        if (id != attacker.id && hp > 0) {
            var distance = point_distance(x, y, attacker.x, attacker.y);
            if (distance <= 24) {  // Adjacent
                hp -= area_damage;
                
                if (variable_global_exists("combat_log")) {
                    global.combat_log(character_name + " takes " + string(area_damage) + " area damage!");
                }
            }
        }
    }
}

// === BASIC AI FALLBACK ===

function basic_enemy_ai() {
    // Simple fallback AI - just attack adjacent player
    var target_player = instance_place(x + 16, y, obj_Player);
    if (!target_player) target_player = instance_place(x - 16, y, obj_Player);
    if (!target_player) target_player = instance_place(x, y + 16, obj_Player);
    if (!target_player) target_player = instance_place(x, y - 16, obj_Player);
    
    if (target_player) {
        // Attack the adjacent player
        var _direction = Dir.DOWN;  // Default direction
        var dx = target_player.x - x;
        var dy = target_player.y - y;
        
        if (abs(dx) > abs(dy)) {
            _direction = (dx > 0) ? Dir.RIGHT : Dir.LEFT;
        } else {
            _direction = (dy > 0) ? Dir.DOWN : Dir.UP;
        }
        
        return { action: "attack", target: target_player, direction: _direction };
    } else {
        return { action: "wait", target: noone, direction: Dir.DOWN };
    }
}
