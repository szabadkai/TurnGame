if (ds_list_size(turn_list) > 0) {
	var object = turn_list[| 0];
	ds_list_delete(turn_list, 0);
	ds_list_add(turn_list, object);
	event_user(1);
}
