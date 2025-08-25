// Draw Player Details Overlay on GUI layer
if (!visible || !instance_exists(player_instance)) {
    exit;
}

var player = player_instance;
var viewport_w = display_get_gui_width();
var viewport_h = display_get_gui_height();

// Get TopBar height for proper positioning
var top_bar_height = variable_global_exists("top_bar_height") ? global.top_bar_height : 80;
var top_padding = 10; // Extra space below TopBar

// Calculate panel dimensions and position (positioned below TopBar)
var panel_w = viewport_w - (panel_margin * 2);
var panel_h = viewport_h - (panel_margin * 2) - top_bar_height - top_padding;
var panel_x = panel_margin;
var panel_y = panel_margin + top_bar_height + top_padding;

// Draw semi-transparent background
draw_set_alpha(background_alpha);
draw_rectangle_color(0, 0, viewport_w, viewport_h, c_black, c_black, c_black, c_black, false);
draw_set_alpha(1);

// Draw panel background and border
draw_set_color(c_dkgray);
draw_rectangle(panel_x, panel_y, panel_x + panel_w, panel_y + panel_h, false);
draw_set_color(c_white);
draw_rectangle(panel_x, panel_y, panel_x + panel_w, panel_y + panel_h, true);

// Set up text drawing
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

// Two-column layout setup
var content_margin = 15;
var column_gap = 20;
var left_column_x = panel_x + content_margin;
var left_column_w = floor((panel_w - content_margin * 2 - column_gap) / 2);
var right_column_x = left_column_x + left_column_w + column_gap;
var right_column_w = panel_w - content_margin * 2 - left_column_w - column_gap;

var text_y = panel_y + content_margin;
var left_y = text_y;
var right_y = text_y;

// === TITLE (spans both columns) ===
draw_set_color(c_yellow);
var title_text = "=== PLAYER DETAILS ===";
if (array_length(player_list) > 1) {
    title_text = "=== PLAYER DETAILS (" + string(current_player_index + 1) + "/" + string(array_length(player_list)) + ") ===";
}
draw_text(left_column_x, left_y, title_text);
left_y += line_height + section_spacing;
right_y += line_height + section_spacing;

// Draw column separator line
draw_set_alpha(0.2);
draw_set_color(c_white);
var separator_x = right_column_x - column_gap/2;
draw_line(separator_x, text_y + 30, separator_x, panel_y + panel_h - 100); // Don't draw through title or controls
draw_set_alpha(1);

// === LEFT COLUMN START ===

// === CHARACTER NAME ===
draw_set_color(c_white);
draw_text(left_column_x, left_y, "Character: " + string(player.character_name));

// Show ASI available indicator
if (can_increase_ability_score(player)) {
    draw_set_color(c_yellow);
    draw_text(left_column_x, left_y + line_height, "[ASI AVAILABLE]");
    left_y += line_height;
    draw_set_color(c_white);
}

left_y += line_height + section_spacing;

// === BASIC STATS (LEFT COLUMN) ===
draw_set_color(c_lime);
draw_text(left_column_x, left_y, "BASIC STATS");
left_y += line_height;
draw_set_color(c_white);

draw_text(left_column_x + 20, left_y, "Level: " + string(player.level));
left_y += line_height;
draw_text(left_column_x + 20, left_y, "Experience: " + string(player.xp) + "/" + string(player.xp_to_next_level));
left_y += line_height;
draw_text(left_column_x + 20, left_y, "Proficiency Bonus: +" + string(player.proficiency_bonus));
left_y += line_height;
draw_text(left_column_x + 20, left_y, "Health: " + string(player.hp) + "/" + string(player.max_hp));
left_y += line_height;
draw_text(left_column_x + 20, left_y, "Moves per Turn: " + string(player.max_moves));
left_y += line_height;
draw_text(left_column_x + 20, left_y, "Current Moves: " + string(player.moves));
left_y += line_height + section_spacing;

