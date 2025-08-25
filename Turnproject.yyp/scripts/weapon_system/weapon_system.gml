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
    
    // 1. Basic & Precision Weapons (Sci‑Fi core, classic unarmed)
    global.weapons[0] = create_weapon("Fists", 1, "1d1", 0, "none", "Your bare hands - always deal 1 damage");
    global.weapons[1] = create_weapon("Monoblade", 2, "1d8", 1, "finesse", "Ultra-fine edge; agile strikes use DEX for attacks");
    global.weapons[2] = create_weapon("Vibroknife", 1, "1d4", 2, "finesse", "High-frequency blade for precise close quarters; uses DEX");
    
    // 2. Energy/Tech Weapons  
    global.weapons[3] = create_weapon("Arc Projector", 0, "1d6", 2, "chain_lightning", "Electro arc emitter — jumps to adjacent targets");
    global.weapons[4] = create_weapon("Cryo Emitter", 1, "1d4", 1, "freeze", "Supercooled beam — 50% chance to freeze target");
    
    // 3. Defensive Gear
    global.weapons[5] = create_weapon("Riot Shield & Baton", 1, "1d6", 2, "defense_boost", "+3 Defense; counter-attack on enemy miss");
    global.weapons[6] = create_weapon("Deflection Gauntlet", 2, "1d4", 0, "reflect", "Reactive field reflects 50% incoming damage");
    
    // 4. Heavy Weapons
    global.weapons[7] = create_weapon("Powered Sledge", -1, "2d6", 3, "area_attack", "Powered strikes impact all adjacent enemies");
    global.weapons[8] = create_weapon("Plasma Blade", 1, "1d8", 2, "burn", "Superheated edge — 25% chance to ignite");
    
    // 5. Risk/Reward Weapons
    global.weapons[9] = create_weapon("Chain Axe (Overclocked)", 2, "1d12", 4, "self_harm", "Unstable drive — heavy damage, inflicts 1 self-damage");
    
    // 6. Ranged Weapons
    global.weapons[10] = create_weapon("Plasma Pistol", 1, "1d8", 2, "ranged", "Compact energy sidearm — DEX-based, Range: 4 tiles");
    
    // 7. Enemy/Grunt Weapons (Always 1 damage)
    global.weapons[11] = create_weapon("Scrap Shiv", 0, "1d1", 0, "none", "Improvised blade — minimal damage");
    global.weapons[12] = create_weapon("Pipe Wrench", 0, "1d1", 0, "none", "Heavy tool swung as a weapon");
    global.weapons[13] = create_weapon("Cyber Claws", 0, "1d1", 0, "none", "Retractable talons — scraping damage");
    global.weapons[14] = create_weapon("Predator Fangs", 0, "1d1", 0, "none", "Augmented bite — quick strikes");
    global.weapons[15] = create_weapon("Raider Knife", 0, "1d1", 0, "none", "Standard gang issue — dulled edge");
}

function update_combat_stats() {
    if (is_undefined(equipped_weapon_id)) return;
    
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
    // STR for melee, DEX for finesse and ranged (name-agnostic)
    var ability_mod = (weapon_special_type == "finesse" || weapon_special_type == "ranged") ? dex_mod : str_mod;
    
    attack_bonus = proficiency_bonus + ability_mod + weapon_attack_bonus;
    damage_modifier = ability_mod + weapon_damage_modifier;
    
    // Calculate defense (AC = base armor class + DEX mod + special bonuses)
    defense_score = base_armor_class + dex_mod;
    
    // Special defense bonus for Shield & Sword
    if (weapon_special_type == "defense_boost") {
        defense_score += 3;
    }
    
    // Defending action bonus (+2 AC until next turn)
    if (variable_instance_exists(id, "is_defending") && is_defending) {
        defense_score += 2;
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
                scr_log("CRITICAL HIT with " + weapon_name + "!");
                return damage_roll * 3;
            }
            break;
            
        case "instant_kill":
            if (attack_roll == 20) {
                scr_log("ASSASSINATION! " + weapon_name + " delivers a killing blow!");
                return 999;
            }
            break;
            
        case "chain_lightning":
            scr_log("CHAIN LIGHTNING! Striking adjacent enemies!");
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
                scr_log("Target FROZEN! Will skip next turn!");
            }
            break;
            
        case "area_attack":
            scr_log("AREA ATTACK! " + weapon_name + " strikes multiple foes!");
            var area_enemies = find_adjacent_enemies(attacker);
            for (var i = 0; i < array_length(area_enemies); i++) {
                if (area_enemies[i] != target) {
                    area_attack(attacker, area_enemies[i]);
                }
            }
            break;
            
        case "burn":
            if (irandom(3) == 0) {
                target.burn_turns = 3;
                scr_log("Target BURNING! Will take 1 damage per turn for 3 turns!");
            }
            break;
            
        case "self_harm":
            attacker.hp -= 1;
            var attacker_name = global.entity_name(attacker);
            scr_log("BERSERKER RAGE! " + attacker_name + " takes 1 damage from fury! (HP: " + string(attacker.hp) + "/" + string(attacker.max_hp) + ")");
            // Warning if attacker is getting low on health
            if (attacker.hp <= 3 && object_get_name(attacker.object_index) == "obj_Player") {
                scr_log("WARNING: " + attacker_name + " is critically injured from berserker rage!");
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
        scr_log("Chain " + attacker.weapon_damage_dice + "+" + string(attacker.damage_modifier) + " = " + string(damage) + " damage");
        target.hp -= damage;
        scr_log(global.entity_name(target) + " takes " + string(damage) + " chain damage!");
    }
}

