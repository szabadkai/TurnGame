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
// Handle scene selection input here too (fallback to ensure navigation works)
if (global.dialog_scene_selection) {
    if (keyboard_check_pressed(vk_up)) {
        navigate_scene_selection(-1);
    }
    if (keyboard_check_pressed(vk_down)) {
        navigate_scene_selection(1);
    }
    // Select with Enter only to avoid instantly selecting when opening with 'I'
    if (keyboard_check_pressed(vk_enter)) {
        select_current_scene();
    }
    if (keyboard_check_pressed(vk_escape)) {
        show_debug_message("Exiting scene selection...");
        global.dialog_scene_selection = false;
        global.dialog_state = 0; // DialogState.INACTIVE
        transition_alpha = 0;
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
        }
        if (keyboard_check_pressed(vk_down)) {
            selected_choice_index = (selected_choice_index + 1) % choice_count;
        }
        
        // Select choice with Enter or Space
        if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) {
            select_choice(selected_choice_index);
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

// Process delayed effects
process_delayed_effects();

// Debug input
if (dialog_debug) {
    // Press D to start demo dialog
    if (keyboard_check_pressed(ord("D"))) {
        start_demo_dialog();
    }
    
    // Press ESC to end dialog
    if (keyboard_check_pressed(vk_escape)) {
        end_dialog_scene();
    }
}

// Function to select a choice
function select_choice(choice_index) {
    var choices = get_available_choices();
    if (choice_index >= 0 && choice_index < array_length(choices)) {
        select_dialog_choice(choices[choice_index]);
        global.dialog_state = 3; // DialogState.TRANSITIONING
        transition_alpha = 0;
    }
}
