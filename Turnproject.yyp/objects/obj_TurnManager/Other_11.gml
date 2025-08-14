//turn decider

if (ds_list_size(turn_list) > 0) {
	var instance = turn_list[| 0];
	
	// Check if the instance still exists before accessing it
	if (instance_exists(instance)) {
		instance.state = TURNSTATE.active;
    } else {
        // Remove dead instance from turn list
        ds_list_delete(turn_list, 0);
        show_debug_message("Removed destroyed instance from turn queue");
		
		// Try to activate the next instance
		if (ds_list_size(turn_list) > 0) {
			var next_instance = turn_list[| 0];
			if (instance_exists(next_instance)) {
				next_instance.state = TURNSTATE.active;
			}
		}
	}
}
