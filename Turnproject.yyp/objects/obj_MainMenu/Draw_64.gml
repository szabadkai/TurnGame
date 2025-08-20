// Main Menu Manager - Draw GUI Event

// Set font
draw_set_font(menu_font);
draw_set_halign(fa_center);
draw_set_valign(fa_middle);

// Calculate menu appearance progress
var appear_progress = clamp(menu_appear_timer / menu_appear_duration, 0, 1);
var alpha_mod = appear_progress;

// Apply transition alpha if transitioning
if (menu_state == MENUSTATE.TRANSITION) {
    alpha_mod *= transition_alpha;
}

// Draw background
if (show_promo_background && background_image != noone && sprite_exists(background_image)) {
    // Draw promo background image
    draw_set_alpha(1.0 * alpha_mod);
    draw_set_color(c_white);
    
    // Scale image to fit screen while maintaining aspect ratio
    var screen_w = display_get_gui_width();
    var screen_h = display_get_gui_height();
    var img_w = sprite_get_width(background_image);
    var img_h = sprite_get_height(background_image);
    
    var scale_x = screen_w / img_w;
    var scale_y = screen_h / img_h;
    var scale = max(scale_x, scale_y); // Use larger scale to fill screen
    
    var draw_w = img_w * scale;
    var draw_h = img_h * scale;
    var draw_x = (screen_w - draw_w) / 2;
    var draw_y = (screen_h - draw_h) / 2;
    
    draw_sprite_ext(background_image, 0, draw_x, draw_y, scale, scale, 0, c_white, alpha_mod);
    
    // Add fade-to-black overlay as we approach the transition
    var fade_progress = background_fade_timer / background_fade_duration;
    if (fade_progress > 0.7) {
        var overlay_alpha = (fade_progress - 0.7) / 0.3; // Start fading at 70%
        draw_set_alpha(overlay_alpha * 0.8 * alpha_mod);
        draw_set_color(c_black);
        draw_rectangle(0, 0, screen_w, screen_h, false);
    }
} else {
    // Draw semi-transparent black backdrop
    draw_set_alpha(0.8 * alpha_mod);
    draw_set_color(c_black);
    draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
}

// Draw title with effects
draw_set_alpha(1.0 * alpha_mod);
var title_text = get_menu_title();

// Add title glow effect for main menu
if (menu_state == MENUSTATE.MAIN) {
    // Draw title shadow
    draw_set_color(c_black);
    draw_text(menu_x + 2, menu_y + title_y_offset + 2, title_text);
    
    // Draw title with pulse effect
    var pulse = 0.8 + sin(current_time * 0.003) * 0.2;
    draw_set_color(merge_color(c_white, c_yellow, pulse));
} else {
    draw_set_color(title_color);
}

draw_text(menu_x, menu_y + title_y_offset, title_text);

// Draw menu options
for (var i = 0; i < array_length(current_options); i++) {
    var option_y = menu_y + (i * option_spacing) - ((array_length(current_options) - 1) * option_spacing / 2);
    
    // Set color based on selection and availability
    var option_color = normal_color;
    var option_alpha = alpha_mod;
    
    if (i == selected_option) {
        option_color = selected_color;
        // Add subtle pulse animation for selected option
        var pulse = sin(current_time * 0.01) * 0.2 + 0.8;
        option_alpha *= pulse;
    }
    
    // Check if option should be disabled
    if (is_option_disabled(i)) {
        option_color = disabled_color;
        option_alpha *= 0.5;
    }
    
    draw_set_color(option_color);
    draw_set_alpha(option_alpha);
    
    var option_text = get_option_display_text(i);
    draw_text(menu_x, option_y, option_text);
}

// State-specific drawing
switch (menu_state) {
    case MENUSTATE.SAVE_LOAD:
        draw_save_load_info();
        break;
        
    case MENUSTATE.SETTINGS_AUDIO:
    case MENUSTATE.SETTINGS_GRAPHICS:
    case MENUSTATE.SETTINGS_CONTROLS:
    case MENUSTATE.SETTINGS_GAMEPLAY:
        draw_settings_values();
        break;
}

// Draw instructions at bottom
draw_set_alpha(0.7 * alpha_mod);
draw_set_color(c_ltgray);
draw_set_valign(fa_bottom);
var instructions = get_instruction_text();
draw_text(menu_x, display_get_gui_height() - 10, instructions);

// Reset draw settings
draw_set_alpha(1.0);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);