// === ABILITY SCORES (LEFT COLUMN) ===
draw_set_color(c_lime);
draw_text(left_column_x, left_y, "ABILITY SCORES");
left_y += line_height;
draw_set_color(c_white);

draw_text(left_column_x + 20, left_y, "Strength: " + string(player.strength) + " (" + (player.str_mod >= 0 ? "+" : "") + string(player.str_mod) + ")");
left_y += line_height;
draw_text(left_column_x + 20, left_y, "Dexterity: " + string(player.dexterity) + " (" + (player.dex_mod >= 0 ? "+" : "") + string(player.dex_mod) + ")");
left_y += line_height;
draw_text(left_column_x + 20, left_y, "Constitution: " + string(player.constitution) + " (" + (player.con_mod >= 0 ? "+" : "") + string(player.con_mod) + ")");
left_y += line_height;
draw_text(left_column_x + 20, left_y, "Intelligence: " + string(player.intelligence) + " (" + (player.int_mod >= 0 ? "+" : "") + string(player.int_mod) + ")");
left_y += line_height;
draw_text(left_column_x + 20, left_y, "Wisdom: " + string(player.wisdom) + " (" + (player.wis_mod >= 0 ? "+" : "") + string(player.wis_mod) + ")");
left_y += line_height;
draw_text(left_column_x + 20, left_y, "Charisma: " + string(player.charisma) + " (" + (player.cha_mod >= 0 ? "+" : "") + string(player.cha_mod) + ")");
left_y += line_height + section_spacing;

// === STATUS EFFECTS (LEFT COLUMN) ===
draw_set_color(c_red);
draw_text(left_column_x, left_y, "STATUS EFFECTS");
left_y += line_height;
draw_set_color(c_white);

if (player.frozen_turns > 0) {
    draw_set_color(c_aqua);
    draw_text(left_column_x + 20, left_y, "FROZEN - " + string(player.frozen_turns) + " turns remaining");
    left_y += line_height;
    draw_set_color(c_white);
}

if (player.burn_turns > 0) {
    draw_set_color(c_orange);
    draw_text(left_column_x + 20, left_y, "BURNING - " + string(player.burn_turns) + " turns remaining");
    left_y += line_height;
    draw_set_color(c_white);
}

if (player.frozen_turns == 0 && player.burn_turns == 0) {
    draw_set_color(c_ltgray);
    draw_text(left_column_x + 20, left_y, "No active status effects");
    left_y += line_height;
    draw_set_color(c_white);
}

// === RIGHT COLUMN START ===

// === PORTRAIT (RIGHT COLUMN - larger) ===
var portrait_size = 120; // Larger portrait in right column
var portrait_x1 = right_column_x + 10; // Center it a bit in the right column
var portrait_y1 = right_y;
var portrait_x2 = portrait_x1 + portrait_size;
var portrait_y2 = portrait_y1 + portrait_size;

// Draw portrait frame with subtle shadow
draw_set_alpha(0.3);
draw_set_color(c_black);
draw_rectangle(portrait_x1 + 2, portrait_y1 + 2, portrait_x2 + 2, portrait_y2 + 2, false);
draw_set_alpha(0.8);
draw_set_color(make_color_rgb(20,20,20));
draw_rectangle(portrait_x1, portrait_y1, portrait_x2, portrait_y2, false);
draw_set_alpha(1);
draw_set_color(c_white);
draw_rectangle(portrait_x1, portrait_y1, portrait_x2, portrait_y2, true);

// Resolve and draw portrait sprite if available
var spr_portrait = portraits_get_sprite_for_entity(player);
if (spr_portrait != -1) {
    portraits_draw_fit(spr_portrait, portrait_x1 + 2, portrait_y1 + 2, portrait_x2 - 2, portrait_y2 - 2);
}

right_y += portrait_size + section_spacing;

