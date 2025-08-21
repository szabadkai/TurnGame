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
    
    // Special key for weapon 10 (Pistol) - use minus key
    if (keyboard_check_pressed(ord("-"))) {
        var weapon_id = 10;
        if (weapon_id < array_length(global.weapons)) {
            equipped_weapon_id = weapon_id;
            update_combat_stats();
            if (variable_global_exists("combat_log")) global.combat_log("Equipped: " + weapon_name);
            if (variable_global_exists("combat_log")) global.combat_log("Attack: +" + string(weapon_attack_bonus) + " | Damage: " + weapon_damage_dice + "+" + string(weapon_damage_modifier));
            if (variable_global_exists("combat_log")) global.combat_log("Special: " + global.weapons[weapon_id].description);
        }
    }
}

//Mouse Click Attack (for Ranged Weapons)
// === MOUSE ATTACK INPUT ===
if (state == TURNSTATE.active && moves > 0 && !is_anim && mouse_check_button_pressed(mb_left)) {
    // Only use mouse attacks for ranged weapons
    if (weapon_special_type == "ranged") {
        
        // Check if clicked on an enemy
        var clicked_enemy = instance_position(mouse_x, mouse_y, obj_Enemy);
        if (clicked_enemy != noone) {
            // Check if enemy is in range
            if (is_enemy_in_pistol_range(self, clicked_enemy)) {
                target_enemy = clicked_enemy;
                
                // Calculate direction to face the target
                var dx = clicked_enemy.x - x;
                var dy = clicked_enemy.y - y;
                
                if (abs(dx) > abs(dy)) {
                    dir = (dx > 0) ? Dir.RIGHT : Dir.LEFT;
                } else {
                    dir = (dy > 0) ? Dir.DOWN : Dir.UP;
                }
                
                anim_state = State.ATTACK;
                sprite_index = spr_matrix[dir][anim_state];
                image_index = 0;
                image_speed = 1.0;
                is_anim = true;
                depth = -100;
            } else {
                if (variable_global_exists("combat_log")) global.combat_log("Target out of range! (Max 4 tiles)");
            }
        }
    }
}

//Move
// === INPUT AND STATE TRANSITION ===
if (state == TURNSTATE.active && moves > 0 && !is_anim) {

    // Right
    if (keyboard_check_pressed(ord("D")) && can_move_to(x + 16, y)) {
        dir = Dir.RIGHT;
        anim_state = State.RUN;
        sprite_index = spr_matrix[dir][anim_state];
        image_index = 0;
        image_speed = 1.0;
        is_anim = true;
    }

    // Left
    else if (keyboard_check_pressed(ord("A")) && can_move_to(x - 16, y)) {
        dir = Dir.LEFT;
        anim_state = State.RUN;
        sprite_index = spr_matrix[dir][anim_state];
        image_index = 0;
        image_speed = 1.0;
        is_anim = true;
    }

    // Up
    else if (keyboard_check_pressed(ord("W")) && can_move_to(x, y - 16)) {
        dir = Dir.UP;
        anim_state = State.RUN;
        sprite_index = spr_matrix[dir][anim_state];
        image_index = 0;
        image_speed = 1.0;
        is_anim = true;
    }

    // Down
    else if (keyboard_check_pressed(ord("S")) && can_move_to(x, y + 16)) {
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
            if (variable_global_exists("combat_log")) global.combat_log("=== " + character_name + " Turn ===");
        }
        
        var attack_roll = roll_d20();
        var attack_total = attack_roll + attack_bonus;

        // Validate target before using it (may have been destroyed/moved)
        if (!variable_instance_exists(id, "target_enemy") || is_undefined(target_enemy) || target_enemy == noone || !instance_exists(target_enemy)) {
            if (variable_global_exists("combat_log")) global.combat_log("Attack cancelled: target unavailable.");
            // Cleanly end the attack animation/state
            anim_state = State.IDLE;
            sprite_index = spr_matrix[dir][anim_state];
            image_index = 0;
            image_speed = 1.0;
            is_anim = false;
            moves = max(0, moves - 1);
            depth = 0;
            exit;
        }

        var hit = (attack_total >= target_enemy.defense_score);
        
        if (variable_global_exists("combat_log")) global.combat_log(character_name + " attacks with " + weapon_name + ": d20+" + string(attack_bonus) + " = [" + string(attack_roll) + "] + " + string(attack_bonus) + " = " + string(attack_total) + " vs Defense " + string(target_enemy.defense_score) + (hit ? " - HIT!" : " - MISS!"));
        
        if (hit) {
            var base_damage = roll_weapon_damage_with_display(weapon_damage_dice, damage_modifier, weapon_name);
            var final_damage = handle_special_attack(self, target_enemy, attack_roll, base_damage);
            
            target_enemy.hp -= final_damage;
            if (variable_global_exists("combat_log")) global.combat_log(target_enemy.character_name + " takes " + string(final_damage) + " damage (" + string(target_enemy.hp + final_damage) + " HP → " + string(target_enemy.hp) + " HP)");
            
            if (target_enemy.hp <= 0) {
                if (variable_global_exists("combat_log")) global.combat_log(target_enemy.character_name + " is defeated!");
                
                // Award XP to entire party using new distribution system
                var xp_reward = target_enemy.xp_value;
                distribute_party_xp(xp_reward);
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

// === DEATH HANDLING (CHECK FIRST) ===
if (hp <= 0) {
    // Log player death
    if (variable_global_exists("combat_log")) {
        global.combat_log("*** " + character_name + " HAS DIED! ***");
    }
    
    // If this player was taking its turn, we need to pass the turn
    var was_active = (state == TURNSTATE.active);
    
    // Remove from turn list BEFORE destroying instance
    var turn_index = ds_list_find_index(obj_TurnManager.turn_list, id);
    if (turn_index >= 0) {
        ds_list_delete(obj_TurnManager.turn_list, turn_index);
    }
    
    // If player was active, trigger turn rotation to next character
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

//pass to space
if (state == TURNSTATE.active && moves == 0) {
	alarm[0] = 1;
}

// === DEBUG: Test collision at current position ===
if (keyboard_check_pressed(ord("T"))) {
    show_debug_message("=== COLLISION DEBUG TEST ===");
    show_debug_message("Player at: (" + string(x) + "," + string(y) + ")");
    
    // Test current position and adjacent positions
    var test_positions = [
        {name: "Current", test_x: x, test_y: y},
        {name: "Right", test_x: x + 16, test_y: y},
        {name: "Left", test_x: x - 16, test_y: y},
        {name: "Up", test_x: x, test_y: y - 16},
        {name: "Down", test_x: x, test_y: y + 16}
    ];
    
    for (var i = 0; i < array_length(test_positions); i++) {
        var pos = test_positions[i];
        show_debug_message("--- Testing " + pos.name + " position ---");
        var result = can_move_to(pos.test_x, pos.test_y);
        show_debug_message("Result for " + pos.name + ": " + (result ? "CLEAR" : "BLOCKED"));
    }
}


