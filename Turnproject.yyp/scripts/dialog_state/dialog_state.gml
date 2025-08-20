// Dialog state management functions
// Handles flags, counters, resources, and persistent state

// Initialize dialog state if not already done
function init_dialog_state() {
    if (!variable_global_exists("dialog_flags")) {
        global.dialog_flags = {};
    }
    if (!variable_global_exists("dialog_counters")) {
        global.dialog_counters = {};
    }
    if (!variable_global_exists("dialog_reputation")) {
        global.dialog_reputation = {
            earth: 0,
            pirates: 0,
            watchers: 0,
            nexus: 0
        };
    }
    if (!variable_global_exists("dialog_resources")) {
        global.dialog_resources = {
            fuel: 20,
            supplies: 10,
            intel: 0
        };
    }
    if (!variable_global_exists("dialog_emotions")) {
        global.dialog_emotions = {
            chen_fear: 0,
            chen_trust: 0,
            torres_trust: 0,
            torres_suspicion: 0,
            torres_doubt: 0,
            crew_morale: 0,
            crew_fear: 0,
            crew_alert: "low"
        };
    }
    if (!variable_global_exists("loop_count")) {
        global.loop_count = 0;
    }
    if (!variable_global_exists("player_background")) {
        global.player_background = "";
    }
}

// Flag management
function set_dialog_flag(flag_name, value) {
    init_dialog_state();
    variable_struct_set(global.dialog_flags, flag_name, value);
    show_debug_message("Set flag " + flag_name + " to " + string(value));
}

function get_dialog_flag(flag_name) {
    init_dialog_state();
    if (variable_struct_exists(global.dialog_flags, flag_name)) {
        return variable_struct_get(global.dialog_flags, flag_name);
    }
    return false;
}

function check_flag(flag_name) {
    return get_dialog_flag(flag_name);
}

// Counter management
function set_dialog_counter(counter_name, value) {
    init_dialog_state();
    variable_struct_set(global.dialog_counters, counter_name, value);
    show_debug_message("Set counter " + counter_name + " to " + string(value));
}

function get_dialog_counter(counter_name) {
    init_dialog_state();
    if (variable_struct_exists(global.dialog_counters, counter_name)) {
        return variable_struct_get(global.dialog_counters, counter_name);
    }
    return 0;
}

function increment_dialog_counter(counter_name, amount = 1) {
    var current = get_dialog_counter(counter_name);
    set_dialog_counter(counter_name, current + amount);
}

function decrement_dialog_counter(counter_name, amount = 1) {
    var current = get_dialog_counter(counter_name);
    set_dialog_counter(counter_name, current - amount);
}

// Reputation management
function set_dialog_reputation(faction, value) {
    init_dialog_state();
    variable_struct_set(global.dialog_reputation, faction, value);
    show_debug_message("Set " + faction + " reputation to " + string(value));
}

function get_dialog_reputation(faction) {
    init_dialog_state();
    if (variable_struct_exists(global.dialog_reputation, faction)) {
        return variable_struct_get(global.dialog_reputation, faction);
    }
    return 0;
}

function modify_dialog_reputation(faction, amount) {
    var current = get_dialog_reputation(faction);
    set_dialog_reputation(faction, current + amount);
}

// Resource management
function set_dialog_resource(resource_name, value) {
    init_dialog_state();
    variable_struct_set(global.dialog_resources, resource_name, value);
    show_debug_message("Set " + resource_name + " to " + string(value));
}

function get_dialog_resource(resource_name) {
    init_dialog_state();
    if (variable_struct_exists(global.dialog_resources, resource_name)) {
        return variable_struct_get(global.dialog_resources, resource_name);
    }
    return 0;
}

function modify_dialog_resource(resource_name, amount) {
    var current = get_dialog_resource(resource_name);
    set_dialog_resource(resource_name, max(0, current + amount));
}

// Emotion management
function set_dialog_emotion(emotion_name, value) {
    init_dialog_state();
    variable_struct_set(global.dialog_emotions, emotion_name, value);
    show_debug_message("Set emotion " + emotion_name + " to " + string(value));
}

function get_dialog_emotion(emotion_name) {
    init_dialog_state();
    if (variable_struct_exists(global.dialog_emotions, emotion_name)) {
        return variable_struct_get(global.dialog_emotions, emotion_name);
    }
    return 0;
}

function modify_dialog_emotion(emotion_name, amount) {
    var current = get_dialog_emotion(emotion_name);
    set_dialog_emotion(emotion_name, current + amount);
}

