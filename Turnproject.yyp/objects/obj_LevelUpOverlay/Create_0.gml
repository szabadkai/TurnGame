// Level Up Overlay - Ability Score Improvement System
visible = false;
player_instance = noone;

// UI settings
background_alpha = 0.8;
panel_margin = 50;
line_height = 20;
section_spacing = 10;

// Ability Score Improvement state
asi_points_remaining = 0;  // Number of points to distribute
asi_selections = {
    strength: 0,
    dexterity: 0,
    constitution: 0,
    intelligence: 0,
    wisdom: 0,
    charisma: 0
};

// Button layout
button_width = 30;
button_height = 20;
buttons = [];  // Array of button objects {x, y, w, h, ability, type}

function show_asi_overlay(player) {
    show_debug_message("DEBUG: show_asi_overlay called for " + player.character_name);
    
    player_instance = player;
    visible = true;
    asi_points_remaining = 2;  // Standard ASI gives 2 points
    
    // Reset selections
    asi_selections.strength = 0;
    asi_selections.dexterity = 0;
    asi_selections.constitution = 0;
    asi_selections.intelligence = 0;
    asi_selections.wisdom = 0;
    asi_selections.charisma = 0;
    
    // Create button layout
    setup_buttons();
    
    show_debug_message("DEBUG: ASI overlay now visible = " + string(visible));
}

function setup_buttons() {
    buttons = [];
    
    var viewport_w = display_get_gui_width();
    var viewport_h = display_get_gui_height();
    var panel_x = panel_margin;
    var panel_y = panel_margin;
    var text_x = panel_x + 20;
    var start_y = panel_y + 150;  // Position below header info
    
    var abilities = ["strength", "dexterity", "constitution", "intelligence", "wisdom", "charisma"];
    
    for (var i = 0; i < array_length(abilities); i++) {
        var ability = abilities[i];
        var y_pos = start_y + (i * (line_height + 5));
        
        // Plus button
        var plus_btn = {
            x: text_x + 280,
            y: y_pos + 20,
            w: button_width,
            h: button_height,
            ability: ability,
            type: "plus"
        };
        array_push(buttons, plus_btn);
        
        // Minus button  
        var minus_btn = {
            x: text_x + 320,
            y: y_pos + 20,
            w: button_width,
            h: button_height,
            ability: ability,
            type: "minus"
        };
        array_push(buttons, minus_btn);
    }
    
    // Confirm button
    var confirm_btn = {
        x: text_x + 150,
        y: start_y + (array_length(abilities) * (line_height + 5)) + 30,
        w: 100,
        h: 30,
        ability: "confirm",
        type: "confirm"
    };
    array_push(buttons, confirm_btn);
}

function apply_asi_improvements() {
    // Apply all selected ability score improvements
    if (asi_selections.strength > 0) {
        increase_ability_score(player_instance, "strength", asi_selections.strength);
    }
    if (asi_selections.dexterity > 0) {
        increase_ability_score(player_instance, "dexterity", asi_selections.dexterity);
    }
    if (asi_selections.constitution > 0) {
        increase_ability_score(player_instance, "constitution", asi_selections.constitution);
    }
    if (asi_selections.intelligence > 0) {
        increase_ability_score(player_instance, "intelligence", asi_selections.intelligence);
    }
    if (asi_selections.wisdom > 0) {
        increase_ability_score(player_instance, "wisdom", asi_selections.wisdom);
    }
    if (asi_selections.charisma > 0) {
        increase_ability_score(player_instance, "charisma", asi_selections.charisma);
    }
    
    if (variable_global_exists("combat_log")) {
        global.combat_log(player_instance.character_name + " completed ability score improvements!");
    }
    
    // Clear the needs_asi flag
    player_instance.needs_asi = false;
    
    // Check if other players need ASI and auto-switch to them
    var player_count = instance_number(obj_Player);
    for (var i = 0; i < player_count; i++) {
        var other_player = instance_find(obj_Player, i);
        if (instance_exists(other_player) && other_player != player_instance && other_player.needs_asi) {
            // Switch to the next player who needs ASI
            if (variable_global_exists("combat_log")) {
                global.combat_log("Switching ASI overlay to " + other_player.character_name);
            }
            show_asi_overlay(other_player);
            return; // Don't hide the overlay, just switch players
        }
    }
    
    // No more players need ASI, hide the overlay
    visible = false;
}
