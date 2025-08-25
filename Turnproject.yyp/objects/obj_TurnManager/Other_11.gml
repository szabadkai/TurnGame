//turn decider

if (ds_list_size(turn_list) > 0) {
	var instance = turn_list[| 0];
	
	// Check if the instance still exists before accessing it
	if (instance_exists(instance)) {
		instance.state = TURNSTATE.active;
		
		// Clear defending status at start of turn and update combat stats
		if (variable_instance_exists(instance, "is_defending")) {
			instance.is_defending = false;
			// Update combat stats to recalculate defense score without defending bonus
			if (script_exists(update_combat_stats)) {
				with (instance) {
					update_combat_stats();
				}
			}
		}
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
