// KeyPress Enter - Select scene or choice
// Works in both scene selection and dialog choice modes

if (global.dialog_scene_selection) {
    // Select current scene
    select_current_scene();
} else if (global.dialog_state == 2) { // DialogState.CHOICE_SELECTION
    // Select current choice
    var available_choices = get_available_choices();
    if (array_length(available_choices) > 0 && selected_choice_index >= 0 && selected_choice_index < array_length(available_choices)) {
        select_dialog_choice(available_choices[selected_choice_index]);
    }
} else if (global.dialog_state == 1) { // DialogState.ACTIVE
    // Continue to choices if available, otherwise end
    var current_node = get_current_dialog_node();
    if (current_node != undefined && variable_struct_exists(current_node, "choices")) {
        var available_choices = get_available_choices();
        if (array_length(available_choices) > 0) {
            global.dialog_state = 2; // DialogState.CHOICE_SELECTION
            selected_choice_index = 0;
            choice_count = array_length(available_choices);
        } else {
            end_dialog_scene();
        }
    } else {
        end_dialog_scene();
    }
}