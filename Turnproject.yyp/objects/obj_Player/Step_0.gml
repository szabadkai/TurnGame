// === STATUS EFFECTS ===
if (frozen_turns > 0) {
    if (state == TURNSTATE.active) {
        if (variable_global_exists("combat_log")) global.combat_log("Player is FROZEN! Skipping turn...");
        frozen_turns--;
        alarm[0] = 1;
        exit;
    }
}

if (burn_turns > 0 && state == TURNSTATE.active) {
    hp -= 1;
    burn_turns--;
    if (variable_global_exists("combat_log")) global.combat_log("Player takes 1 BURN damage! (" + string(burn_turns) + " turns remaining)");
    if (hp <= 0) {
        if (variable_global_exists("combat_log")) global.combat_log("Player burned to death!");
    }
}

// === WEAPON SWITCHING ===
if (state == TURNSTATE.active) {
    for (var i = 0; i <= 9; i++) {
        if (keyboard_check_pressed(ord(string(i)))) {
            if (i < array_length(global.weapons)) {
                equipped_weapon_id = i;
                update_combat_stats();
                if (variable_global_exists("combat_log")) global.combat_log("Equipped: " + weapon_name);
                if (variable_global_exists("combat_log")) global.combat_log("Attack: +" + string(weapon_attack_bonus) + " | Damage: " + weapon_damage_dice + "+" + string(weapon_damage_modifier));
                if (variable_global_exists("combat_log")) global.combat_log("Special: " + global.weapons[i].description);
            }
        }
    }
    
    if (keyboard_check_pressed(ord("I"))) {
        if (variable_global_exists("combat_log")) global.combat_log("=== CURRENT WEAPON ===");
        if (variable_global_exists("combat_log")) global.combat_log("Name: " + weapon_name);
        if (variable_global_exists("combat_log")) global.combat_log("Damage: " + weapon_damage_dice + "+" + string(weapon_damage_modifier) + " | Attack: +" + string(weapon_attack_bonus));
        if (variable_global_exists("combat_log")) global.combat_log("Final Stats: +" + string(attack_bonus) + " attack, +" + string(damage_modifier) + " dmg mod, " + string(defense_score) + " defense");
        if (variable_global_exists("combat_log")) global.combat_log("Special: " + global.weapons[equipped_weapon_id].description);
    }
}

//Move
// === INPUT AND STATE TRANSITION ===
if (state == TURNSTATE.active && moves > 0 && !is_anim) {

    // Right
    if (keyboard_check_pressed(ord("D")) && place_free(x + 16, y)) {
        dir = Dir.RIGHT;
        anim_state = State.RUN;
        sprite_index = spr_matrix[dir][anim_state];
        image_index = 0;
        image_speed = 1.0;
        is_anim = true;
    }

    // Left
    else if (keyboard_check_pressed(ord("A")) && place_free(x - 16, y)) {
        dir = Dir.LEFT;
        anim_state = State.RUN;
        sprite_index = spr_matrix[dir][anim_state];
        image_index = 0;
        image_speed = 1.0;
        is_anim = true;
    }

    // Up
    else if (keyboard_check_pressed(ord("W")) && place_free(x, y - 16)) {
        dir = Dir.UP;
        anim_state = State.RUN;
        sprite_index = spr_matrix[dir][anim_state];
        image_index = 0;
        image_speed = 1.0;
        is_anim = true;
    }

    // Down
    else if (keyboard_check_pressed(ord("S")) && place_free(x, y + 16)) {
        dir = Dir.DOWN;
        anim_state = State.RUN;
        sprite_index = spr_matrix[dir][anim_state];
        image_index = 0;
        image_speed = 1.0;
        is_anim = true;
    }
}

// === ANIMATION CHECK & FINAL MOVE ===
if (anim_state == State.RUN && is_anim) {
    if (image_index == 4) {
        // Move based on direction
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
    }
}

