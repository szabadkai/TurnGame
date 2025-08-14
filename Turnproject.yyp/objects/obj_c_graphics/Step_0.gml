///Fullscreen
if (keyboard_check(vk_alt) && keyboard_check_released(vk_enter)) {
	if (window_get_fullscreen()) {
		window_set_fullscreen(false)
	}
	else {
		window_set_fullscreen(true);
	}
}

///Restart Game
if (keyboard_check_pressed(ord("R"))) {
	show_debug_message("=== GAME RESTART ===");
	game_restart();
}
