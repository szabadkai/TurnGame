// === SHARED COMBAT ENTITY LOGIC ===
// Base class logic for death detection and cleanup

// Check for death condition
if (hp <= 0) {
    show_debug_message(character_name + " has died (HP: " + string(hp) + ")");
    
    // Trigger combat state check before destroying
    var turn_manager = instance_find(obj_TurnManager, 0);
    if (turn_manager != noone) {
        turn_manager.alarm[3] = 2; // Check win/loss conditions in 2 steps
        show_debug_message("Combat state check triggered for " + character_name);
    } else {
        show_debug_message("WARNING: No TurnManager found for combat state check!");
    }
    
    // Mark for destruction
    instance_destroy();
}