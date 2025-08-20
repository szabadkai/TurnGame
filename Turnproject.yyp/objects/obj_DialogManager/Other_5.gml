// obj_DialogManager Room End Event
// Clean up dialog UI and resources when leaving the room

show_debug_message("DialogManager Room End - cleaning up");

// Stop scene selection UI
global.dialog_scene_selection = false;
global.selected_scene_index = 0;

// Reset dialog state
global.dialog_state = 0;
global.current_dialog_scene = undefined;
global.current_dialog_node = undefined;

// Free any dynamically loaded scene sprite
if (global.current_scene_image != noone && sprite_exists(global.current_scene_image)) {
    sprite_delete(global.current_scene_image);
    global.current_scene_image = noone;
}

show_debug_message("DialogManager cleaned up on room end");