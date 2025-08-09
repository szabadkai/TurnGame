// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information

function roll_d20() {
    return irandom_range(1, 20);
}

function roll_attack(attacker, target) {
    var roll = roll_d20();
    var total = roll + attacker.attack_bonus;
    var hit = (total >= target.defense_score);
    
    var attacker_name = object_get_name(attacker.object_index);
    var target_name = object_get_name(target.object_index);
    
    if (hit) {
        show_debug_message(attacker_name + " attacks " + target_name + ": d20+" + string(attacker.attack_bonus) + " = [" + string(roll) + "] + " + string(attacker.attack_bonus) + " = " + string(total) + " vs Defense " + string(target.defense_score) + " - HIT!");
    } else {
        show_debug_message(attacker_name + " attacks " + target_name + ": d20+" + string(attacker.attack_bonus) + " = [" + string(roll) + "] + " + string(attacker.attack_bonus) + " = " + string(total) + " vs Defense " + string(target.defense_score) + " - MISS!");
    }
    
    return hit;
}

function roll_damage(attacker) {
    var roll = roll_d20();
    var damage = max(1, roll + attacker.damage_modifier);
    
    var attacker_name = object_get_name(attacker.object_index);
    show_debug_message("Damage: d20+" + string(attacker.damage_modifier) + " = [" + string(roll) + "] + " + string(attacker.damage_modifier) + " = " + string(damage) + " damage");
    
    return damage;
}

function roll_weapon_damage(damage_dice) {
    // Parse dice notation like "1d6", "2d6", "1d4", etc.
    var dice_count = 1;
    var dice_sides = 6;
    var total_damage = 0;
    
    // Handle special case of "1d1" (always 1)
    if (damage_dice == "1d1") {
        return 1;
    }
    
    // Parse the dice string
    var d_pos = string_pos("d", damage_dice);
    if (d_pos > 0) {
        dice_count = real(string_copy(damage_dice, 1, d_pos - 1));
        dice_sides = real(string_copy(damage_dice, d_pos + 1, string_length(damage_dice) - d_pos));
    }
    
    // Roll multiple dice and sum them
    for (var i = 0; i < dice_count; i++) {
        total_damage += irandom_range(1, dice_sides);
    }
    
    return total_damage;
}

function roll_weapon_damage_with_display(damage_dice, damage_modifier, weapon_name) {
    var dice_roll = roll_weapon_damage(damage_dice);
    var total_damage = dice_roll + damage_modifier;
    
    // Display the roll with proper D&D notation
    if (variable_global_exists("combat_log")) global.combat_log(weapon_name + " damage: " + damage_dice + "+" + string(damage_modifier) + " = [" + string(dice_roll) + "] + " + string(damage_modifier) + " = " + string(total_damage) + " damage");
    
    return total_damage;
}

function damage_text_to_value(damage_text){
if (damage_text = "d6") {
return irandom_range(1, 6)
}
if (damage_text = "d4") {
return irandom_range(1, 4)
}
}