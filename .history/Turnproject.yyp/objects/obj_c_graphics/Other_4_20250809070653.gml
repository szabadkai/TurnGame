//enable graphics, camera, sets it to view size and to middle
view_enabled = true;
view_visible[0] = true;
camera_set_view_size(view_camera[0], view_width/zoom, view_height/zoom);
camera_set_view_pos(view_camera[0], ((room_width)/2-(view_width/zoom)/2), ((room_height)/2-((view_height)/zoom)/2));