function area_attack(attacker, target) {
    if (roll_attack_simple(attacker.attack_bonus, target.defense_score, "Area")) {
        var damage = roll_weapon_damage(attacker.weapon_damage_dice) + attacker.damage_modifier;
        scr_log("Area " + attacker.weapon_damage_dice + "+" + string(attacker.damage_modifier) + " = " + string(damage) + " damage");
        target.hp -= damage;
        scr_log(global.entity_name(target) + " takes " + string(damage) + " area damage!");
    }
}

function roll_attack_simple(attack_bonus, target_defense, prefix) {
    var roll = roll_d20();
    var total = roll + attack_bonus;
    var hit = (total >= target_defense);
    
    scr_log(prefix + " attack: d20+" + string(attack_bonus) + " = [" + string(roll) + "] + " + string(attack_bonus) + " = " + string(total) + " vs Defense " + string(target_defense) + (hit ? " - HIT!" : " - MISS!"));
    
    return hit;
}

function roll_damage_simple(damage_modifier, prefix) {
    var roll = roll_d20();
    var damage = max(1, roll + damage_modifier);
    
    scr_log(prefix + " damage: d20+" + string(damage_modifier) + " = [" + string(roll) + "] + " + string(damage_modifier) + " = " + string(damage) + " damage");
    
    return damage;
}

function handle_defensive_abilities(defender, attacker, incoming_damage, attack_missed) {
    if (!instance_exists(defender) || is_undefined(defender.weapon_special_type)) return incoming_damage;
    
    switch(defender.weapon_special_type) {
        case "defense_boost":
            if (attack_missed) {
                scr_log("COUNTER-ATTACK! " + defender.weapon_name + " strikes back!");
                var counter_damage = roll_damage_simple(1, "Counter");
                attacker.hp -= counter_damage;
                    scr_log(global.entity_name(attacker) + " takes " + string(counter_damage) + " counter damage!");
            }
            break;
            
        case "reflect":
            if (incoming_damage > 0) {
                var reflected = floor(incoming_damage * 0.5);
                if (reflected > 0) {
                    scr_log("PARRY! " + defender.weapon_name + " reflects " + string(reflected) + " damage back!");
                    attacker.hp -= reflected;
                    scr_log(global.entity_name(attacker) + " takes " + string(reflected) + " reflected damage!");
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
    
    // Scan along the direction in 16-pixel steps
    var current_x = attacker.x;
    var current_y = attacker.y;
    
    for (var i = 1; i <= max_range; i++) {
        current_x += dx;
        current_y += dy;
        
        // Check for tile collision
        var tile_layer = layer_tilemap_get_id(LAYER_COLLISION);
        if (tile_layer != -1) {
            var tile_data = tilemap_get_at_pixel(tile_layer, current_x, current_y);
            if (tile_data > 0 && tile_data != -2147483648) {
                break; // Hit wall, stop scanning
            }
        }
        
        // Check for enemy at this position
        var enemy = instance_position(current_x, current_y, obj_Enemy);
        if (enemy != noone) {
            return enemy; // Return first enemy found
        }
    }
    
    return noone; // No enemy found in range
}

function is_enemy_in_pistol_range(player, enemy) {
    // Simple distance check - 4 tiles = 64 pixels
    var distance = point_distance(player.x, player.y, enemy.x, enemy.y);
    if (distance > 64) {
        return false;
    }
    
    // Check for tile collision along the line
    var tile_layer = layer_tilemap_get_id(LAYER_COLLISION);
    if (tile_layer != -1) {
        // Sample the line at regular intervals to check for tile collision
        var steps = ceil(distance / 8); // Check every 8 pixels for good coverage
        var dx = (enemy.x - player.x) / steps;
        var dy = (enemy.y - player.y) / steps;
        
        for (var i = 1; i < steps; i++) { // Skip start and end points
            var check_x = player.x + (dx * i);
            var check_y = player.y + (dy * i);
            var tile_data = tilemap_get_at_pixel(tile_layer, check_x, check_y);
            
            if (tile_data > 0 && tile_data != -2147483648) {
                return false; // Tile blocks line of sight
            }
        }
    }
    
    return true; // Clear line of sight
}

function get_weapon_sprite(weapon_id) {
    // Map weapon IDs to their sprite names
    switch(weapon_id) {
        case 0: return asset_get_index("spr_weapon_fists");
        case 1: return asset_get_index("spr_weapon_monoblade");
        case 2: return asset_get_index("spr_weapon_vibroknife");
        case 3: return asset_get_index("spr_weapon_arc_projector");
        case 4: return asset_get_index("spr_weapon_cryo_emitter");
        case 5: return asset_get_index("spr_weapon_riot_shield");
        case 6: return asset_get_index("spr_weapon_deflection_gauntlet");
        case 7: return asset_get_index("spr_weapon_powered_sledge");
        case 8: return asset_get_index("spr_weapon_plasma_blade");
        case 9: return asset_get_index("spr_weapon_chain_axe");
        case 10: return asset_get_index("spr_weapon_plasma_pistol");
        // Enemy weapons don't have sprites yet - return -1
        default: return -1;
    }
}



