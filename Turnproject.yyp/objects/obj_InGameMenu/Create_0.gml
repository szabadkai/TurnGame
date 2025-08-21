// In-Game Menu Manager - Create Event

// Initialize enums and systems
menu_enums();

// Initialize base menu system with in-game context
var in_game_menu_options = [
    "Resume Game",
    "Save Game", 
    "Load Game",
    "Settings",
    "Main Menu"
];

init_base_menu(MENU_CONTEXT.IN_GAME_MENU, in_game_menu_options);

// Settings values initialization (ensure global settings exist)
if (!variable_global_exists("game_settings")) {
    global.game_settings = {
        master_volume: 1.0,
        sfx_volume: 1.0,
        music_volume: 1.0,
        fullscreen: false,
        zoom_level: 4,
        combat_speed: 1.0,
        auto_save: true,
        difficulty: 1,
        
        // Key bindings
        key_up: vk_up,
        key_down: vk_down,
        key_left: vk_left,
        key_right: vk_right,
        key_attack: vk_space,
        key_details: ord("I")
    };
}

// Load settings from file
load_settings();

// Pause the game when menu opens
instance_deactivate_all(true);
instance_activate_object(obj_InGameMenu);

// Remember the room we came from for returning from settings
origin_room = room;

// Define custom close function for this instance
close_menu = function() {
    show_debug_message("Closing in-game menu and resuming game...");
    
    // Reactivate all game objects
    instance_activate_all();
    
    // Destroy this menu instance
    instance_destroy();
};

show_debug_message("In-Game Menu initialized and game paused");