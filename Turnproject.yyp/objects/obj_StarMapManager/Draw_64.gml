// obj_StarMapManager Draw GUI Event
// Show input instructions for the star map

// Only show instructions if no crew selection UI is active
var crew_ui = instance_find(obj_CrewSelectUI, 0);
if (crew_ui != noone && crew_ui.ui_visible) {
    exit; // Skip drawing instructions when crew UI is active
}

// Draw instructions at the bottom of the screen
var gui_width = display_get_gui_width();
var gui_height = display_get_gui_height();

draw_set_font(-1); // Default font
draw_set_halign(fa_center);
draw_set_valign(fa_bottom);

// Background for instructions
draw_set_color(c_black);
draw_set_alpha(0.7);
draw_rectangle(0, gui_height - 40, gui_width, gui_height, false);

// Instructions text
draw_set_color(c_white);
draw_set_alpha(1.0);

if (variable_instance_exists(id, "keyboard_navigation_active") && keyboard_navigation_active) {
    // Keyboard navigation is active
    draw_text(gui_width / 2, gui_height - 25, "Arrow Keys/Tab: Navigate Systems • Enter: Select • ESC: Main Menu • Mouse: Switch to Mouse Mode");
} else {
    // Mouse navigation is active (default)
    draw_text(gui_width / 2, gui_height - 25, "Mouse: Hover & Click Systems • Arrow Keys: Switch to Keyboard Mode • ESC: Main Menu");
}

// Show current system info if keyboard navigation is active and a system is selected
if (variable_instance_exists(id, "keyboard_navigation_active") && keyboard_navigation_active && 
    variable_instance_exists(id, "selected_system_index") && variable_instance_exists(id, "unlocked_systems") &&
    selected_system_index >= 0 && selected_system_index < array_length(unlocked_systems)) {
    
    var selected_system = unlocked_systems[selected_system_index];
    if (instance_exists(selected_system)) {
        // Show selected system name at the top
        draw_set_halign(fa_center);
        draw_set_valign(fa_top);
        draw_set_color(c_yellow);
        draw_text(gui_width / 2, 10, "Selected: " + selected_system.system_name + " (" + string(selected_system_index + 1) + "/" + string(array_length(unlocked_systems)) + ")");
    }
}

// Reset draw settings
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
draw_set_alpha(1.0);