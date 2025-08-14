// UI System Failsafe - Force create UI objects if missing

show_debug_message("=== UI FAILSAFE CHECK ===");

// Check and create PlayerDetails
if (instance_number(obj_PlayerDetails) == 0) {
    show_debug_message("FAILSAFE: Creating PlayerDetails");
    var pd = instance_create_layer(64, 0, "Instances", obj_PlayerDetails);
    if (pd == noone) {
        // Try without layer specification
        pd = instance_create_depth(64, 0, -10, obj_PlayerDetails);
    }
}

// Check and create UIManager  
if (instance_number(obj_UIManager) == 0) {
    show_debug_message("FAILSAFE: Creating UIManager");
    var ui = instance_create_layer(128, 0, "Instances", obj_UIManager);
    if (ui == noone) {
        // Try without layer specification
        ui = instance_create_depth(128, 0, -10, obj_UIManager);
    }
}

// Check and create LevelUpOverlay
if (instance_number(obj_LevelUpOverlay) == 0) {
    show_debug_message("FAILSAFE: Creating LevelUpOverlay");
    var luo = instance_create_layer(96, 0, "Instances", obj_LevelUpOverlay);
    if (luo == noone) {
        // Try without layer specification  
        luo = instance_create_depth(96, 0, -10, obj_LevelUpOverlay);
    }
}

show_debug_message("UI FAILSAFE COMPLETE:");
show_debug_message("PlayerDetails: " + string(instance_number(obj_PlayerDetails)));
show_debug_message("UIManager: " + string(instance_number(obj_UIManager)));
show_debug_message("LevelUpOverlay: " + string(instance_number(obj_LevelUpOverlay)));
show_debug_message("Press 'I' to test UI system!");
