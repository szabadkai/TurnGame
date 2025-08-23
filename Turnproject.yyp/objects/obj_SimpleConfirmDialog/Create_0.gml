// Simple Confirmation Dialog - Minimal version for testing

show_visible = false;
show_alpha = 0;
target_alpha = 0;

dialog_width = 300;
dialog_height = 150;
dialog_x = 0;
dialog_y = 0;

system_name = "";
confirm_callback = -1;
cancel_callback = -1;

show_debug_message("Simple confirmation dialog created");

function show_confirmation(name, confirm_cb, cancel_cb) {
    show_visible = true;
    target_alpha = 1;
    system_name = name;
    confirm_callback = confirm_cb;
    cancel_callback = cancel_cb;
    
    dialog_x = (display_get_gui_width() - dialog_width) / 2;
    dialog_y = (display_get_gui_height() - dialog_height) / 2;
    
    show_debug_message("Showing simple confirmation for: " + name);
}

function hide_confirmation() {
    target_alpha = 0;
    show_debug_message("Hiding simple confirmation");
}