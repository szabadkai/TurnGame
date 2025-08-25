// Main Menu Room Creation Code
// Initialize the main menu system

// Menu enums are automatically available from the script resource

// Initialize dialog system for scene gallery functionality
if (!variable_global_exists("dialog_flags")) {
    init_dialog_system();
}

// Set the starting room reference for "New Game" functionality  
global.gameplay_room = Room1;

// Start background music
start_background_music("menu");

show_debug_message("Main Menu room initialized");