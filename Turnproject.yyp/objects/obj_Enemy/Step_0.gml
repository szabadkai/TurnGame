// === STATUS EFFECTS ===
if (frozen_turns > 0) {
    if (state == TURNSTATE.active) {
        if (variable_global_exists("combat_log")) global.combat_log(character_name + " is FROZEN! Skipping turn...");
        frozen_turns--;
        alarm[0] = 1;
        exit;
    }
}

if (burn_turns > 0 && state == TURNSTATE.active) {
    hp -= 1;
    burn_turns--;
    if (variable_global_exists("combat_log")) global.combat_log(character_name + " takes 1 BURN damage! (" + string(burn_turns) + " turns remaining)");
    if (hp <= 0) {
        if (variable_global_exists("combat_log")) global.combat_log(character_name + " burned to death!");
    }
}

// === DEATH HANDLING (CHECK FIRST) ===
if (hp <= 0) {
    if (!dying) {
        // Log enemy death
        if (variable_global_exists("combat_log")) {
            global.combat_log("*** " + character_name + " HAS DIED! ***");
        }

        // If this enemy was taking its turn, we need to pass the turn
        var was_active = (state == TURNSTATE.active);

        // Remove from turn list BEFORE starting death animation
        if (instance_exists(obj_TurnManager) && ds_exists(obj_TurnManager.turn_list, ds_type_list)) {
            var turn_index = ds_list_find_index(obj_TurnManager.turn_list, id);
            if (turn_index >= 0) {
                ds_list_delete(obj_TurnManager.turn_list, turn_index);
            }
        }

        // If enemy was active, trigger turn rotation to next character
        if (was_active) {
            state = TURNSTATE.inactive;  // Clean up state
            with (obj_TurnManager) {
                event_user(0);  // Rotate to next turn
            }
        }

        // Start death animation
        dying = true;
        anim_state = State.DIE;
        // Ensure sprite matrix contains death state
        if (spr_matrix == undefined) spr_matrix = init_character_sprite_matrix(character_index);
        var die_sprite = spr_matrix[dir][State.DIE];
        if (die_sprite == undefined || !sprite_exists(die_sprite)) {
            // Fallback to generic death sprite
            die_sprite = asset_get_index("Sprite103");
        }
        if (die_sprite != -1) {
            sprite_index = die_sprite;
        }
        image_index = 0;
        image_speed = 0.8;
        is_anim = true;
    } else {
        // Already in death animation: destroy when it finishes
        if (image_index >= sprite_get_number(sprite_index) - 1) {
            instance_destroy();
        }
    }
    exit; // Stop processing this step event
}

// === SPRITE ANIMATION ===
// Ensure proper animation state initialization
if (!variable_instance_exists(id, "anim_state") || anim_state == undefined) {
    anim_state = State.IDLE;
}
if (!variable_instance_exists(id, "dir") || dir == undefined) {
    dir = Dir.DOWN;
}

// Update sprite based on current state (only when not animating)
if (!is_anim && variable_instance_exists(id, "spr_matrix") && spr_matrix != undefined) {
    // Ensure dir and anim_state are valid indices
    if (dir >= 0 && dir < array_length(spr_matrix) && 
        anim_state >= 0 && anim_state < array_length(spr_matrix[dir])) {
        var new_sprite = spr_matrix[dir][anim_state];
        if (new_sprite != undefined && sprite_exists(new_sprite)) {
            if (sprite_index != new_sprite) {
                // Special debug for left direction idle issues
                if (dir == Dir.LEFT && anim_state == State.IDLE) {
                    show_debug_message(character_name + " LEFT IDLE: changing from " + string(sprite_index) + " to " + string(new_sprite) + " (char_index:" + string(character_index) + ")");
                }
                sprite_index = new_sprite;
            }
        } else {
            show_debug_message(character_name + " ERROR: Invalid sprite at dir:" + string(dir) + " anim:" + string(anim_state) + " sprite_id:" + string(new_sprite));
            // Fallback to a different direction if left idle is broken
            if (dir == Dir.LEFT && anim_state == State.IDLE) {
                var fallback_sprite = spr_matrix[Dir.DOWN][State.IDLE]; // Use down idle as fallback
                if (fallback_sprite != undefined && sprite_exists(fallback_sprite)) {
                    show_debug_message(character_name + " Using down idle as fallback for broken left idle");
                    sprite_index = fallback_sprite;
                }
            }
        }
    }
}

