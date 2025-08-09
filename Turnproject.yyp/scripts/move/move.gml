function move(_up_down_left_right){
if (_up_down_left_right = 0) {
		is_animating = true;
		vspeed = -obj_c_turn.spd;
		image_index = 0
		alarm[0] = obj_c_turn.turn_lenght;
	}
if (_up_down_left_right = 1) {
		is_animating = true;
		vspeed = obj_c_turn.spd;
		image_index = 1
		alarm[0] = obj_c_turn.turn_lenght;
	}
if (_up_down_left_right = 2) {
		is_animating = true;
		hspeed = -obj_c_turn.spd;
		image_index = 2
		alarm[0] = obj_c_turn.turn_lenght;
	}
if (_up_down_left_right = 3) {
		is_animating = true;
		hspeed = obj_c_turn.spd;
		image_index = 3
		alarm[0] = obj_c_turn.turn_lenght;
	}
}