// obj_DialogManager Step Event
// Handle input and state management

// Initialize input system if not already done
if (!variable_global_exists("input_bindings")) {
    init_input_system();
}

// Update input system
update_input_system();

// Only process if dialog is active
if (global.dialog_state == 0) { // DialogState.INACTIVE
    return;
}

// Debug state changes
if (dialog_debug && keyboard_check_pressed(vk_f1)) {
    show_debug_message("Dialog State: " + string(global.dialog_state));
    show_debug_message("Current Node: " + string(global.current_dialog_node));
    show_debug_message("Current Scene: " + string(global.current_dialog_scene));
}

// Handle transition effects
// Handle ALL input in Step event for better organization
// Scene selection input
if (global.dialog_scene_selection) {
    var nav = input_get_navigation();
    
    // Keyboard navigation
    if (nav.up) {
        navigate_scene_selection(-1);
    }
    if (nav.down) {
        navigate_scene_selection(1);
    }
    if (nav.select) {
        select_current_scene();
    }
    if (keyboard_check_pressed(ord("I"))) {
        select_current_scene();
    }
    if (nav.cancel) {
        show_debug_message("Exiting scene selection...");
        global.dialog_scene_selection = false;
        global.dialog_state = 0; // DialogState.INACTIVE
        transition_alpha = 0;
        // No other UI is present; immediately transition to Room1 from the dialog room
        if (room == Room_Dialog) {
            show_debug_message("ESC closed selector; transitioning to overworld");
            scr_nav_go(GameState.OVERWORLD, undefined);
            return;
        }
    }
    
    // Mouse support for scene selection
    if (global.input_mouse.clicked) {
        var center_x = display_get_gui_width() / 2;
        var center_y = display_get_gui_height() / 2;
        var box_width = 600;
        var box_height = 400;
        var box_x = center_x - box_width / 2;
        var box_y = center_y - box_height / 2;
        var list_start_y = box_y + 60;
        var item_height = 25;
        
        var scene_list = get_scene_list();
        var visible_items = min(12, array_length(scene_list));
        var scroll_offset = max(0, global.selected_scene_index - visible_items + 1);
        
        // Check if clicked on a scene item
        for (var i = 0; i < visible_items; i++) {
            var scene_index = scroll_offset + i;
            if (scene_index >= array_length(scene_list)) break;
            
            var item_y = list_start_y + (i * item_height);
            
            if (input_mouse_clicked_in_area(box_x, item_y, box_x + box_width, item_y + item_height)) {
                global.selected_scene_index = scene_index;
                select_current_scene();
                return;
            }
        }
    }
    
    // Avoid processing dialog logic while in scene selection
    return;
}

// Handle transition effects
if (global.dialog_state == 3) { // DialogState.TRANSITIONING
    transition_alpha = lerp(transition_alpha, 1, transition_speed);
    if (transition_alpha >= 0.95) {
        global.dialog_state = 1; // DialogState.ACTIVE
        transition_alpha = 1;
    }
}

// Handle input for choice selection
if (global.dialog_state == 2) { // DialogState.CHOICE_SELECTION
    var choices = get_available_choices();
    choice_count = array_length(choices);
    
    if (choice_count > 0) {
        var nav = input_get_navigation();
        
        // Navigate choices with arrow keys
        if (nav.up) {
            selected_choice_index = (selected_choice_index - 1 + choice_count) % choice_count;
            show_debug_message("Selected choice: " + string(selected_choice_index));
        }
        if (nav.down) {
            selected_choice_index = (selected_choice_index + 1) % choice_count;
            show_debug_message("Selected choice: " + string(selected_choice_index));
        }
        
        // Select choice with Enter or Space
        if (nav.select) {
            select_dialog_choice(choices[selected_choice_index]);
        }
        
        // Mouse support for choice selection
        if (global.input_mouse.clicked) {
            var dialog_margin = 40;
            var dialog_height = 200;
            var dialog_y = display_get_gui_height() - dialog_height - dialog_margin;
            var text_margin = 20;
            var text_x = dialog_margin + text_margin;
            var choice_start_y = dialog_y + text_margin + 80;
            var choice_spacing = 25;
            
            // Check if clicked on a choice
            for (var i = 0; i < choice_count; i++) {
                var choice_y = choice_start_y + (i * choice_spacing);
                
                if (input_mouse_clicked_in_area(text_x - 20, choice_y - 5, display_get_gui_width() - dialog_margin, choice_y + 20)) {
                    selected_choice_index = i;
                    select_dialog_choice(choices[i]);
                    return;
                }
            }
        }
    }
}

// Handle dialog progression
if (global.dialog_state == 1) { // DialogState.ACTIVE
    var current_node = get_current_dialog_node();
    if (current_node != undefined) {
        // Check if node has choices
        if (variable_struct_exists(current_node, "choices")) {
            var choices = get_available_choices();
            if (array_length(choices) > 0) {
                global.dialog_state = 2; // DialogState.CHOICE_SELECTION
                selected_choice_index = 0;
                choice_count = array_length(choices);
            } else {
                // No valid choices available - check for auto-advance
                if (variable_struct_exists(current_node, "next")) {
                    goto_dialog_node(current_node.next);
                } else {
                    end_dialog_scene();
                }
            }
        } else {
            // No choices - advance with Space, Enter, or mouse click
            var nav = input_get_navigation();
            if (nav.select || global.input_mouse.clicked) {
                if (variable_struct_exists(current_node, "next")) {
                    goto_dialog_node(current_node.next);
                } else {
                    end_dialog_scene();
                }
            }
        }
    }
}

// Handle general input (when dialog is inactive)
if (global.dialog_state == 0) { // DialogState.INACTIVE
    // Start scene selection with I key
    if (keyboard_check_pressed(ord("I"))) {
        show_debug_message("Starting scene selection from main game...");
        start_scene_selection();
    }
}

// Handle ESC for all states (except scene selection which is handled above)
if (!global.dialog_scene_selection && global.dialog_state != 0) {
    if (keyboard_check_pressed(vk_escape)) {
        // Show in-game menu instead of immediately ending dialog
        var existing_menu = instance_find(obj_InGameMenu, 0);
        if (existing_menu == noone) {
            instance_create_layer(0, 0, "Instances", obj_InGameMenu);
        }
    }
} else if (!global.dialog_scene_selection && global.dialog_state == 0) {
    // No UI visible (no selection, dialog inactive). If we are in the dialog room,
    // pressing ESC should show in-game menu.
    if (keyboard_check_pressed(vk_escape) && room == Room_Dialog) {
        var existing_menu = instance_find(obj_InGameMenu, 0);
        if (existing_menu == noone) {
            instance_create_layer(0, 0, "Instances", obj_InGameMenu);
        }
    }
}

// Process delayed effects
process_delayed_effects();

// Debug input
if (dialog_debug) {
    // Press D to start demo dialog }
    
    // Press ESC to end dialog
    if (keyboard_check_pressed(vk_escape)) {
        end_dialog_scene();
    }
}