// === COMBAT STATS (RIGHT COLUMN) ===
draw_set_color(c_lime);
draw_text(right_column_x, right_y, "COMBAT STATS");
right_y += line_height;
draw_set_color(c_white);

// Calculate attack ability modifier based on weapon type
var attack_ability_name = "STR";
var attack_mod = player.str_mod;
if (player.weapon_special_type == "finesse" || player.weapon_special_type == "ranged") {
    attack_ability_name = "DEX";
    attack_mod = player.dex_mod;
}

// Show calculated totals with breakdown
draw_text(right_column_x + 20, right_y, "Attack Bonus: +" + string(player.attack_bonus));
right_y += line_height;
draw_set_color(c_ltgray);
draw_text(right_column_x + 25, right_y, "(Prof:" + string(player.proficiency_bonus) + " + " + attack_ability_name + ":" + (attack_mod >= 0 ? "+" : "") + string(attack_mod) + " + Weapon:" + string(player.weapon_attack_bonus) + ")");
right_y += line_height;

var damage_ability_name = attack_ability_name;  // Same as attack for now
var damage_mod = (attack_ability_name == "DEX") ? player.dex_mod : player.str_mod;

draw_set_color(c_white);
draw_text(right_column_x + 20, right_y, "Damage Modifier: +" + string(player.damage_modifier));
right_y += line_height;
draw_set_color(c_ltgray);
draw_text(right_column_x + 25, right_y, "(" + damage_ability_name + ":" + (damage_mod >= 0 ? "+" : "") + string(damage_mod) + " + Weapon:" + string(player.weapon_damage_modifier) + ")");
right_y += line_height;

draw_set_color(c_white);
draw_text(right_column_x + 20, right_y, "Armor Class: " + string(player.defense_score));
right_y += line_height;
draw_set_color(c_ltgray);
draw_text(right_column_x + 25, right_y, "(Base:" + string(player.base_armor_class) + " + DEX:" + (player.dex_mod >= 0 ? "+" : "") + string(player.dex_mod) + ")");
right_y += line_height + section_spacing;

// === EQUIPPED WEAPON (RIGHT COLUMN) ===
draw_set_color(c_orange);
draw_text(right_column_x, right_y, "EQUIPPED WEAPON");
right_y += line_height;
draw_set_color(c_white);

// Weapon name with cycling buttons
var weapon_name_y = right_y;
draw_text(right_column_x + 20, weapon_name_y, "Name:");

// Previous weapon button
var prev_btn_x = right_column_x + 70;
var prev_btn_y = weapon_name_y;
var button_w = 60;
var button_h = 18;

prev_weapon_button.x = prev_btn_x;
prev_weapon_button.y = prev_btn_y;
prev_weapon_button.w = button_w;
prev_weapon_button.h = button_h;

// Check if mouse is over previous button
var mouse_gui_x = device_mouse_x_to_gui(0);
var mouse_gui_y = device_mouse_y_to_gui(0);
var prev_hover = (mouse_gui_x >= prev_btn_x && mouse_gui_x <= prev_btn_x + button_w &&
                  mouse_gui_y >= prev_btn_y && mouse_gui_y <= prev_btn_y + button_h);

draw_set_color(prev_hover ? c_yellow : c_ltgray);
draw_rectangle(prev_btn_x, prev_btn_y, prev_btn_x + button_w, prev_btn_y + button_h, true);
draw_set_halign(fa_center);
draw_text(prev_btn_x + button_w/2, prev_btn_y, "◀ PREV");
draw_set_halign(fa_left);

// Next weapon button (right after PREV button)
var next_btn_x = prev_btn_x + button_w + 5;
var next_btn_y = weapon_name_y;

next_weapon_button.x = next_btn_x;
next_weapon_button.y = next_btn_y;
next_weapon_button.w = button_w;
next_weapon_button.h = button_h;

