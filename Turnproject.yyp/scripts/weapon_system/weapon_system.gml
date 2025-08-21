// Weapon System with Unique Mechanics

function create_weapon(name, attack_bonus, damage_dice, damage_modifier, special_type, description) {
    return {
        name: name,
        attack_bonus: attack_bonus,
        damage_dice: damage_dice,
        damage_modifier: damage_modifier,
        special_type: special_type,
        description: description
    };
}

function init_weapons() {
    global.weapons = [];
    
    // 1. Basic & Precision Weapons
    global.weapons[0] = create_weapon("Fists", 1, "1d1", 0, "none", "Your bare hands - always deal 1 damage");
    global.weapons[1] = create_weapon("Rapier", 2, "1d8", 1, "finesse", "Finesse weapon - Uses DEX for attacks");
    global.weapons[2] = create_weapon("Assassin's Blade", 1, "1d4", 2, "finesse", "Deadly precision - Uses DEX for attacks");
    
    // 2. Magical Weapons  
    global.weapons[3] = create_weapon("Lightning Staff", 0, "1d6", 2, "chain_lightning", "Magical focus - Chain lightning to adjacent foes");
    global.weapons[4] = create_weapon("Frost Wand", 1, "1d4", 1, "freeze", "Ice magic - 50% chance to freeze enemy");
    
    // 3. Defensive Weapons
    global.weapons[5] = create_weapon("Shield & Sword", 1, "1d6", 2, "defense_boost", "Balanced weapon - +3 Defense, counter-attacks");
    global.weapons[6] = create_weapon("Parrying Dagger", 2, "1d4", 0, "reflect", "Defensive blade - Reflects 50% damage");
    
    // 4. Heavy Weapons
    global.weapons[7] = create_weapon("War Hammer", -1, "2d6", 3, "area_attack", "Massive weapon - Hits all adjacent enemies");
    global.weapons[8] = create_weapon("Flame Sword", 1, "1d8", 2, "burn", "Enchanted blade - 25% chance to burn");
    
    // 5. Risk/Reward Weapons
    global.weapons[9] = create_weapon("Berserker Axe", 2, "1d12", 4, "self_harm", "Brutal weapon - High damage but self-harm");
    
    // 6. Ranged Weapons
    global.weapons[10] = create_weapon("Pistol", 1, "1d8", 2, "ranged", "Ranged firearm - Uses DEX for attacks, Range: 4 tiles");
    
    // 7. Enemy Weapons (Always 1 damage)
    global.weapons[11] = create_weapon("Rusty Dagger", 0, "1d1", 0, "none", "Crude blade - Minimal damage");
    global.weapons[12] = create_weapon("Crude Club", 0, "1d1", 0, "none", "Simple bludgeon - Basic attack");
    global.weapons[13] = create_weapon("Bone Claws", 0, "1d1", 0, "none", "Skeletal talons - Scraping damage");
    global.weapons[14] = create_weapon("Fangs", 0, "1d1", 0, "none", "Natural bite - Quick strikes");
    global.weapons[15] = create_weapon("Bandit Blade", 0, "1d1", 0, "none", "Worn shortsword - Dulled edge");
}

function update_combat_stats() {
    if (equipped_weapon_id == undefined) return;
    
    var weapon = global.weapons[equipped_weapon_id];
    
    // Update weapon properties on object
    weapon_name = weapon.name;
    weapon_attack_bonus = weapon.attack_bonus;
    weapon_damage_dice = weapon.damage_dice;
    weapon_damage_modifier = weapon.damage_modifier;
    weapon_special_type = weapon.special_type;
    
    // Update ability modifiers (in case they changed from leveling)
    update_ability_modifiers(self);
    
    // Update proficiency bonus based on current level
    proficiency_bonus = get_proficiency_bonus(level);
    
    // Calculate final combat stats using new ability score system
    // For now, use STR for melee weapons, DEX for finesse weapons
    var ability_mod = (weapon_special_type == "finesse" || weapon_special_type == "ranged" || weapon.name == "Rapier") ? dex_mod : str_mod;
    
    attack_bonus = proficiency_bonus + ability_mod + weapon_attack_bonus;
    damage_modifier = ability_mod + weapon_damage_modifier;
    
    // Calculate defense (AC = base armor class + DEX mod + special bonuses)
    defense_score = base_armor_class + dex_mod;
    
    // Special defense bonus for Shield & Sword
    if (weapon_special_type == "defense_boost") {
        defense_score += 3;
    }
    
    // Update sprite matrix for weapon-specific animations
    if (variable_instance_exists(id, "character_index") && variable_instance_exists(id, "spr_matrix")) {
        spr_matrix = update_sprite_matrix(character_index, weapon_special_type);
    }
}

