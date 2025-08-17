// Draw Player Details Overlay on GUI layer
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
draw_set_color(c_white);
draw_rectangle(panel_x, panel_y, panel_x + panel_w, panel_y + panel_h, true);

// Set up text drawing
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);

var text_x = panel_x + 15;
var text_y = panel_y + 15;
var current_y = text_y;

// === TITLE ===
draw_set_color(c_yellow);
var title_text = "=== PLAYER DETAILS ===";
if (array_length(player_list) > 1) {
    title_text = "=== PLAYER DETAILS (" + string(current_player_index + 1) + "/" + string(array_length(player_list)) + ") ===";
}
draw_text(text_x, current_y, title_text);
current_y += line_height;

// === CHARACTER NAME ===
draw_set_color(c_white);
draw_text(text_x, current_y, "Character: " + string(player.character_name));

// Show ASI available indicator
if (can_increase_ability_score(player)) {
    draw_set_color(c_yellow);
    draw_text(text_x + 200, current_y, "[ASI AVAILABLE]");
    draw_set_color(c_white);
}

current_y += line_height + section_spacing;

// === BASIC STATS ===
draw_set_color(c_lime);
draw_text(text_x, current_y, "BASIC STATS");
current_y += line_height;
draw_set_color(c_white);

draw_text(text_x + 20, current_y, "Level: " + string(player.level));
current_y += line_height;
draw_text(text_x + 20, current_y, "Experience: " + string(player.xp) + "/" + string(player.xp_to_next_level));
current_y += line_height;
draw_text(text_x + 20, current_y, "Proficiency Bonus: +" + string(player.proficiency_bonus));
current_y += line_height;
draw_text(text_x + 20, current_y, "Health: " + string(player.hp) + "/" + string(player.max_hp));
current_y += line_height;
draw_text(text_x + 20, current_y, "Moves per Turn: " + string(player.max_moves));
current_y += line_height;
draw_text(text_x + 20, current_y, "Current Moves: " + string(player.moves));
current_y += line_height + section_spacing;

// === ABILITY SCORES ===
draw_set_color(c_lime);
draw_text(text_x, current_y, "ABILITY SCORES");
current_y += line_height;
draw_set_color(c_white);

draw_text(text_x + 20, current_y, "Strength: " + string(player.strength) + " (" + (player.str_mod >= 0 ? "+" : "") + string(player.str_mod) + ")");
current_y += line_height;
draw_text(text_x + 20, current_y, "Dexterity: " + string(player.dexterity) + " (" + (player.dex_mod >= 0 ? "+" : "") + string(player.dex_mod) + ")");
current_y += line_height;
draw_text(text_x + 20, current_y, "Constitution: " + string(player.constitution) + " (" + (player.con_mod >= 0 ? "+" : "") + string(player.con_mod) + ")");
current_y += line_height;
draw_text(text_x + 20, current_y, "Intelligence: " + string(player.intelligence) + " (" + (player.int_mod >= 0 ? "+" : "") + string(player.int_mod) + ")");
current_y += line_height;
draw_text(text_x + 20, current_y, "Wisdom: " + string(player.wisdom) + " (" + (player.wis_mod >= 0 ? "+" : "") + string(player.wis_mod) + ")");
current_y += line_height;
draw_text(text_x + 20, current_y, "Charisma: " + string(player.charisma) + " (" + (player.cha_mod >= 0 ? "+" : "") + string(player.cha_mod) + ")");
current_y += line_height + section_spacing;

// === COMBAT STATS ===
draw_set_color(c_lime);
draw_text(text_x, current_y, "COMBAT STATS");
current_y += line_height;
draw_set_color(c_white);

// Calculate attack ability modifier based on weapon type
var attack_ability_name = "STR";
var attack_mod = player.str_mod;
if (player.weapon_special_type == "finesse" || player.weapon_special_type == "ranged" || player.weapon_name == "Rapier") {
    attack_ability_name = "DEX";
    attack_mod = player.dex_mod;
}

// Show calculated totals with breakdown
draw_text(text_x + 20, current_y, "Attack Bonus: +" + string(player.attack_bonus) + " (Prof:" + string(player.proficiency_bonus) + " + " + attack_ability_name + ":" + (attack_mod >= 0 ? "+" : "") + string(attack_mod) + " + Weapon:" + string(player.weapon_attack_bonus) + ")");
current_y += line_height;

