// Input System - Unified input abstraction for consistent UI behavior
// Provides both keyboard and mouse support for all UI interactions

// Input action definitions
enum INPUT_ACTION {
    NAVIGATE_UP,
    NAVIGATE_DOWN,
    NAVIGATE_LEFT,
    NAVIGATE_RIGHT,
    SELECT,
    CANCEL,
    CLICK_POSITION,
    SCROLL_UP,
    SCROLL_DOWN,
    TOGGLE,
    NEXT_TAB,
    PREV_TAB
}

// Initialize input system with default bindings
function init_input_system() {
    global.input_bindings = {
        navigate_up: {
            keyboard: [vk_up, ord("W")],
            mouse_wheel: "up"
        },
        navigate_down: {
            keyboard: [vk_down, ord("S")],
            mouse_wheel: "down"  
        },
        navigate_left: {
            keyboard: [vk_left, ord("A")]
        },
        navigate_right: {
            keyboard: [vk_right, ord("D")]
        },
        select: {
            keyboard: [vk_enter, vk_space],
            mouse: mb_left
        },
        cancel: {
            keyboard: [vk_escape]
        },
        toggle: {
            keyboard: [vk_space, vk_enter],
            mouse: mb_left
        },
        next_tab: {
            keyboard: [vk_tab]
        },
        prev_tab: {
            keyboard: [vk_tab], // With shift modifier
            requires_shift: true
        }
    };
    
    // Mouse state tracking
    global.input_mouse = {
        x: 0,
        y: 0,
        gui_x: 0,
        gui_y: 0,
        wheel_up: false,
        wheel_down: false,
        clicked: false,
        hover_target: noone
    };
}

// Update input system (call once per step in a manager object)
function update_input_system() {
    // Update mouse coordinates
    global.input_mouse.x = mouse_x;
    global.input_mouse.y = mouse_y;
    global.input_mouse.gui_x = device_mouse_x_to_gui(0);
    global.input_mouse.gui_y = device_mouse_y_to_gui(0);
    
    // Update mouse wheel
    global.input_mouse.wheel_up = mouse_wheel_up();
    global.input_mouse.wheel_down = mouse_wheel_down();
    
    // Update click state
    global.input_mouse.clicked = mouse_check_button_pressed(mb_left);
}

// Check if an input action is triggered
function input_check_pressed(action_name) {
    if (!variable_struct_exists(global.input_bindings, action_name)) {
        return false;
    }
    
    var bindings = variable_struct_get(global.input_bindings, action_name);
    
    // Check keyboard inputs
    if (variable_struct_exists(bindings, "keyboard")) {
        var keys = bindings.keyboard;
        var requires_shift = variable_struct_exists(bindings, "requires_shift") && bindings.requires_shift;
        var shift_held = keyboard_check(vk_shift);
        
        for (var i = 0; i < array_length(keys); i++) {
            if (keyboard_check_pressed(keys[i])) {
                // If requires shift, both shift must be held and this is the right context
                if (requires_shift && shift_held) return true;
                if (!requires_shift && !shift_held) return true;
            }
        }
    }
    
    // Check mouse inputs
    if (variable_struct_exists(bindings, "mouse")) {
        var mouse_btn = bindings.mouse;
        if (mouse_check_button_pressed(mouse_btn)) {
            return true;
        }
    }
    
    // Check mouse wheel
    if (variable_struct_exists(bindings, "mouse_wheel")) {
        var wheel_dir = bindings.mouse_wheel;
        if (wheel_dir == "up" && global.input_mouse.wheel_up) return true;
        if (wheel_dir == "down" && global.input_mouse.wheel_down) return true;
    }
    
    return false;
}

// Check if an input action is held
function input_check_held(action_name) {
    if (!variable_struct_exists(global.input_bindings, action_name)) {
        return false;
    }
    
    var bindings = variable_struct_get(global.input_bindings, action_name);
    
    // Check keyboard inputs
    if (variable_struct_exists(bindings, "keyboard")) {
        var keys = bindings.keyboard;
        for (var i = 0; i < array_length(keys); i++) {
            if (keyboard_check(keys[i])) {
                return true;
            }
        }
    }
    
    // Check mouse inputs
    if (variable_struct_exists(bindings, "mouse")) {
        var mouse_btn = bindings.mouse;
        if (mouse_check_button(mouse_btn)) {
            return true;
        }
    }
    
    return false;
}

// Check if mouse is over a rectangular area (GUI coordinates)
function input_mouse_in_area(x1, y1, x2, y2) {
    var mx = global.input_mouse.gui_x;
    var my = global.input_mouse.gui_y;
    return (mx >= x1 && mx <= x2 && my >= y1 && my <= y2);
}

// Check if mouse clicked in a rectangular area (GUI coordinates)
function input_mouse_clicked_in_area(x1, y1, x2, y2) {
    return input_mouse_in_area(x1, y1, x2, y2) && global.input_mouse.clicked;
}

// Get navigation input as a struct with directional booleans
function input_get_navigation() {
    return {
        up: input_check_pressed("navigate_up"),
        down: input_check_pressed("navigate_down"),
        left: input_check_pressed("navigate_left"),
        right: input_check_pressed("navigate_right"),
        select: input_check_pressed("select"),
        cancel: input_check_pressed("cancel"),
        toggle: input_check_pressed("toggle"),
        next_tab: input_check_pressed("next_tab") && !keyboard_check(vk_shift),
        prev_tab: input_check_pressed("prev_tab") && keyboard_check(vk_shift)
    };
}

// UI Helper: Create clickable area data structure
function create_ui_button(x1, y1, x2, y2, action_callback, hover_callback = undefined) {
    return {
        x1: x1,
        y1: y1, 
        x2: x2,
        y2: y2,
        action_callback: action_callback,
        hover_callback: hover_callback,
        is_hovered: false
    };
}

// UI Helper: Process a list of UI buttons for mouse interaction
function process_ui_buttons(button_array) {
    var any_hovered = false;
    
    for (var i = 0; i < array_length(button_array); i++) {
        var btn = button_array[i];
        var was_hovered = btn.is_hovered;
        btn.is_hovered = input_mouse_in_area(btn.x1, btn.y1, btn.x2, btn.y2);
        
        if (btn.is_hovered) {
            any_hovered = true;
            
            // Hover callback for visual feedback
            if (btn.hover_callback != undefined && !was_hovered) {
                btn.hover_callback();
            }
            
            // Click callback
            if (global.input_mouse.clicked && btn.action_callback != undefined) {
                btn.action_callback();
                return i; // Return index of clicked button
            }
        }
    }
    
    return -1; // No button clicked
}

// UI Helper: Draw button with hover state
function draw_ui_button_with_hover(btn, text, font, normal_color = c_ltgray, hover_color = c_white, selected_color = c_yellow, is_selected = false) {
    draw_set_font(font);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    
    var color = normal_color;
    if (is_selected) {
        color = selected_color;
    } else if (btn.is_hovered) {
        color = hover_color;
    }
    
    draw_set_color(color);
    var center_x = (btn.x1 + btn.x2) / 2;
    var center_y = (btn.y1 + btn.y2) / 2;
    draw_text(center_x, center_y, text);
}