// Generic stat management (handles all types)
function set_dialog_stat(stat_name, value) {
    // Handle compound names like "resources.fuel"
    if (string_pos(".", stat_name) > 0) {
        var parts = string_split(stat_name, ".");
        var category = parts[0];
        var name = parts[1];
        
        switch (category) {
            case "resources":
                set_dialog_resource(name, value);
                break;
            case "reputation":
                set_dialog_reputation(name, value);
                break;
            default:
                // Treat as counter
                set_dialog_counter(stat_name, value);
                break;
        }
        return;
    }
    
    // Check if it's a known emotion
    if (variable_struct_exists(global.dialog_emotions, stat_name)) {
        set_dialog_emotion(stat_name, value);
        return;
    }
    
    // Check if it's a known reputation
    if (variable_struct_exists(global.dialog_reputation, stat_name)) {
        set_dialog_reputation(stat_name, value);
        return;
    }
    
    // Check if it's a known resource
    if (variable_struct_exists(global.dialog_resources, stat_name)) {
        set_dialog_resource(stat_name, value);
        return;
    }
    
    // Handle special cases
    switch (stat_name) {
        case "loop_count":
            global.loop_count = value;
            break;
        case "player_background":
            global.player_background = value;
            break;
        default:
            // Default to counter
            set_dialog_counter(stat_name, value);
            break;
    }
}

function get_dialog_stat(stat_name) {
    // Handle compound names
    if (string_pos(".", stat_name) > 0) {
        var parts = string_split(stat_name, ".");
        var category = parts[0];
        var name = parts[1];
        
        switch (category) {
            case "resources":
                return get_dialog_resource(name);
            case "reputation":
                return get_dialog_reputation(name);
            default:
                return get_dialog_counter(stat_name);
        }
    }
    
    // Check emotions first
    if (variable_struct_exists(global.dialog_emotions, stat_name)) {
        return get_dialog_emotion(stat_name);
    }
    
    // Check reputation
    if (variable_struct_exists(global.dialog_reputation, stat_name)) {
        return get_dialog_reputation(stat_name);
    }
    
    // Check resources
    if (variable_struct_exists(global.dialog_resources, stat_name)) {
        return get_dialog_resource(stat_name);
    }
    
    // Handle special cases
    switch (stat_name) {
        case "loop_count":
            return global.loop_count;
        case "player_background":
            return global.player_background;
        default:
            return get_dialog_counter(stat_name);
    }
}

// Delayed effects processing
function process_delayed_effects() {
    if (!variable_global_exists("delayed_effects")) {
        return;
    }
    
    for (var i = array_length(global.delayed_effects) - 1; i >= 0; i--) {
        var effect = global.delayed_effects[i];
        effect.turns_remaining--;
        
        if (effect.turns_remaining <= 0) {
            // Trigger the delayed effect
            trigger_delayed_effect(effect);
            array_delete(global.delayed_effects, i, 1);
        }
    }
}

function trigger_delayed_effect(effect) {
    switch (effect.effect_type) {
        case "crew_betrayal":
            set_dialog_flag("crew_betrayal_" + effect.who, true);
            show_debug_message("Delayed effect triggered: crew betrayal by " + effect.who);
            break;
        case "phantom_attention":
            set_dialog_flag("phantom_attention", true);
            show_debug_message("Delayed effect triggered: phantom attention");
            break;
        case "gate_glitch":
            set_dialog_flag("gate_glitch", true);
            show_debug_message("Delayed effect triggered: gate glitch");
            break;
        default:
            show_debug_message("Unknown delayed effect: " + effect.effect_type);
            break;
    }
}

// Save/load dialog state
function save_dialog_state() {
    var state = {
        flags: global.dialog_flags,
        counters: global.dialog_counters,
        reputation: global.dialog_reputation,
        resources: global.dialog_resources,
        emotions: global.dialog_emotions,
        loop_count: global.loop_count,
        player_background: global.player_background,
        delayed_effects: global.delayed_effects ?? []
    };
    
    return json_stringify(state);
}

function load_dialog_state(state_json) {
    try {
        var state = json_parse(state_json);
        
        global.dialog_flags = state.flags ?? {};
        global.dialog_counters = state.counters ?? {};
        global.dialog_reputation = state.reputation ?? {};
        global.dialog_resources = state.resources ?? {};
        global.dialog_emotions = state.emotions ?? {};
        global.loop_count = state.loop_count ?? 0;
        global.player_background = state.player_background ?? "";
        global.delayed_effects = state.delayed_effects ?? [];
        
        return true;
    } catch (e) {
        show_debug_message("Failed to load dialog state: " + string(e));
        return false;
    }
}

// Reset dialog state for new game
function reset_dialog_state() {
    global.dialog_flags = {};
    global.dialog_counters = {};
    global.dialog_reputation = {
        earth: 0,
        pirates: 0,
        watchers: 0,
        nexus: 0
    };
    global.dialog_resources = {
        fuel: 20,
        supplies: 10,
        intel: 0
    };
    global.dialog_emotions = {
        chen_fear: 0,
        chen_trust: 0,
        torres_trust: 0,
        torres_suspicion: 0,
        torres_doubt: 0,
        crew_morale: 0,
        crew_fear: 0,
        crew_alert: "low"
    };
    global.loop_count = 0;
    global.player_background = "";
    global.delayed_effects = [];
    
    show_debug_message("Dialog state reset");
}

// Increment loop count (for meta-gaming features)
function increment_loop_count() {
    global.loop_count++;
    show_debug_message("Loop count incremented to " + string(global.loop_count));
}