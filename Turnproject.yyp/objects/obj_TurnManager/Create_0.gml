randomize();

//create turn list
turn_list = ds_list_create();

//creating a list -objects- adding all instance numbers of obj_Statable
var objects = ds_list_create();
for (var i = 0; i < instance_number(obj_Statable); i++) {
	ds_list_add(objects, instance_find(obj_Statable, i))
}

while (ds_list_size(objects) > 0) {
	ds_list_shuffle(objects);
	ds_list_add(turn_list, objects[| 0]);
	ds_list_delete(objects, 0)
}

ds_list_destroy(objects);
