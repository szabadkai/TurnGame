// Dialog evaluator functions
// Handles conditions, skill checks, and effects processing

// Evaluate dialog conditions
function evaluate_dialog_conditions(conditions) {
    if (conditions == undefined) return true;
    
    var condition_names = variable_struct_get_names(conditions);
    
    for (var i = 0; i < array_length(condition_names); i++) {
        var condition_name = condition_names[i];
        var condition_value = variable_struct_get(conditions, condition_name);
        
        switch (condition_name) {
            case "background":
                if (!check_character_background(condition_value)) {
                    return false;
                }
                break;
                
            case "loop_count":
                if (!check_loop_count(condition_value)) {
                    return false;
                }
                break;
                
            case "intel":
                if (!check_stat_condition("intel", condition_value)) {
                    return false;
                }
                break;
                
            case "emotions":
                if (!check_emotion_conditions(condition_value)) {
                    return false;
                }
                break;
                
            case "resources":
                if (!check_resource_conditions(condition_value)) {
                    return false;
                }
                break;
                
            case "remembered_event":
                if (!check_remembered_event(condition_value)) {
                    return false;
                }
                break;
                
            case "remembered_death":
                if (!check_flag("remembered_death")) {
                    return false;
                }
                break;
                
            case "skill_check_result":
                // This would be checked after a skill check is performed
                break;
                
            default:
                // Check as a simple flag or counter
                if (!check_general_condition(condition_name, condition_value)) {
                    return false;
                }
                break;
        }
    }
    
    return true;
}

// Check character background
function check_character_background(required_background) {
    var player_background = global.player_background ?? "";
    return player_background == required_background;
}

// Check loop count condition
function check_loop_count(condition) {
    var current_loop = global.loop_count ?? 0;
    
    if (is_string(condition)) {
        var op1 = string_char_at(condition, 1);
        var op2 = (string_length(condition) >= 2) ? string_char_at(condition, 2) : "";
        var skip = (op2 == "=") ? 2 : 1;
        
        if (op1 == ">" || op1 == "<" || op1 == "=") {
            var rhs = string_delete(condition, 1, skip);
            var compare_value = real(rhs);
            if (op1 == ">" && op2 == "=") return current_loop >= compare_value;
            if (op1 == ">") return current_loop > compare_value;
            if (op1 == "<" && op2 == "=") return current_loop <= compare_value;
            if (op1 == "<") return current_loop < compare_value;
            if (op1 == "=") return current_loop == compare_value;
        }
    }
    
    return current_loop == real(condition);
}

// Check stat condition
function check_stat_condition(stat_name, condition) {
    var current_value = get_dialog_stat(stat_name);
    
    if (is_string(condition)) {
        var op1 = string_char_at(condition, 1);
        var op2 = (string_length(condition) >= 2) ? string_char_at(condition, 2) : "";
        var skip = (op2 == "=") ? 2 : 1;
        
        if (op1 == ">" || op1 == "<" || op1 == "=") {
            var rhs = string_delete(condition, 1, skip);
            var compare_value = real(rhs);
            if (op1 == ">" && op2 == "=") return current_value >= compare_value;
            if (op1 == ">") return current_value > compare_value;
            if (op1 == "<" && op2 == "=") return current_value <= compare_value;
            if (op1 == "<") return current_value < compare_value;
            if (op1 == "=") return current_value == compare_value;
        }
    }
    
    // If no operator found, try direct comparison
    try {
        return current_value == real(condition);
    } catch (e) {
        show_debug_message("Invalid stat condition: " + string(condition));
        return false;
    }
}

// Check emotion conditions
function check_emotion_conditions(emotions) {
    var emotion_names = variable_struct_get_names(emotions);
    
    for (var i = 0; i < array_length(emotion_names); i++) {
        var emotion_name = emotion_names[i];
        var condition = variable_struct_get(emotions, emotion_name);
        
        if (!check_stat_condition(emotion_name, condition)) {
            return false;
        }
    }
    
    return true;
}

