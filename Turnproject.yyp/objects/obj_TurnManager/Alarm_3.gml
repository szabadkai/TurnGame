// obj_TurnManager Alarm[3] Event
// Check combat win/loss conditions

show_debug_message("Checking combat win/loss conditions...");

// Count remaining players and enemies
var player_count = instance_number(obj_Player);
var enemy_count = instance_number(obj_Enemy);

show_debug_message("Players remaining: " + string(player_count) + ", Enemies remaining: " + string(enemy_count));

// Check win condition (all enemies defeated)
if (enemy_count == 0 && player_count > 0) {
    show_debug_message("COMBAT WON! All enemies defeated!");
    handle_combat_victory();
}
// Check loss condition (all players dead)
else if (player_count == 0) {
    show_debug_message("COMBAT LOST! All players are dead!");
    handle_combat_defeat();
}
// Combat continues
else {
    show_debug_message("Combat continues...");
}

// Handle combat victory
function handle_combat_victory() {
    show_debug_message("Processing combat victory...");
    
    // Award XP to remaining players
    var player_count = instance_number(obj_Player);
    var xp_award = 50; // Base XP award
    
    if (player_count > 0) {
        distribute_party_xp(xp_award);
        
        if (variable_global_exists("combat_log")) {
            global.combat_log("VICTORY! Combat complete.");
        }
    }
    
    // Notify GameManager of combat completion
    if (variable_global_exists("game_manager") && instance_exists(global.game_manager)) {
        global.game_manager.on_combat_completed(true, xp_award);
    }
    
    // Create or show combat results UI
    var results_ui = instance_find(obj_CombatResultsUI, 0);
    if (results_ui == noone) {
        results_ui = instance_create_layer(0, 0, "Instances", obj_CombatResultsUI);
    }
    
    if (results_ui != noone) {
        results_ui.show_victory_results(xp_award);
    }
}

// Handle combat defeat
function handle_combat_defeat() {
    show_debug_message("Processing combat defeat...");
    
    if (variable_global_exists("combat_log")) {
        global.combat_log("DEFEAT! All party members have fallen.");
    }
    
    // Notify GameManager of combat defeat
    if (variable_global_exists("game_manager") && instance_exists(global.game_manager)) {
        global.game_manager.on_combat_completed(false, 0);
    }
    
    // Create or show combat results UI
    var results_ui = instance_find(obj_CombatResultsUI, 0);
    if (results_ui == noone) {
        results_ui = instance_create_layer(0, 0, "Instances", obj_CombatResultsUI);
    }
    
    if (results_ui != noone) {
        results_ui.show_defeat_results();
    }
}