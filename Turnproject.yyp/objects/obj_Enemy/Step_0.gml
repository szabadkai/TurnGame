// === STATUS EFFECTS ===
if (frozen_turns > 0) {
    if (state == TURNSTATE.active) {
        global.combat_log(object_get_name(object_index) + " is FROZEN! Skipping turn...");
        frozen_turns--;
        alarm[0] = 1;
        exit;
    }
}

if (burn_turns > 0 && state == TURNSTATE.active) {
    hp -= 1;
    burn_turns--;
    global.combat_log(object_get_name(object_index) + " takes 1 BURN damage! (" + string(burn_turns) + " turns remaining)");
    if (hp <= 0) {
        global.combat_log(object_get_name(object_index) + " burned to death!");
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
            show_debug_message(object_get_name(target_player.object_index) + " takes " + string(damage) + " damage (" + string(target_player.hp + damage) + " HP → " + string(target_player.hp) + " HP)");
            
            if (target_player.hp <= 0) {
                show_debug_message(object_get_name(target_player.object_index) + " is defeated!");
            }
        } else {
            handle_defensive_abilities(target_player, self, 0, true);
        }
    }
    
    alarm[0] = 1;
}

//death at 0 hp
if (hp <= 0) {
	instance_destroy();
	ds_list_delete(obj_TurnManager.turn_list, ds_list_find_index(obj_TurnManager.turn_list, id))
}



