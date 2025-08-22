// obj_CombatResultsUI Step Event
// Handle UI interactions and animations

if (!ui_visible) return;

// Update alpha animation
ui_alpha = lerp(ui_alpha, target_alpha, fade_speed);

// If fading out and nearly invisible, hide completely
if (target_alpha == 0 && ui_alpha < 0.05) {
    ui_visible = false;
    ui_alpha = 0;
}

// Check button hover state
button_hover = is_mouse_over_button();

// Handle button click
if (button_hover && mouse_check_button_pressed(mb_left)) {
    handle_return_button();
}

// Handle keyboard shortcuts
if (keyboard_check_pressed(vk_enter) || keyboard_check_pressed(vk_space)) {
    handle_return_button();
}

if (keyboard_check_pressed(vk_escape)) {
    handle_return_button();
}