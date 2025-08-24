// obj_TurnManager Step Event
// Handle global game state and input

// M key shortcut to access star map
if (keyboard_check_pressed(ord("M"))) {
    // Initialize star map system if not already done
    if (!variable_global_exists("star_map_state")) {
        init_star_map();
    }
    
    show_debug_message("M key pressed - navigating to star map");
    scr_nav_go(GameState.STARMAP, undefined);
}

// V key debug shortcut to trigger victory (kill all enemies)
if (keyboard_check_pressed(ord("V"))) {
    show_debug_message("V key pressed - triggering combat victory by killing all enemies");
    
    var enemy_count = instance_number(obj_Enemy);
    show_debug_message("Killing " + string(enemy_count) + " enemies...");
    
    // Kill all enemies to trigger victory
    with (obj_Enemy) {
        show_debug_message("Killing enemy: " + character_name);
        hp = 0; // This will trigger death in next step
    }
    
    scr_log("DEBUG: All enemies eliminated for testing!");
}

// B key debug shortcut to trigger defeat (kill all players)
if (keyboard_check_pressed(ord("B"))) {
    show_debug_message("B key pressed - triggering combat defeat by killing all players");
    
    var player_count = instance_number(obj_Player);
    show_debug_message("Killing " + string(player_count) + " players...");
    
    // Kill all players to trigger defeat
    with (obj_Player) {
        show_debug_message("Killing player: " + character_name);
        hp = 0; // This will trigger death in next step
    }
    
    scr_log("DEBUG: All players defeated for testing!");
}

// C key to manually check combat state (for debugging)
if (keyboard_check_pressed(ord("C"))) {
    show_debug_message("C key pressed - manually checking combat state");
    alarm[3] = 1; // Trigger combat state check
}

// AUTOMATIC COMBAT END CHECK - Check every 60 frames (1 second)
if (get_timer() mod 1000000 < 16667) { // Check roughly once per second
    var enemy_count = instance_number(obj_Enemy);
    var player_count = instance_number(obj_Player);
    
    // Only check if there are players but no enemies (victory) or no players (defeat)
    if ((enemy_count == 0 && player_count > 0) || player_count == 0) {
        alarm[3] = 1; // Trigger combat state check immediately
    }
}
