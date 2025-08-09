// UI System Failsafe - Force create UI objects if missing

if (variable_global_exists("combat_log")) {
    global.combat_log("=== UI FAILSAFE CHECK ===");
}

// Check and create PlayerDetails
if (instance_number(obj_PlayerDetails) == 0) {
    if (variable_global_exists("combat_log")) {
        global.combat_log("FAILSAFE: Creating PlayerDetails");
    }
    var pd = instance_create_layer(64, 0, "Instances", obj_PlayerDetails);
    if (pd == noone) {
        // Try without layer specification
        pd = instance_create_depth(64, 0, -10, obj_PlayerDetails);
    }
}

// Check and create UIManager  
if (instance_number(obj_UIManager) == 0) {
    if (variable_global_exists("combat_log")) {
        global.combat_log("FAILSAFE: Creating UIManager");
    }
    var ui = instance_create_layer(128, 0, "Instances", obj_UIManager);
    if (ui == noone) {
        // Try without layer specification
        ui = instance_create_depth(128, 0, -10, obj_UIManager);
    }
}

// Check and create LevelUpOverlay
if (instance_number(obj_LevelUpOverlay) == 0) {
    if (variable_global_exists("combat_log")) {
        global.combat_log("FAILSAFE: Creating LevelUpOverlay");
    }
    var luo = instance_create_layer(96, 0, "Instances", obj_LevelUpOverlay);
    if (luo == noone) {
        // Try without layer specification  
        luo = instance_create_depth(96, 0, -10, obj_LevelUpOverlay);
    }
}

if (variable_global_exists("combat_log")) {
    global.combat_log("UI FAILSAFE COMPLETE:");
    global.combat_log("PlayerDetails: " + string(instance_number(obj_PlayerDetails)));
    global.combat_log("UIManager: " + string(instance_number(obj_UIManager)));  
    global.combat_log("LevelUpOverlay: " + string(instance_number(obj_LevelUpOverlay)));
    global.combat_log("Press 'I' to test UI system!");
}