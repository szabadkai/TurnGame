// Main Menu Manager - Create Event

// CRITICAL: Initialize enums FIRST before using them
menu_enums();

// Menu state variables
menu_state = MENUSTATE.MAIN;
previous_menu_state = MENUSTATE.MAIN;
selected_option = 0;
transition_alpha = 0;
transition_speed = 0.05;
transition_direction = 1; // 1 = fade in, -1 = fade out

// Menu option arrays
main_menu_options = [
    "New Game",
    "Continue", 
    "Settings",
    "Scene Gallery",
    "Quit"
];

settings_options = [
    "Audio",
    "Graphics", 
    "Controls",
    "Gameplay",
    "Back"
];

audio_options = [
    "Master Volume",
    "SFX Volume",
    "Music Volume",
    "Back"
];

graphics_options = [
    "Fullscreen",
    "Zoom Level",
    "Back"
];

controls_options = [
    "Move Up",
    "Move Down", 
    "Move Left",
    "Move Right",
    "Attack",
    "Player Details",
    "Back"
];

gameplay_options = [
    "Combat Speed",
    "Auto Save",
    "Difficulty",
    "Back"
];

// Current menu options reference
current_options = main_menu_options;

// Menu positioning
menu_x = room_width / 2;
menu_y = room_height / 2;
option_spacing = 16;
title_y_offset = -60;

// Font and colors
menu_font = Font1;
title_color = c_white;
selected_color = c_yellow;
normal_color = c_ltgray;
disabled_color = c_gray;

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

// Scene gallery variables
scene_list = [];
selected_scene_index = 0;

// Save system variables
save_slots = [];
selected_save_slot = 0;

// Initialize save slot checking
check_save_slots();

// Load settings from file
load_settings();

// Menu animation variables
menu_appear_timer = 0;
menu_appear_duration = 30;

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

// Initialize current options
update_current_options();

show_debug_message("Main Menu Manager initialized");