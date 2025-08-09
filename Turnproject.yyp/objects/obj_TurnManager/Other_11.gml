//turn decider

if (ds_list_size(turn_list) > 0) {
	var instance = turn_list[| 0];
	
	instance.state = TURNSTATE.active;
}