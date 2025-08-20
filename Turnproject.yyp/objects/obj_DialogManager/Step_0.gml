// obj_DialogManager Step Event
// Handle input and state management

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
    if (keyboard_check_pressed(vk_up)) {
        navigate_scene_selection(-1);
    }
    if (keyboard_check_pressed(vk_down)) {
        navigate_scene_selection(1);
    }
    if (keyboard_check_pressed(vk_enter)) {
        select_current_scene();
    }
    if (keyboard_check_pressed(ord("I"))) {
        select_current_scene();
    }
    if (keyboard_check_pressed(vk_escape)) {
        show_debug_message("Exiting scene selection...");
        global.dialog_scene_selection = false;
        global.dialog_state = 0; // DialogState.INACTIVE
        transition_alpha = 0;
        // No other UI is present; immediately transition to Room1 from the dialog room
        if (room == Room_Dialog) {
            show_debug_message("ESC closed selector; transitioning to Room1");
            room_goto(Room1);
            return;
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
        // Navigate choices with arrow keys
        if (keyboard_check_pressed(vk_up)) {
            selected_choice_index = (selected_choice_index - 1 + choice_count) % choice_count;
            show_debug_message("Selected choice: " + string(selected_choice_index));
        }
        if (keyboard_check_pressed(vk_down)) {
            selected_choice_index = (selected_choice_index + 1) % choice_count;
            show_debug_message("Selected choice: " + string(selected_choice_index));
        }
        
        // Select choice with Enter or Space
        if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) {
            select_dialog_choice(choices[selected_choice_index]);
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
            // No choices - advance with Space or Enter
            if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) {
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
        show_debug_message("Exiting dialog...");
        end_dialog_scene();
        transition_alpha = 0;
    }
} else if (!global.dialog_scene_selection && global.dialog_state == 0) {
    // No UI visible (no selection, dialog inactive). If we are in the dialog room,
    // pressing ESC should always transition to Room1.
    if (keyboard_check_pressed(vk_escape) && room == Room_Dialog) {
        show_debug_message("ESC pressed with no UI; transitioning to Room1");
        room_goto(Room1);
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