function handle_special_attack(attacker, target, attack_roll, damage_roll) {
    var special = attacker.weapon_special_type;
    var weapon_name = attacker.weapon_name;
    
    switch(special) {
        case "crit_18":
            if (attack_roll >= 18) {
                if (variable_global_exists("combat_log")) global.combat_log("CRITICAL HIT with " + weapon_name + "!");
                return damage_roll * 3;
            }
            break;
            
        case "instant_kill":
            if (attack_roll == 20) {
                if (variable_global_exists("combat_log")) global.combat_log("ASSASSINATION! " + weapon_name + " delivers a killing blow!");
                return 999;
            }
            break;
            
        case "chain_lightning":
            if (variable_global_exists("combat_log")) global.combat_log("CHAIN LIGHTNING! Striking adjacent enemies!");
            var enemies = find_adjacent_enemies(attacker);
            for (var i = 0; i < array_length(enemies); i++) {
                if (enemies[i] != target) {
                    chain_attack(attacker, enemies[i]);
                }
            }
            break;
            
        case "freeze":
            if (irandom(1) == 0) {
                target.frozen_turns = 1;
                if (variable_global_exists("combat_log")) global.combat_log("Target FROZEN! Will skip next turn!");
            }
            break;
            
        case "area_attack":
            if (variable_global_exists("combat_log")) global.combat_log("AREA ATTACK! " + weapon_name + " strikes multiple foes!");
            var enemies = find_adjacent_enemies(attacker);
            for (var i = 0; i < array_length(enemies); i++) {
                if (enemies[i] != target) {
                    area_attack(attacker, enemies[i]);
                }
            }
            break;
            
        case "burn":
            if (irandom(3) == 0) {
                target.burn_turns = 3;
                if (variable_global_exists("combat_log")) global.combat_log("Target BURNING! Will take 1 damage per turn for 3 turns!");
            }
            break;
            
        case "self_harm":
            attacker.hp -= 1;
            if (variable_global_exists("combat_log")) {
                var attacker_name = global.entity_name(attacker);
                global.combat_log("BERSERKER RAGE! " + attacker_name + " takes 1 damage from fury! (HP: " + string(attacker.hp) + "/" + string(attacker.max_hp) + ")");
                
                // Warning if attacker is getting low on health
                if (attacker.hp <= 3 && object_get_name(attacker.object_index) == "obj_Player") {
                    global.combat_log("WARNING: " + attacker_name + " is critically injured from berserker rage!");
                }
            }
            break;
    }
    
    return damage_roll;
}

function find_adjacent_enemies(attacker) {
    var enemies = [];
    var count = 0;
    
    var positions = [
        [attacker.x + 16, attacker.y],
        [attacker.x - 16, attacker.y], 
        [attacker.x, attacker.y + 16],
        [attacker.x, attacker.y - 16]
    ];
    
    for (var i = 0; i < 4; i++) {
        var enemy = instance_position(positions[i][0], positions[i][1], obj_Enemy);
        if (enemy != noone) {
            enemies[count] = enemy;
            count++;
        }
    }
    
    return enemies;
}

function chain_attack(attacker, target) {
    if (roll_attack_simple(attacker.attack_bonus, target.defense_score, "Chain")) {
        var damage = roll_weapon_damage(attacker.weapon_damage_dice) + attacker.damage_modifier;
        if (variable_global_exists("combat_log")) global.combat_log("Chain " + attacker.weapon_damage_dice + "+" + string(attacker.damage_modifier) + " = " + string(damage) + " damage");
        target.hp -= damage;
        if (variable_global_exists("combat_log")) global.combat_log(global.entity_name(target) + " takes " + string(damage) + " chain damage!");
    }
}

function area_attack(attacker, target) {
    if (roll_attack_simple(attacker.attack_bonus, target.defense_score, "Area")) {
        var damage = roll_weapon_damage(attacker.weapon_damage_dice) + attacker.damage_modifier;
        if (variable_global_exists("combat_log")) global.combat_log("Area " + attacker.weapon_damage_dice + "+" + string(attacker.damage_modifier) + " = " + string(damage) + " damage");
        target.hp -= damage;
        if (variable_global_exists("combat_log")) global.combat_log(global.entity_name(target) + " takes " + string(damage) + " area damage!");
    }
}