// === ENHANCED ENEMY AI ===
if (state == TURNSTATE.active && !is_anim) {
    // Initialize moves for enemies (they get 1 action per turn)
    if (moves == 0) {
        max_moves = 1;
        moves = 1;
        show_debug_message("=== " + character_name + " Turn ===");
    }
    
    if (moves > 0) {
        // Use AI decision system to determine action
        var ai_decision;
        
        // Enhanced AI with anti-stacking - find closest player and move intelligently
        var closest_player = noone;
        var closest_distance = 999;
        
        // Find the closest living player
        with (obj_Player) {
            if (hp > 0) {
                var dist = point_distance(other.x, other.y, x, y) / 16;
                if (dist < closest_distance) {
                    closest_distance = dist;
                    closest_player = self;
                }
            }
        }
        
        if (closest_player != noone) {
            var engagement_direction = Dir.DOWN;
            var dx = closest_player.x - x;
            var dy = closest_player.y - y;
            
            // Calculate direction to target
            if (abs(dx) > abs(dy)) {
                engagement_direction = (dx > 0) ? Dir.RIGHT : Dir.LEFT;
            } else {
                engagement_direction = (dy > 0) ? Dir.DOWN : Dir.UP;
            }
            
            // Check if adjacent (within attack range)
            if (closest_distance <= 1.5) {
                // Attack the player
                ai_decision = { action: "attack", target: closest_player, direction: engagement_direction };
            } else {
                // Move toward player with anti-stacking logic
                var move_direction = noone;
                var can_move_primary = false;
                
                // Try primary direction first
                var new_x = x;
                var new_y = y;
                switch (engagement_direction) {
                    case Dir.RIGHT: new_x += 16; break;
                    case Dir.LEFT:  new_x -= 16; break;
                    case Dir.UP:    new_y -= 16; break;
                    case Dir.DOWN:  new_y += 16; break;
                }
                
                // Check if position is free (walls and characters)
                can_move_primary = place_free(new_x, new_y);
                if (can_move_primary) {
                    // Check for ALL players at exact position
                    with (obj_Player) {
                        if (x == new_x && y == new_y) {
                            can_move_primary = false;
                            show_debug_message(other.character_name + " blocked by player at " + string(new_x) + "," + string(new_y));
                            break;
                        }
                    }
                    
                    // Check for other enemies at exact position
                    if (can_move_primary) {
                        with (obj_Enemy) {
                            if (id != other.id && x == new_x && y == new_y) {
                                can_move_primary = false;
                                show_debug_message(other.character_name + " blocked by enemy " + character_name + " at " + string(new_x) + "," + string(new_y));
                                break;
                            }
                        }
                    }
                }
                
                if (can_move_primary) {
                    move_direction = engagement_direction;
                } else {
                    // Try alternative directions to avoid stacking
                    var alt_directions = [];
                    
                    // If close to target (within 3 tiles), try flanking positions
                    if (closest_distance <= 3) {
                        // Try to flank around the player
                        var flanking_positions = [
                            { dir: Dir.UP, x: x, y: y - 16 },
                            { dir: Dir.DOWN, x: x, y: y + 16 },
                            { dir: Dir.LEFT, x: x - 16, y: y },
                            { dir: Dir.RIGHT, x: x + 16, y: y }
                        ];
                        
                        // Shuffle positions for variety
                        for (var i = 0; i < 3; i++) {
                            var j = irandom(3);
                            var temp = flanking_positions[i];
                            flanking_positions[i] = flanking_positions[j];
                            flanking_positions[j] = temp;
                        }
                        
                        // Try each flanking position
                        for (var i = 0; i < array_length(flanking_positions); i++) {
                            var pos = flanking_positions[i];
                            var pos_free = place_free(pos.x, pos.y);
                            
                            if (pos_free) {
                                // Check for players at position
                                with (obj_Player) {
                                    if (x == pos.x && y == pos.y) {
                                        pos_free = false;
                                        break;
                                    }
                                }
                                
                                // Check for other enemies at position
                                if (pos_free) {
                                    with (obj_Enemy) {
                                        if (id != other.id && x == pos.x && y == pos.y) {
                                            pos_free = false;
                                            break;
                                        }
                                    }
                                }
                            }
                            
                            if (pos_free) {
                                move_direction = pos.dir;
                                break;
                            }
                        }
                    } else {
                        // For distant targets, try perpendicular directions
                        if (engagement_direction == Dir.RIGHT || engagement_direction == Dir.LEFT) {
                            alt_directions = [Dir.UP, Dir.DOWN];
                        } else {
                            alt_directions = [Dir.LEFT, Dir.RIGHT];
                        }
                        
                        for (var i = 0; i < array_length(alt_directions); i++) {
                            var alt_dir = alt_directions[i];
                            new_x = x;
                            new_y = y;
                            
                            switch (alt_dir) {
                                case Dir.RIGHT: new_x += 16; break;
                                case Dir.LEFT:  new_x -= 16; break;
                                case Dir.UP:    new_y -= 16; break;
                                case Dir.DOWN:  new_y += 16; break;
                            }
                            
                            var alt_free = place_free(new_x, new_y);
                            if (alt_free) {
                                // Check for players at position
                                with (obj_Player) {
                                    if (x == new_x && y == new_y) {
                                        alt_free = false;
                                        break;
                                    }
                                }
                                
                                // Check for other enemies at position
                                if (alt_free) {
                                    with (obj_Enemy) {
                                        if (id != other.id && x == new_x && y == new_y) {
                                            alt_free = false;
                                            break;
                                        }
                                    }
                                }
                            }
                            
                            if (alt_free) {
                                move_direction = alt_dir;
                                break;
                            }
                        }
                    }
                }
                
                if (move_direction != noone) {
                    ai_decision = { action: "move", target: closest_player, direction: move_direction };
                } else {
                    // All positions blocked, wait
                    ai_decision = { action: "wait", target: closest_player, direction: engagement_direction };
                }
            }
        } else {
            ai_decision = { action: "wait", target: noone, direction: Dir.DOWN };
        }
        
        // Execute the AI decision
        switch (ai_decision.action) {
            case "attack":
                var target = ai_decision.target;
                if (target != noone) {
                    var distance = point_distance(x, y, target.x, target.y);
                    if (distance <= 24) {
                        dir = ai_decision.direction;
                        anim_state = State.ATTACK;
                        sprite_index = spr_matrix[dir][anim_state];
                        image_index = 0;
                        image_speed = 1.0;
                        is_anim = true;
                        target_player = target;
                    } else {
                        moves = 0;
                        alarm[0] = 1;
                    }
                }
                break;
                
            case "move":
                var move_dir = ai_decision.direction;
                var new_x = x;
                var new_y = y;
                
                switch (move_dir) {
                    case Dir.RIGHT: new_x += 16; break;
                    case Dir.LEFT:  new_x -= 16; break;
                    case Dir.UP:    new_y -= 16; break;
                    case Dir.DOWN:  new_y += 16; break;
                }
                
                // Double-check movement is valid before executing
                var can_execute_move = place_free(new_x, new_y);
                
                // Check for players at the destination
                if (can_execute_move) {
                    with (obj_Player) {
                        if (x == new_x && y == new_y) {
                            can_execute_move = false;
                            show_debug_message(other.character_name + " BLOCKED from moving to " + string(new_x) + "," + string(new_y) + " - player there");
                            break;
                        }
                    }
                }
                
                // Check for other enemies at the destination
                if (can_execute_move) {
                    with (obj_Enemy) {
                        if (id != other.id && x == new_x && y == new_y) {
                            can_execute_move = false;
                            show_debug_message(other.character_name + " BLOCKED from moving to " + string(new_x) + "," + string(new_y) + " - enemy " + character_name + " there");
                            break;
                        }
                    }
                }
                
                if (can_execute_move) {
                    dir = move_dir;
                    anim_state = State.RUN;
                    sprite_index = spr_matrix[dir][anim_state];
                    image_index = 0;
                    image_speed = 1.0;
                    is_anim = true;
                    
                    if (variable_global_exists("combat_log")) {
                        var target_name = (ai_decision.target != noone) ? ai_decision.target.character_name : "target";
                        global.combat_log(character_name + " moves toward " + target_name + "!");
                    }
                } else {
                    // Movement blocked at execution time - end turn
                    show_debug_message(character_name + " could not execute move - ending turn");
                    moves = 0;
                    alarm[0] = 1;
                }
                break;
                
            case "wait":
            default:
                if (variable_global_exists("combat_log")) {
                    global.combat_log(character_name + " waits...");
                }
                // Don't change direction when waiting - keep current facing
                moves = 0;
                alarm[0] = 1;
                break;
        }
    }
}