// Check resource conditions
function check_resource_conditions(resources) {
    var resource_names = variable_struct_get_names(resources);
    
    for (var i = 0; i < array_length(resource_names); i++) {
        var resource_name = resource_names[i];
        var condition = variable_struct_get(resources, resource_name);
        
        var current_value = get_dialog_resource(resource_name);
        if (!check_numeric_condition(current_value, condition)) {
            return false;
        }
    }
    
    return true;
}

// Check remembered event
function check_remembered_event(event_name) {
    return check_flag("remembered_" + event_name);
}

// Check general condition (flags, counters)
function check_general_condition(condition_name, condition_value) {
    // Try as flag first
    if (is_bool(condition_value)) {
        return check_flag(condition_name) == condition_value;
    }
    
    // Try as counter
    return check_stat_condition(condition_name, condition_value);
}

// Check numeric condition helper
function check_numeric_condition(current_value, condition) {
    if (is_string(condition)) {
        var op1 = string_char_at(condition, 1);
        var op2 = (string_length(condition) >= 2) ? string_char_at(condition, 2) : "";
        var skip = (op2 == "=") ? 2 : 1;
        
        if (op1 == ">" || op1 == "<" || op1 == "=") {
            var rhs = string_delete(condition, 1, skip);
            var compare_value = real(rhs);
            if (op1 == ">" && op2 == "=") return current_value >= compare_value;
            if (op1 == ">") return current_value > compare_value;
            if (op1 == "<" && op2 == "=") return current_value <= compare_value;
            if (op1 == "<") return current_value < compare_value;
            if (op1 == "=") return current_value == compare_value;
        }
    }
    
    return current_value == real(condition);
}

// Perform skill check
function perform_skill_check(skill_check_data) {
    var skill_type = skill_check_data.type;
    var difficulty = skill_check_data.difficulty;
    var roll = irandom_range(1, 20);
    
    // Get character modifiers
    var modifier = get_skill_modifier(skill_type);
    var total = roll + modifier;
    
    show_debug_message("Skill Check: " + skill_type + " | Roll: " + string(roll) + " + " + string(modifier) + " = " + string(total) + " vs DC " + string(difficulty));
    
    // Handle contested checks
    if (variable_struct_exists(skill_check_data, "contested")) {
        var contested_data = skill_check_data.contested;
        var npc_roll = irandom_range(1, 20) + contested_data.value;
        
        if (total >= npc_roll) {
            return roll == 20 ? 3 : 1; // CRITICAL_SUCCESS : SUCCESS
        } else {
            return roll == 1 ? 4 : 2; // CRITICAL_FAILURE : FAILURE
        }
    }
    
    // Handle group modifiers
    if (variable_struct_exists(skill_check_data, "group_modifiers")) {
        var modifiers = skill_check_data.group_modifiers;
        for (var i = 0; i < array_length(modifiers); i++) {
            var modifier_item = modifiers[i];
            if (evaluate_dialog_conditions(modifier_item.condition)) {
                difficulty += real(modifier_item.delta);
            }
        }
    }
    
    // Determine result
    if (roll == 20) {
        return 3; // SkillCheckResult.CRITICAL_SUCCESS
    } else if (roll == 1) {
        return 4; // SkillCheckResult.CRITICAL_FAILURE
    } else if (total >= difficulty) {
        return 1; // SkillCheckResult.SUCCESS
    } else {
        return 2; // SkillCheckResult.FAILURE
    }
}

// Get skill modifier based on character stats
function get_skill_modifier(skill_type) {
    // Parse compound skills like "intelligence+void_touched"
    if (string_pos("+", skill_type) > 0) {
        var skills = string_split(skill_type, "+");
        var total_modifier = 0;
        for (var i = 0; i < array_length(skills); i++) {
            total_modifier += get_single_skill_modifier(skills[i]);
        }
        return total_modifier;
    } else {
        return get_single_skill_modifier(skill_type);
    }
}

