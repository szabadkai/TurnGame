// obj_TooltipManager Step Event
// Update tooltip animation and position

// Update fade animation
tooltip_alpha = lerp(tooltip_alpha, tooltip_target_alpha, fade_speed);

// Hide tooltip when fully faded
if (tooltip_target_alpha == 0 && tooltip_alpha < 0.01) {
    tooltip_visible = false;
    tooltip_alpha = 0;
}

// Update tooltip position if following mouse
if (tooltip_visible) {
    update_tooltip_position();
}