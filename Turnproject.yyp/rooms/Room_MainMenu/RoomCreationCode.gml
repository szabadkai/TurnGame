// Main Menu Room Creation Code
// Initialize the main menu system

// CRITICAL: Initialize menu enums FIRST before any objects use them
menu_enums();

// Initialize dialog system for scene gallery functionality
if (!variable_global_exists("dialog_flags")) {
    init_dialog_system();
}

// Set the starting room reference for "New Game" functionality  
global.gameplay_room = Room1;

show_debug_message("Main Menu room initialized");