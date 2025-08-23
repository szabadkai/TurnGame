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

///Return to Main Menu
if (keyboard_check_pressed(vk_f10)) {
  show_debug_message("=== RETURNING TO MAIN MENU ===");
  // Quick save current game state if auto-save is enabled
  if (variable_global_exists("game_settings") && global.game_settings.auto_save) {
    try {
      auto_save_game();
    } catch (e) {
      show_debug_message("Auto-save failed: " + string(e));
    }
  }
  scr_nav_go(GameState.MAIN_MENU, undefined);
}

// camera follow player (center view on first player)
if (variable_instance_exists(id, "cam")) {
  

  // apply zoom by resizing camera view (keep port same size) 
    last_zoom = -1;
  if (zoom != last_zoom) {
    last_zoom = zoom;
    var new_vw = max(16, floor(window_width / zoom));
    var new_vh = max(16, floor(window_height / zoom));
    new_vw -= (new_vw % 16);
    new_vh -= (new_vh % 16);
    camera_set_view_size(cam, new_vw, new_vh);
  }
}
