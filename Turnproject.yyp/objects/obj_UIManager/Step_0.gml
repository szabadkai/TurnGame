

// Update UI state based on overlay visibility
// This handles cases where UI objects close themselves
if (ui_state == "player_details" && player_details != noone && !player_details.visible) {
    ui_state = "none";
    current_player = noone;
}

if (ui_state == "level_up" && level_up_overlay != noone && !level_up_overlay.visible) {
    ui_state = "none";
    current_player = noone;
}