function roll_attack_simple(attack_bonus, target_defense, prefix) {
    var roll = roll_d20();
    var total = roll + attack_bonus;
    var hit = (total >= target_defense);
    
    if (variable_global_exists("combat_log")) global.combat_log(prefix + " attack: d20+" + string(attack_bonus) + " = [" + string(roll) + "] + " + string(attack_bonus) + " = " + string(total) + " vs Defense " + string(target_defense) + (hit ? " - HIT!" : " - MISS!"));
    
    return hit;
}

function roll_damage_simple(damage_modifier, prefix) {
    var roll = roll_d20();
    var damage = max(1, roll + damage_modifier);
    
    if (variable_global_exists("combat_log")) global.combat_log(prefix + " damage: d20+" + string(damage_modifier) + " = [" + string(roll) + "] + " + string(damage_modifier) + " = " + string(damage) + " damage");
    
    return damage;
}

function handle_defensive_abilities(defender, attacker, incoming_damage, attack_missed) {
    if (!instance_exists(defender) || defender.weapon_special_type == undefined) return incoming_damage;
    
    switch(defender.weapon_special_type) {
        case "defense_boost":
            if (attack_missed) {
                if (variable_global_exists("combat_log")) global.combat_log("COUNTER-ATTACK! " + defender.weapon_name + " strikes back!");
                var counter_damage = roll_damage_simple(1, "Counter");
                attacker.hp -= counter_damage;
                if (variable_global_exists("combat_log")) global.combat_log(global.entity_name(attacker) + " takes " + string(counter_damage) + " counter damage!");
            }
            break;
            
        case "reflect":
            if (incoming_damage > 0) {
                var reflected = floor(incoming_damage * 0.5);
                if (reflected > 0) {
                    if (variable_global_exists("combat_log")) global.combat_log("PARRY! " + defender.weapon_name + " reflects " + string(reflected) + " damage back!");
                    attacker.hp -= reflected;
                    if (variable_global_exists("combat_log")) global.combat_log(global.entity_name(attacker) + " takes " + string(reflected) + " reflected damage!");
                }
            }
            break;
    }
    
    return incoming_damage;
}

function get_weapon_range(weapon_special_type) {
    switch(weapon_special_type) {
        case "ranged":
            return 4; // 4 tiles for pistol
        default:
            return 1; // Adjacent only for melee weapons
    }
}

function find_enemies_in_line(attacker, direction, max_range) {
    var dx = 0, dy = 0;
    
    // Set direction offsets
    switch(direction) {
        case Dir.RIGHT: dx = 16; dy = 0; break;
        case Dir.LEFT:  dx = -16; dy = 0; break;
        case Dir.UP:    dx = 0; dy = -16; break;
        case Dir.DOWN:  dx = 0; dy = 16; break;
    }
    
    // Scan along the direction
    var current_x = attacker.x;
    var current_y = attacker.y;
    
    for (var i = 1; i <= max_range; i++) {
        current_x += dx;
        current_y += dy;
        
        // Check for walls/obstacles (assuming solid objects block shots)
        // Use character base collision system to check for walls and tiles
        with (attacker) {
            if (!can_move_to(current_x, current_y)) {
                other.i = max_range + 1; // Break the loop
            }
        }
        if (i > max_range) break; // Hit wall or tile collision, stop scanning
        
        // Check for enemy at this position
        var enemy = instance_position(current_x, current_y, obj_Enemy);
        if (enemy != noone) {
            return enemy; // Return first enemy found
        }
    }
    
    return noone; // No enemy found in range
}

function is_enemy_in_pistol_range(player, enemy) {
    // Calculate distance in grid tiles
    var dx = abs(enemy.x - player.x) / 16; // Convert pixels to tiles
    var dy = abs(enemy.y - player.y) / 16;
    
    // Use Manhattan distance (grid-based movement)
    var distance = max(dx, dy); // Chebyshev distance for 8-directional range
    
    // Check if within pistol range (4 tiles)
    if (distance > 4) {
        return false;
    }
    
    // For now, skip line of sight check as it's causing issues
    // TODO: Implement proper wall-only line of sight later
    return true;
}