// === ANIMATION HANDLING ===
// Handle movement animation completion
if (anim_state == State.RUN && is_anim && image_index >= 4) {
    // Complete the movement
    switch (dir) {
        case Dir.RIGHT: x += 16; break;
        case Dir.LEFT:  x -= 16; break;
        case Dir.UP:    y -= 16; break;
        case Dir.DOWN:  y += 16; break;
    }
    
    // Return to idle
    anim_state = State.IDLE;
    sprite_index = spr_matrix[dir][anim_state];
    image_index = 0;
    image_speed = 1.0;
    is_anim = false;
    moves -= 1;
    
    // End turn if no moves left
    if (moves <= 0) {
        alarm[0] = 1;
    }
}

// Handle attack animation completion
if (anim_state == State.ATTACK && is_anim && image_index >= sprite_get_number(sprite_index) - 1) {
    // Perform the actual attack
    if (target_player != noone && instance_exists(target_player)) {
        var hit = roll_attack(self, target_player);
        
        if (hit) {
            var base_damage = roll_weapon_damage_with_display(weapon_damage_dice, damage_modifier, weapon_name);
            
            // Apply weapon special abilities 
            var special_damage = handle_special_attack(self, target_player, hit, base_damage);
            if (special_damage > base_damage) {
                base_damage = special_damage;
            }
            
            var final_damage = handle_defensive_abilities(target_player, self, base_damage, false);
            target_player.hp -= final_damage;
            
            // Combat log reporting
            if (variable_global_exists("combat_log")) {
                var player_name = target_player.character_name;
                global.combat_log(player_name + " takes " + string(final_damage) + " damage from " + weapon_name + "! (HP: " + string(target_player.hp) + "/" + string(target_player.max_hp) + ")");
                
                if (target_player.hp <= 0) {
                    global.combat_log("*** " + player_name + " has been defeated by " + character_name + "! ***");
                } else if (target_player.hp <= 3) {
                    global.combat_log("WARNING: " + player_name + " is critically injured!");
                }
            }
            
            // Handle weapon special effects
            // Note: This function may not exist for all weapons, so we skip it for enemies for now
        } else {
            handle_defensive_abilities(target_player, self, 0, true);
        }
    }
    
    // Return to idle
    anim_state = State.IDLE;
    sprite_index = spr_matrix[dir][anim_state];
    image_index = 0;
    image_speed = 1.0;
    is_anim = false;
    moves -= 1;
    target_player = noone;
    
    // End turn
    if (moves <= 0) {
        alarm[0] = 1;
    }
}

// === HOVER COLOR SYSTEM ===
// Check if mouse is hovering over this enemy
var mouse_hovering = position_meeting(mouse_x, mouse_y, self);

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

// Set sprite color based on hover and pistol state
if (pistol_active && active_player != noone && mouse_hovering) {
    // Only show color when actually hovering over enemy
    // Use the exact same calculation as is_enemy_in_pistol_range()
    if (script_exists(is_enemy_in_pistol_range) && is_enemy_in_pistol_range(active_player, self)) {
        sprite_color = c_lime; // Green for in range (including line of sight)
    } else {
        sprite_color = c_dkgray;  // Dark gray for out of range or blocked  
    }
} else {
    sprite_color = c_white; // Default white color (no hover feedback)
}