// Check if mouse is over next button
var next_hover = (mouse_gui_x >= next_btn_x && mouse_gui_x <= next_btn_x + button_w &&
                  mouse_gui_y >= next_btn_y && mouse_gui_y <= next_btn_y + button_h);

draw_set_color(next_hover ? c_yellow : c_ltgray);
draw_rectangle(next_btn_x, next_btn_y, next_btn_x + button_w, next_btn_y + button_h, true);
draw_set_halign(fa_center);
draw_text(next_btn_x + button_w/2, next_btn_y , "NEXT ▶");
draw_set_halign(fa_left);

// Weapon name (below buttons)
right_y += line_height + 3;
draw_set_color(c_white);
draw_text(right_column_x + 20, right_y, player.weapon_name);
right_y += line_height;

draw_text(right_column_x + 20, right_y, "Damage Dice: " + player.weapon_damage_dice);
right_y += line_height;
draw_text(right_column_x + 20, right_y, "Attack Bonus: +" + string(player.weapon_attack_bonus));
right_y += line_height;
draw_text(right_column_x + 20, right_y, "Damage Bonus: +" + string(player.weapon_damage_modifier));
right_y += line_height;
draw_text(right_column_x + 20, right_y, "Special Type: " + player.weapon_special_type);
right_y += line_height;

// Get weapon description if available
if (player.equipped_weapon_id < array_length(global.weapons)) {
    var weapon_desc = global.weapons[player.equipped_weapon_id].description;
    draw_set_color(c_ltgray);
    draw_text(right_column_x + 20, right_y, "Description: " + weapon_desc);
    right_y += line_height;
    draw_set_color(c_white);
}

right_y += section_spacing;

// === WEAPON ILLUSTRATION ===
var weapon_spr = get_weapon_sprite(player.equipped_weapon_id);
if (weapon_spr != -1) {
    draw_set_color(c_orange);
    draw_text(right_column_x, right_y, "WEAPON ILLUSTRATION");
    right_y += line_height;
    
    // Draw weapon sprite in a rectangular frame matching 128x32 aspect ratio
    var weapon_frame_w = 128;
    var weapon_frame_h = 32;
    var weapon_x1 = right_column_x + 10;
    var weapon_y1 = right_y;
    var weapon_x2 = weapon_x1 + weapon_frame_w;
    var weapon_y2 = weapon_y1 + weapon_frame_h;
    
    // Draw weapon frame with subtle shadow
    draw_set_alpha(0.3);
    draw_set_color(c_black);
    draw_rectangle(weapon_x1 + 2, weapon_y1 + 2, weapon_x2 + 2, weapon_y2 + 2, false);
    draw_set_alpha(0.8);
    draw_set_color(make_color_rgb(30,30,30));
    draw_rectangle(weapon_x1, weapon_y1, weapon_x2, weapon_y2, false);
    draw_set_alpha(1);
    draw_set_color(c_yellow);
    draw_rectangle(weapon_x1, weapon_y1, weapon_x2, weapon_y2, true);
    
    // Draw sprite at original size (assuming it's 128x32)
    var draw_x = weapon_x1 + 2;
    var draw_y = weapon_y1 + 2;
    
    draw_sprite(weapon_spr, 0, draw_x, draw_y);
    
    right_y += weapon_frame_h + section_spacing;
}


// === CONTROLS (bottom, spans both columns) ===
var controls_y = panel_y + panel_h - 80;
draw_set_color(c_yellow);
draw_text(left_column_x, controls_y, "CONTROLS:");
draw_set_color(c_white);
draw_text(left_column_x, controls_y + 15, "ESC - Close this window");
draw_text(left_column_x, controls_y + 30, "Click PREV/NEXT buttons - Change weapons");
draw_text(left_column_x, controls_y + 45, "0-9, - (during combat) - Quick weapon switch");
if (array_length(player_list) > 1) {
    draw_set_color(c_ltgray);
    draw_text(left_column_x, controls_y + 60, "← → - Switch between players");
}

// Reset drawing settings
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);
