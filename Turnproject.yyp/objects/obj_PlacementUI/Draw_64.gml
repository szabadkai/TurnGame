// obj_PlacementUI Draw GUI Event
// Enhanced visual feedback for Heroes 3 style placement system (no overlays)

if (!placement_active || array_length(crew_to_place) == 0) return;

// Check if TopBar is handling placement display (resolve object safely)
var obj_topbar_index = asset_get_index("obj_TopBar");
if (obj_topbar_index != -1) {
    var top_bar = instance_find(obj_topbar_index, 0);
    if (top_bar != noone && variable_instance_exists(top_bar, "current_mode") && top_bar.current_mode == TOPBAR_MODE.PLACEMENT_MODE) {
        // TopBar is showing placement info, don't draw our own panel
        return;
    }
}
// If no TopBar found or not in placement mode, draw our compact panel


// Enhanced instruction panel with Heroes 3 style
draw_set_alpha(0.9);
draw_set_color(c_black);
draw_rectangle(10, 10, 320, 90, false);

// Draw panel border with gradient effect
draw_set_alpha(1.0);
draw_set_color(c_yellow);
draw_rectangle(10, 10, 320, 90, true);
draw_set_color(c_orange);
draw_rectangle(11, 11, 319, 89, true);

// Enhanced instruction text with battle grid info
draw_set_halign(fa_left);
draw_set_valign(fa_top);
draw_set_color(c_white);

var instruction_text = "";
if (current_character_index < array_length(crew_to_place)) {
    var current_char = crew_to_place[current_character_index];
    if (!current_char.placed) {
        instruction_text = "Place: " + current_char.crew_member.full_name;
    } else {
        var grid_pos = pixel_to_grid(current_char.final_x, current_char.final_y);
        instruction_text = "Selected: " + current_char.crew_member.full_name + " [" + string(grid_pos.x) + "," + string(grid_pos.y) + "]";
    }
} else {
    instruction_text = "All characters positioned on battle grid";
}

draw_text(15, 15, instruction_text);
draw_set_color(c_ltgray);
draw_text(15, 28, "• Click grid cell to place character");
draw_text(15, 40, "• WASD/Arrows to move on grid");
draw_text(15, 52, "• Tab to switch characters");

if (placement_completed) {
    draw_set_color(c_lime);
    var flash_alpha = 0.5 + 0.5 * sin(current_time * 0.01);
    draw_set_alpha(flash_alpha);
    draw_text(15, 68, ">> Press ENTER to start battle! <<");
    draw_set_alpha(1.0);
} else {
    var placed_count = 0;
    for (var i = 0; i < array_length(crew_to_place); i++) {
        if (crew_to_place[i].placed) placed_count++;
    }
    draw_set_color(c_yellow);
    draw_text(15, 68, "Arena: " + string(placed_count) + "/" + string(array_length(crew_to_place)) + " placed (" + string(player_cols) + "x" + string(battle_grid_rows) + " grid)");
}

// Reset draw settings
draw_set_alpha(1.0);
draw_set_color(c_white);
draw_set_halign(fa_left);
draw_set_valign(fa_top);
