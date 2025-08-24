// Player Details Overlay
visible = false;
player_instance = noone;

// Player navigation
player_list = [];
current_player_index = 0;

// UI Settings
background_alpha = 0.8;
panel_margin = 20;
line_height = 16;
section_spacing = 8;

// Weapon navigation buttons
prev_weapon_button = { x: 0, y: 0, w: 0, h: 0 };
next_weapon_button = { x: 0, y: 0, w: 0, h: 0 };

// Function to build/refresh player list
function refresh_player_list() {
    player_list = [];
    for (var i = 0; i < instance_number(obj_Player); i++) {
        player_list[i] = instance_find(obj_Player, i);
    }
}