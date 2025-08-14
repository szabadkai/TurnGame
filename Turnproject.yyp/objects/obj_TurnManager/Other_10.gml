if (ds_list_size(turn_list) > 0) {
	var object = turn_list[| 0];
	ds_list_delete(turn_list, 0);
	
	// Only add back to list if the instance still exists
	if (instance_exists(object)) {
		ds_list_add(turn_list, object);
    } else {
        show_debug_message("Skipping destroyed instance in turn rotation");
    }
	
	event_user(1);
}