//Attack
// === INPUT AND STATE TRANSITION ===
if (state == TURNSTATE.active && moves > 0 && !is_anim) {

    // Right
    if (keyboard_check_pressed(ord("D")) && instance_place(x + 16, y, obj_Enemy)) {
        target_enemy = instance_place(x + 16, y, obj_Enemy);
		dir = Dir.RIGHT;
        anim_state = State.ATTACK;
        sprite_index = spr_matrix[dir][anim_state];
        image_index = 0;
        image_speed = 1.0;
        is_anim = true;
        depth = -100;
    }

    // Left
    else if (keyboard_check_pressed(ord("A")) && instance_place(x - 16, y, obj_Enemy)) {
        target_enemy = instance_place(x - 16, y, obj_Enemy);
		dir = Dir.LEFT;
        anim_state = State.ATTACK;
        sprite_index = spr_matrix[dir][anim_state];
        image_index = 0;
        image_speed = 1.0;
        is_anim = true;
        depth = -100;
    }

    // Up
    else if (keyboard_check_pressed(ord("W")) && instance_place(x, y - 16, obj_Enemy)) {
        target_enemy = instance_place(x, y - 16, obj_Enemy);
		dir = Dir.UP;
        anim_state = State.ATTACK;
        sprite_index = spr_matrix[dir][anim_state];
        image_index = 0;
        image_speed = 1.0;
        is_anim = true;
        depth = -100;
    }

    // Down
    else if (keyboard_check_pressed(ord("S")) && instance_place(x, y + 16, obj_Enemy)) {
        target_enemy = instance_place(x, y + 16, obj_Enemy);
		dir = Dir.DOWN;
        anim_state = State.ATTACK;
        sprite_index = spr_matrix[dir][anim_state];
        image_index = 0;
        image_speed = 1.0;
        is_anim = true;
        depth = -100;
    }
}

// === ANIMATION CHECK & FINAL MOVE ===
if (anim_state == State.ATTACK && is_anim) {
    if (image_index == 3) {
        // Weapon-Based D20 Combat System
        if (variable_global_exists("combat_log")) {
            if (variable_global_exists("combat_log")) global.combat_log("=== " + object_get_name(object_index) + " Turn ===");
        }
        
        var attack_roll = roll_d20();
        var attack_total = attack_roll + attack_bonus;
        var hit = (attack_total >= target_enemy.defense_score);
        
        if (variable_global_exists("combat_log")) global.combat_log(object_get_name(object_index) + " attacks with " + weapon_name + ": d20+" + string(attack_bonus) + " = [" + string(attack_roll) + "] + " + string(attack_bonus) + " = " + string(attack_total) + " vs Defense " + string(target_enemy.defense_score) + (hit ? " - HIT!" : " - MISS!"));
        
        if (hit) {
            var base_damage = roll_weapon_damage_with_display(weapon_damage_dice, damage_modifier, weapon_name);
            var final_damage = handle_special_attack(self, target_enemy, attack_roll, base_damage);
            
            target_enemy.hp -= final_damage;
            if (variable_global_exists("combat_log")) global.combat_log(object_get_name(target_enemy.object_index) + " takes " + string(final_damage) + " damage (" + string(target_enemy.hp + final_damage) + " HP → " + string(target_enemy.hp) + " HP)");
            
            if (target_enemy.hp <= 0) {
                if (variable_global_exists("combat_log")) global.combat_log(object_get_name(target_enemy.object_index) + " is defeated!");
            }
        }
		
        // Return to idle
        anim_state = State.IDLE;
        sprite_index = spr_matrix[dir][anim_state];
        image_index = 0;
        image_speed = 1.0;
        is_anim = false;
        moves -= 1;
        depth = 0;
    }
}

// ensure whatever
sprite_index = spr_matrix[dir][anim_state];

//pass to space
if (state == TURNSTATE.active && moves == 0) {
	alarm[0] = 1;
}

//death at 0 hp
if (hp <= 0) {
	instance_destroy();
	ds_list_delete(obj_TurnManager.turn_list, ds_list_find_index(obj_TurnManager.turn_list, id))
}