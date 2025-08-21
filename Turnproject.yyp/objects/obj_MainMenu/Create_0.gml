// Main Menu Manager - Create Event

// CRITICAL: Initialize enums FIRST before using them
menu_enums();

// Initialize base menu system with main menu context
var main_menu_option_array = [
    "New Game",
    "Continue", 
    "Settings",
    "Scene Gallery",
    "Quit"
];

init_base_menu(MENU_CONTEXT.MAIN_MENU, main_menu_option_array);

// Settings values initialization
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

// Scene gallery variables (main menu specific)
scene_list = [];
selected_scene_index = 0;

// Load settings from file
load_settings();

// Background image variables
background_image = noone;
background_fade_timer = 0;
background_fade_duration = 1800; // 30 seconds at 60fps (much longer)
show_promo_background = true;
current_promo_index = 0;

// Promo image cycle arrays (013-019 and 026-032)
promo_images = ["013", "014", "015", "016", "017", "018", "019", "026", "027", "028", "029", "030", "031", "032"];

// Select random promo image for this session
randomize(); // Ensure true randomness
current_promo_index = irandom(array_length(promo_images) - 1);

// Load current promo background image
load_menu_background_image();

// Initialize current options using base menu system
update_current_options();

show_debug_message("Main Menu Manager initialized");