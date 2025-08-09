// === STATUS EFFECTS ===
if (frozen_turns > 0) {
    if (state == TURNSTATE.active) {
        if (variable_global_exists("combat_log")) global.combat_log(object_get_name(object_index) + " is FROZEN! Skipping turn...");
        frozen_turns--;
        alarm[0] = 1;
        exit;
    }
}

if (burn_turns > 0 && state == TURNSTATE.active) {
    hp -= 1;
    burn_turns--;
    if (variable_global_exists("combat_log")) global.combat_log(object_get_name(object_index) + " takes 1 BURN damage! (" + string(burn_turns) + " turns remaining)");
    if (hp <= 0) {
        if (variable_global_exists("combat_log")) global.combat_log(object_get_name(object_index) + " burned to death!");
    }
}

// Enemy AI - attack adjacent player
if (state == TURNSTATE.active && moves == 0) {
    var target_player = instance_place(x + 16, y, obj_Player);
    if (!target_player) target_player = instance_place(x - 16, y, obj_Player);
    if (!target_player) target_player = instance_place(x, y + 16, obj_Player);
    if (!target_player) target_player = instance_place(x, y - 16, obj_Player);
    
    if (target_player) {
        show_debug_message("=== " + object_get_name(object_index) + " Turn ===");
        var hit = roll_attack(self, target_player);
        
        if (hit) {
            var damage = roll_damage(self);
            damage = handle_defensive_abilities(target_player, self, damage, false);
            target_player.hp -= damage;
            
            // Use combat log for damage reporting
            if (variable_global_exists("combat_log")) {
                var player_name = target_player.character_name;
                global.combat_log(player_name + " takes " + string(damage) + " damage! (HP: " + string(target_player.hp) + "/" + string(target_player.max_hp) + ")");
                
                if (target_player.hp <= 0) {
                    global.combat_log("*** " + player_name + " has been defeated by " + object_get_name(object_index) + "! ***");
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

// === DEATH HANDLING ===
if (hp <= 0) {
    // Log enemy death
    if (variable_global_exists("combat_log")) {
        global.combat_log("*** " + object_get_name(object_index) + " HAS DIED! ***");
    }
    
    // Remove from turn list BEFORE destroying instance
    var turn_index = ds_list_find_index(obj_TurnManager.turn_list, id);
    if (turn_index >= 0) {
        ds_list_delete(obj_TurnManager.turn_list, turn_index);
    }
    
    // Destroy the instance
    instance_destroy();
}



