// Main Menu Manager - Destroy Event

// Clean up background image
if (background_image != noone && sprite_exists(background_image)) {
    sprite_delete(background_image);
    background_image = noone;
}

show_debug_message("Main Menu Manager destroyed");