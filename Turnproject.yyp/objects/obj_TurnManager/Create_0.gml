randomize();

//create turn list
turn_list = ds_list_create();

//creating a list -objects- adding all instance numbers of character_base
var objects = ds_list_create();
for (var i = 0; i < instance_number(character_base); i++) {
	ds_list_add(objects, instance_find(character_base, i))
}

while (ds_list_size(objects) > 0) {
	ds_list_shuffle(objects);
	ds_list_add(turn_list, objects[| 0]);
	ds_list_delete(objects, 0)
}

ds_list_destroy(objects);

// === DIALOG SYSTEM INITIALIZATION ===
// Initialize enums and dialog system early in game startup
scr_enums();
init_dialog_system();
init_dialog_state();

// === STAR MAP SYSTEM INITIALIZATION ===
// Initialize star map system early in game startup
init_star_map();

// === UI SYSTEM FAILSAFE ===
// Force create UI objects if they don't exist - TurnManager runs early so this ensures UI is available
alarm[1] = 5;  // Wait a few steps then force create UI objects

// === SAVE SYSTEM ===
// Apply loaded save data if we're loading a game
if (variable_global_exists("loading_save") && global.loading_save) {
    alarm[2] = 10; // Apply save data after UI is created
}
