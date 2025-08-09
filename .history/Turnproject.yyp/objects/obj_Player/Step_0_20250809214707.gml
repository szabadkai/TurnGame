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
                
                // Award XP to entire party
                var xp_reward = target_enemy.xp_value;
                var player_count = instance_number(obj_Player);
                
                if (variable_global_exists("combat_log")) global.combat_log("Party gains " + string(xp_reward) + " XP (" + string(xp_reward) + " ÷ " + string(player_count) + " each)");
                
                // Distribute XP equally among all players
                for (var i = 0; i < player_count; i++) {
                    var player_instance = instance_find(obj_Player, i);
                    if (instance_exists(player_instance)) {
                        gain_xp(player_instance, xp_reward);
                        if (variable_global_exists("combat_log")) global.combat_log(player_instance.character_name + " gains " + string(xp_reward) + " XP!");
                    }
                }
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

// === DEATH HANDLING ===
if (hp <= 0) {
    instance_destroy();
    ds_list_delete(obj_TurnManager.turn_list, ds_list_find_index(obj_TurnManager.turn_list, id));
}

// === NUCLEAR DEBUG OPTION ===
// Press 'P' to force create and test PlayerDetails immediately
if (keyboard_check_pressed(ord("P"))) {
    global.combat_log("=== NUCLEAR DEBUG ===");
    
    // Test if objects exist as definitions
    global.combat_log("obj_PlayerDetails exists: " + string(object_exists(obj_PlayerDetails)));
    global.combat_log("obj_UIManager exists: " + string(object_exists(obj_UIManager)));
    
    // Destroy any existing broken instances
    with (obj_PlayerDetails) instance_destroy();
    with (obj_UIManager) instance_destroy();
    
    // Force create new ones  
    var pd = instance_create_depth(64, 0, -1000, obj_PlayerDetails);
    global.combat_log("PlayerDetails created: " + string(pd));
    
    if (pd != noone) {
        pd.visible = true;
        pd.player_instance = self;
        pd.refresh_player_list();
        global.combat_log("PlayerDetails forced visible!");
    } else {
        global.combat_log("FAILED to create PlayerDetails!");
    }
}