// Get modifier for a single skill
function get_single_skill_modifier(skill) {
    // Find player instance
    var player = instance_find(obj_Player, 0);
    if (player == noone) {
        show_debug_message("No player instance found for skill check");
        return 0;
    }
    
    switch (skill) {
        case "intelligence":
        case "int":
            return floor((player.int - 10) / 2);
        case "deception":
        case "diplomacy":
            return floor((player.cha - 10) / 2);
        case "engineering":
            return floor((player.int - 10) / 2);
        case "leadership":
            return floor((player.cha - 10) / 2);
        case "void_touched":
            return check_flag("void_touched") ? 2 : 0;
        case "willpower":
            return floor((player.wis - 10) / 2);
        default:
            return 0;
    }
}

// Process dialog effects
function process_dialog_effects(effects) {
    var effect_names = variable_struct_get_names(effects);
    
    for (var i = 0; i < array_length(effect_names); i++) {
        var effect_name = effect_names[i];
        var effect_value = variable_struct_get(effects, effect_name);
        
        switch (effect_name) {
            case "inc":
                process_increment_effects(effect_value);
                break;
            case "dec":
                process_decrement_effects(effect_value);
                break;
            case "set":
                process_set_effects(effect_value);
                break;
            case "effect_chance":
                process_chance_effect(effect_value);
                break;
            case "effect_delayed":
                process_delayed_effect(effect_value);
                break;
            case "scaling_effect":
                process_scaling_effect(effect_value);
                break;
            default:
                // Direct effect
                set_dialog_stat(effect_name, effect_value);
                break;
        }
    }
}

// Process increment effects
function process_increment_effects(inc_effects) {
    var effect_names = variable_struct_get_names(inc_effects);
    
    for (var i = 0; i < array_length(effect_names); i++) {
        var effect_name = effect_names[i];
        var amount = variable_struct_get(inc_effects, effect_name);
        
        var current_value = get_dialog_stat(effect_name);
        set_dialog_stat(effect_name, current_value + amount);
    }
}

// Process decrement effects
function process_decrement_effects(dec_effects) {
    var effect_names = variable_struct_get_names(dec_effects);
    
    for (var i = 0; i < array_length(effect_names); i++) {
        var effect_name = effect_names[i];
        var amount = variable_struct_get(dec_effects, effect_name);
        
        var current_value = get_dialog_stat(effect_name);
        set_dialog_stat(effect_name, current_value - amount);
    }
}

// Process set effects
function process_set_effects(set_effects) {
    var effect_names = variable_struct_get_names(set_effects);
    
    for (var i = 0; i < array_length(effect_names); i++) {
        var effect_name = effect_names[i];
        var value = variable_struct_get(set_effects, effect_name);
        
        set_dialog_stat(effect_name, value);
    }
}

// Process chance effect
function process_chance_effect(chance_data) {
    var probability = chance_data.probability;
    var effect = chance_data.effect;
    
    if (random(1) < probability) {
        set_dialog_flag(effect, true);
    }
}

// Process delayed effect
function process_delayed_effect(delay_data) {
    var turns = delay_data.turns;
    var effect_type = delay_data.type;
    var who = delay_data.who ?? "";
    
    // Store delayed effect for later processing
    if (!variable_global_exists("delayed_effects")) {
        global.delayed_effects = [];
    }
    
    array_push(global.delayed_effects, {
        turns_remaining: turns,
        effect_type: effect_type,
        who: who
    });
}

// Process scaling effect
function process_scaling_effect(scaling_data) {
    var counter = scaling_data.counter;
    var effect = scaling_data.effect;
    var scale_factor = scaling_data.scale_factor ?? 1;
    
    var current_count = get_dialog_counter(counter);
    set_dialog_counter(counter, current_count + 1);
    
    // Apply scaled effect
    var effect_value = current_count * scale_factor;
    set_dialog_stat(effect, effect_value);
}
