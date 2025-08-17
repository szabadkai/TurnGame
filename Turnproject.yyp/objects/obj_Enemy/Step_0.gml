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
    // Log enemy death
    if (variable_global_exists("combat_log")) {
        global.combat_log("*** " + character_name + " HAS DIED! ***");
    }
    
    // If this enemy was taking its turn, we need to pass the turn
    var was_active = (state == TURNSTATE.active);
    
    // Remove from turn list BEFORE destroying instance
    var turn_index = ds_list_find_index(obj_TurnManager.turn_list, id);
    if (turn_index >= 0) {
        ds_list_delete(obj_TurnManager.turn_list, turn_index);
    }
    
    // If enemy was active, trigger turn rotation to next character
    if (was_active) {
        state = TURNSTATE.inactive;  // Clean up state
        with(obj_TurnManager) {
            event_user(0);  // Rotate to next turn
        }
    }
    
    // Destroy the instance
    instance_destroy();
    exit; // Stop processing this step event
}

// === SPRITE ANIMATION ===
// Update sprite based on current state (enemies mostly stay idle)
sprite_index = spr_matrix[dir][anim_state];

// Enemy AI - attack adjacent player
if (state == TURNSTATE.active && moves == 0) {
    var target_player = instance_place(x + 16, y, obj_Player);
    if (!target_player) target_player = instance_place(x - 16, y, obj_Player);
    if (!target_player) target_player = instance_place(x, y + 16, obj_Player);
    if (!target_player) target_player = instance_place(x, y - 16, obj_Player);
    
    if (target_player) {
        show_debug_message("=== " + character_name + " Turn ===");
        var hit = roll_attack(self, target_player);
        
        if (hit) {
            var base_damage = roll_weapon_damage_with_display(weapon_damage_dice, damage_modifier, weapon_name);
            var final_damage = handle_defensive_abilities(target_player, self, base_damage, false);
            target_player.hp -= final_damage;
            
            // Use combat log for damage reporting
            if (variable_global_exists("combat_log")) {
                var player_name = target_player.character_name;
                global.combat_log(player_name + " takes " + string(final_damage) + " damage from " + weapon_name + "! (HP: " + string(target_player.hp) + "/" + string(target_player.max_hp) + ")");
                
                if (target_player.hp <= 0) {
                    global.combat_log("*** " + player_name + " has been defeated by " + character_name + "! ***");
                } else if (target_player.hp <= 3) {
                    global.combat_log("WARNING: " + player_name + " is critically injured!");
                }
            }
        } else {
            handle_defensive_abilities(target_player, self, 0, true);
        }
    }
    
    alarm[0] = 1;
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
    if (is_enemy_in_pistol_range(active_player, self)) {
        sprite_color = c_lime; // Green for in range (including line of sight)
    } else {
        sprite_color = c_dkgray;  // Dark gray for out of range or blocked  
    }
} else {
    sprite_color = c_white; // Default white color (no hover feedback)
}



