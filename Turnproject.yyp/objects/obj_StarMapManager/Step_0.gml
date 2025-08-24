// obj_StarMapManager Step Event
// Handle star map updates and state management

// Initialize input system if not already done
if (!variable_global_exists("input_bindings")) {
    init_input_system();
}

// Update input system
update_input_system();

// Initialize keyboard navigation state
if (!variable_instance_exists(id, "keyboard_navigation_active")) {
    keyboard_navigation_active = false;
    selected_system_index = 0;
    unlocked_systems = [];
    // Only update systems list if systems have been initialized
    if (systems_initialized) {
        update_unlocked_systems_list();
    }
}

// Handle returning from dialog room
// (Pending scene handling is done by DialogManager in Room_Dialog)

// Get navigation input
var nav = input_get_navigation();

// ESC key to return to main menu
if (nav.cancel) {
    scr_nav_go(GameState.MAIN_MENU, undefined);
}

// Keyboard navigation for star systems
if (array_length(unlocked_systems) > 0) {
    // Enable keyboard navigation on first input
    if (nav.up || nav.down || nav.left || nav.right || nav.next_tab) {
        keyboard_navigation_active = true;
    }
    
    if (keyboard_navigation_active) {
        // Navigate between systems
        if (nav.up || nav.left) {
            selected_system_index = (selected_system_index - 1 + array_length(unlocked_systems)) % array_length(unlocked_systems);
            update_system_selection();
        } else if (nav.down || nav.right || nav.next_tab) {
            selected_system_index = (selected_system_index + 1) % array_length(unlocked_systems);
            update_system_selection();
        }
        
        // Select current system
        if (nav.select) {
            var selected_system = unlocked_systems[selected_system_index];
            if (instance_exists(selected_system)) {
                selected_system.trigger_keyboard_selection();
            }
        }
        
        // Disable keyboard navigation on mouse movement
        if (abs(global.input_mouse.x - mouse_x) > 5 || abs(global.input_mouse.y - mouse_y) > 5) {
            keyboard_navigation_active = false;
            clear_system_selection();
        }
    }
}

// Update list of unlocked systems for keyboard navigation
function update_unlocked_systems_list() {
    // Only proceed if systems have been initialized
    if (!systems_initialized) {
        return;
    }
    
    unlocked_systems = [];
    
    // Simple collection without sorting to prevent persistent crashes
    // Navigation order will be based on instance creation order
    with (obj_StarSystem) {
        if (is_unlocked) {
            array_push(other.unlocked_systems, id);
        }
    }
}

// Update visual selection for keyboard navigation
function update_system_selection() {
    // Clear all keyboard selections first
    with (obj_StarSystem) {
        keyboard_selected = false;
    }
    
    // Set current selection
    if (selected_system_index >= 0 && selected_system_index < array_length(unlocked_systems)) {
        var selected_system = unlocked_systems[selected_system_index];
        if (instance_exists(selected_system)) {
            selected_system.keyboard_selected = true;
        }
    }
}

// Clear all keyboard selections
function clear_system_selection() {
    with (obj_StarSystem) {
        keyboard_selected = false;
    }
}
