// Draw Level Up Overlay on GUI layer
if (!visible || !instance_exists(player_instance)) {
    exit;
}

var player = player_instance;
var viewport_w = display_get_gui_width();
var viewport_h = display_get_gui_height();

// Calculate panel dimensions and position
var panel_w = viewport_w - (panel_margin * 2);
var panel_h = viewport_h - (panel_margin * 2);
var panel_x = panel_margin;
var panel_y = panel_margin;

// Draw semi-transparent background
draw_set_alpha(background_alpha);
draw_rectangle_color(0, 0, viewport_w, viewport_h, c_black, c_black, c_black, c_black, false);
draw_set_alpha(1);

// Draw panel background and border
draw_set_color(c_dkgray);
draw_rectangle(panel_x, panel_y, panel_x + panel_w, panel_y + panel_h, false);
draw_set_color(c_yellow);
draw_rectangle(panel_x, panel_y, panel_x + panel_w, panel_y + panel_h, true);

// Set up text drawing
draw_set_color(c_yellow);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

var text_x = panel_x + 20;
var text_y = panel_y + 20;
var current_y = text_y;

// === TITLE ===
draw_text(text_x, current_y, "=== LEVEL " + string(player.level) + " - ABILITY SCORE IMPROVEMENT ===");
current_y += line_height + 10;

draw_set_color(c_white);
draw_text(text_x, current_y, "Character: " + string(player.character_name));
current_y += line_height;
draw_text(text_x, current_y, "Points Remaining: " + string(asi_points_remaining));
current_y += line_height + section_spacing;

draw_set_color(c_ltgray);
draw_text(text_x, current_y, "Distribute 2 points among your abilities. You may increase one ability by +2 or two abilities by +1 each.");
current_y += line_height * 2 + section_spacing;

// === ABILITY SCORES ===
draw_set_color(c_lime);
draw_text(text_x, current_y, "ABILITY SCORES");
current_y += line_height + 5;

var abilities = ["strength", "dexterity", "constitution", "intelligence", "wisdom", "charisma"];
var ability_names = ["Strength", "Dexterity", "Constitution", "Intelligence", "Wisdom", "Charisma"];

for (var i = 0; i < array_length(abilities); i++) {
    var ability = abilities[i];
    var ability_display = ability_names[i];
    var current_score = variable_instance_get(player, ability);
    var planned_increase = variable_struct_get(asi_selections, ability);
    var new_score = current_score + planned_increase;
    
    draw_set_color(c_white);
    var display_text = ability_display + ": " + string(current_score);
    if (planned_increase > 0) {
        display_text += " -> " + string(new_score);
        draw_set_color(c_yellow);
    }
    draw_text(text_x, current_y, display_text);
    
    // Draw buttons
    for (var j = 0; j < array_length(buttons); j++) {
        var btn = buttons[j];
        if (btn.ability == ability) {
            var btn_color = c_gray;
            var btn_text_color = c_white;
            var btn_text = "";
            
            if (btn.type == "plus") {
                btn_text = "+";
                // Enable if we have points and can increase this ability
                if (asi_points_remaining > 0 && planned_increase < 2 && new_score < 20) {
                    btn_color = c_green;
                    btn_text_color = c_white;
                } else {
                    btn_color = c_dkgray;
                    btn_text_color = c_gray;
                }
            } else if (btn.type == "minus") {
                btn_text = "-";
                if (planned_increase > 0) {
                    btn_color = c_red;
                    btn_text_color = c_white;
                } else {
                    btn_color = c_dkgray;
                    btn_text_color = c_gray;
                }
            }
            
            // Draw button
            draw_set_color(btn_color);
            draw_rectangle(btn.x, btn.y, btn.x + btn.w, btn.y + btn.h, false);
            draw_set_color(c_white);
            draw_rectangle(btn.x, btn.y, btn.x + btn.w, btn.y + btn.h, true);
            
            // Draw button text
            draw_set_color(btn_text_color);
            draw_set_halign(fa_center);
            draw_set_valign(fa_middle);
            draw_text(btn.x + btn.w/2, btn.y + btn.h/2, btn_text);
            draw_set_halign(fa_left);
            draw_set_valign(fa_top);
        }
    }
    
    current_y += line_height + 5;
}

// Draw confirm button
for (var i = 0; i < array_length(buttons); i++) {
    var btn = buttons[i];
    if (btn.type == "confirm") {
        var btn_color = (asi_points_remaining == 0) ? c_green : c_dkgray;
        var btn_text_color = (asi_points_remaining == 0) ? c_white : c_gray;
        
        draw_set_color(btn_color);
        draw_rectangle(btn.x, btn.y, btn.x + btn.w, btn.y + btn.h, false);
        draw_set_color(c_white);
        draw_rectangle(btn.x, btn.y, btn.x + btn.w, btn.y + btn.h, true);
        
        draw_set_color(btn_text_color);
        draw_set_halign(fa_center);
        draw_set_valign(fa_middle);
        draw_text(btn.x + btn.w/2, btn.y + btn.h/2, "CONFIRM");
        draw_set_halign(fa_left);
        draw_set_valign(fa_top);
        break;
    }
}

// Instructions
draw_set_color(c_yellow);
draw_text(text_x, viewport_h - 60, "CONTROLS:");
draw_set_color(c_white);
draw_text(text_x, viewport_h - 40, "Click + and - buttons to allocate points");
draw_text(text_x, viewport_h - 25, "ESC - Cancel (forfeit improvements)  |  Click CONFIRM when done");

// Reset drawing settings
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);