var damage_ability_name = attack_ability_name;  // Same as attack for now
var damage_mod = (attack_ability_name == "DEX") ? player.dex_mod : player.str_mod;

draw_text(text_x + 20, current_y, "Damage Modifier: +" + string(player.damage_modifier) + " (" + damage_ability_name + ":" + (damage_mod >= 0 ? "+" : "") + string(damage_mod) + " + Weapon:" + string(player.weapon_damage_modifier) + ")");
current_y += line_height;

draw_text(text_x + 20, current_y, "Armor Class: " + string(player.defense_score) + " (Base:" + string(player.base_armor_class) + " + DEX:" + (player.dex_mod >= 0 ? "+" : "") + string(player.dex_mod) + ")");
current_y += line_height + section_spacing;

// === EQUIPPED WEAPON ===
draw_set_color(c_orange);
draw_text(text_x, current_y, "EQUIPPED WEAPON");
current_y += line_height;
draw_set_color(c_white);

// Weapon name with cycling buttons
var weapon_name_y = current_y;
draw_text(text_x + 20, weapon_name_y, "Name:");

// Store button positions for click detection
if (!variable_instance_exists(id, "prev_weapon_button")) {
    prev_weapon_button = { x: 0, y: 0, w: 0, h: 0 };
    next_weapon_button = { x: 0, y: 0, w: 0, h: 0 };
}

// Previous weapon button
var prev_btn_x = text_x + 80;
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

// Weapon name
draw_set_color(c_white);
draw_text(text_x + 150, weapon_name_y, player.weapon_name);

// Next weapon button  
var next_btn_x = text_x + 250 + string_width(player.weapon_name);
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
draw_set_color(c_white);
current_y += line_height;
draw_text(text_x + 20, current_y, "Damage Dice: " + player.weapon_damage_dice);
current_y += line_height;
draw_text(text_x + 20, current_y, "Attack Bonus: +" + string(player.weapon_attack_bonus));
current_y += line_height;
draw_text(text_x + 20, current_y, "Damage Bonus: +" + string(player.weapon_damage_modifier));
current_y += line_height;
draw_text(text_x + 20, current_y, "Special Type: " + player.weapon_special_type);
current_y += line_height;

// Get weapon description if available
if (player.equipped_weapon_id < array_length(global.weapons)) {
    var weapon_desc = global.weapons[player.equipped_weapon_id].description;
    draw_set_color(c_ltgray);
    draw_text(text_x + 20, current_y, "Description: " + weapon_desc);
    current_y += line_height;
    draw_set_color(c_white);
}
current_y += section_spacing;

// === STATUS EFFECTS ===
draw_set_color(c_red);
draw_text(text_x, current_y, "STATUS EFFECTS");
current_y += line_height;
draw_set_color(c_white);

if (player.frozen_turns > 0) {
    draw_set_color(c_ltblue);
    draw_text(text_x + 20, current_y, "FROZEN - " + string(player.frozen_turns) + " turns remaining");
    current_y += line_height;
    draw_set_color(c_white);
}

if (player.burn_turns > 0) {
    draw_set_color(c_orange);
    draw_text(text_x + 20, current_y, "BURNING - " + string(player.burn_turns) + " turns remaining");
    current_y += line_height;
    draw_set_color(c_white);
}

if (player.frozen_turns == 0 && player.burn_turns == 0) {
    draw_set_color(c_ltgray);
    draw_text(text_x + 20, current_y, "No active status effects");
    current_y += line_height;
    draw_set_color(c_white);
}

// === CONTROLS ===
draw_set_color(c_yellow);
draw_text(text_x, viewport_h - 90, "CONTROLS:");
draw_set_color(c_white);
draw_text(text_x, viewport_h - 75, "ESC - Close this window");
draw_text(text_x, viewport_h - 60, "Click PREV/NEXT buttons - Change weapons");
draw_text(text_x, viewport_h - 45, "0-9, - (during combat) - Quick weapon switch");
if (array_length(player_list) > 1) {
    draw_set_color(c_ltgray);
    draw_text(text_x, viewport_h - 30, "← → - Switch between players");
}

// Reset drawing settings
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);