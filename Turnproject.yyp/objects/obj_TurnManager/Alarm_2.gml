// TurnManager Alarm[2] - Apply loaded save data

apply_loaded_save_data();

// Rebuild turn list after loading
if (ds_exists(turn_list, ds_type_list)) {
    ds_list_destroy(turn_list);
}

turn_list = ds_list_create();

// Recreate turn list with loaded characters
var objects = ds_list_create();
for (var i = 0; i < instance_number(character_base); i++) {
    ds_list_add(objects, instance_find(character_base, i));
}

while (ds_list_size(objects) > 0) {
    ds_list_shuffle(objects);
    ds_list_add(turn_list, objects[| 0]);
    ds_list_delete(objects, 0);
}

ds_list_destroy(objects);

show_debug_message("Turn system rebuilt after loading save data");