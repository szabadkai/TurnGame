///Fullscreen
if (keyboard_check(vk_alt) && keyboard_check_released(vk_enter)) {
	if (window_get_fullscreen()) {
		window_set_fullscreen(false)
	}
	else {
		window_set_fullscreen(true);
	}
}

///Resolution
if (keyboard_check_released(vk_up)) {
	if (window_height = 720) {
		window_width = 1920
		window_height = 1080
	}
		else if (window_height = 1080) {
		window_width = 320
		window_height = 360
	}
		else if (window_height = 360) {
		window_width = 1280
		window_height = 720
	}
	window_set_size(window_width, window_height);
	window_set_position(display_get_width()/2 - window_width/2, display_get_height()/2 - window_height/2);
}

///Restart Game
if (keyboard_check_pressed(ord("R"))) {
	if (variable_global_exists("combat_log")) global.combat_log("=== GAME RESTART ===");
	game_restart();
}