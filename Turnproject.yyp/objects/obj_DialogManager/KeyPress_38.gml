// KeyPress Up Arrow - Navigate scene selection up
// Also works for dialog choice navigation

if (global.dialog_scene_selection) {
    navigate_scene_selection(-1);
} else if (global.dialog_state == 2) { // DialogState.CHOICE_SELECTION
    // Navigate dialog choices
    var available_choices = get_available_choices();
    if (array_length(available_choices) > 0) {
        selected_choice_index--;
        if (selected_choice_index < 0) {
            selected_choice_index = array_length(available_choices) - 1;
        }
        show_debug_message("Selected choice: " + string(selected_choice_index));
    }
}