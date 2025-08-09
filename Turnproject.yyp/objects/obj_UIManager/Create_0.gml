// UI Manager - Centralized UI Input Handling
// UI state tracking
ui_state = "none";  // "none", "player_details", "level_up"
current_player = noone;

// References to UI objects
player_details = noone;
level_up_overlay = noone;

// Initialize UI object references
player_details = instance_find(obj_PlayerDetails, 0);
level_up_overlay = instance_find(obj_LevelUpOverlay, 0);

function get_current_active_player() {
    var player_count = instance_number(obj_Player);
    
    // First priority: Find a player who needs ASI
    for (var i = 0; i < player_count; i++) {
        var player = instance_find(obj_Player, i);
        if (instance_exists(player) && player.needs_asi) {
            return player;
        }
    }
    
    // Second priority: Get the currently active player
    for (var i = 0; i < player_count; i++) {
        var player = instance_find(obj_Player, i);
        if (instance_exists(player) && player.state == TURNSTATE.active) {
            return player;
        }
    }
    
    // If no active player, return first player
    return instance_find(obj_Player, 0);
}

function show_player_details(player) {
    if (player_details == noone) return false;
    
    current_player = player;
    ui_state = "player_details";
    
    player_details.refresh_player_list();
    player_details.visible = true;
    player_details.player_instance = player;
    
    // Set the current player index
    for (var i = 0; i < array_length(player_details.player_list); i++) {
        if (player_details.player_list[i] == player) {
            player_details.current_player_index = i;
            break;
        }
    }
    return true;
}

function show_level_up_overlay(player) {
    if (level_up_overlay == noone) return false;
    
    current_player = player;
    ui_state = "level_up";
    
    level_up_overlay.show_asi_overlay(player);
    
    return true;
}

function close_all_ui() {
    ui_state = "none";
    current_player = noone;
    
    if (player_details != noone) {
        player_details.visible = false;
    }
    
    if (level_up_overlay != noone) {
        level_up_overlay.visible = false;
    }
    
    if (variable_global_exists("combat_log")) {
        global.combat_log("UI Manager: Closed all UI");
    }
}