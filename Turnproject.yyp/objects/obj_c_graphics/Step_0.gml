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

// camera follow player (center view on first player)
if (variable_instance_exists(id, "cam")) {
  var p = noone;
  if (instance_number(obj_Player) > 0) {
    p = instance_find(obj_Player, 0);
  }
  if (instance_exists(p)) {
    var vw = camera_get_view_width(cam);
    var vh = camera_get_view_height(cam);
    var cx = clamp(round(p.x - vw * 0.5), 0, max(0, room_width - vw));
    var cy = clamp(round(p.y - vh * 0.5), 0, max(0, room_height - vh));
    camera_set_view_pos(cam, cx, cy);
  }

  // zoom controls
  if (keyboard_check_pressed(vk_add) || keyboard_check_pressed(ord("E"))) {
    zoom = clamp(zoom + 1, zoom_min, zoom_max);
  }
  if (keyboard_check_pressed(vk_subtract) || keyboard_check_pressed(ord("Q"))) {
    zoom = clamp(zoom - 1, zoom_min, zoom_max);
  }

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
