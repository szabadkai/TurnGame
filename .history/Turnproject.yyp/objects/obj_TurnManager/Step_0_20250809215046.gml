// TurnManager Step - includes UI backup system

// === BACKUP UI INPUT HANDLER ===
// This runs if UIManager fails for any reason
if (keyboard_check_pressed(ord("I"))) {
    var ui_manager = instance_find(obj_UIManager, 0);
    if (ui_manager == noone) {
        // UIManager missing - handle directly
        if (variable_global_exists("combat_log")) {
            global.combat_log("BACKUP: UIManager missing, handling 'I' key directly");
        }
        
        var player_details = instance_find(obj_PlayerDetails, 0);
        if (player_details != noone) {
            player_details.visible = true;
            player_details.player_instance = instance_find(obj_Player, 0);
            player_details.refresh_player_list();
            
            if (variable_global_exists("combat_log")) {
                global.combat_log("BACKUP: PlayerDetails opened successfully");
            }
        } else {
            if (variable_global_exists("combat_log")) {
                global.combat_log("BACKUP: PlayerDetails also missing!");
            }
        }
    }
}
