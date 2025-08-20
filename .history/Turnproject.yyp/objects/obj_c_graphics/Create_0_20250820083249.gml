//windowed mode setup
window_width = 160*7 ;
window_height = 90*7;
view_width = window_width;
view_height = window_height;
last_zoom = 7
window_set_size(window_width, window_height);
window_set_position(display_get_width()/2 - window_width/2, display_get_height()/2 - window_height/2);
surface_resize(application_surface, view_width, view_height);

//zoom setup
zoom = 6;
zoom_min = 1;
zoom_max = 12;

// camera setup (world zoom without affecting GUI)
var vw = max(16, floor(window_width / zoom));
var vh = max(16, floor(window_height / zoom));
vw -= (vw % 16);
vh -= (vh % 16);

cam = camera_create_view(0, 0, vw, vh, 0, noone, -1, -1, -1, -1);
view_enabled = true;
view_set_visible(0, true);
view_set_wport(0, window_width);
view_set_hport(0, window_height);
view_set_camera(0, cam);

// keep GUI at full resolution for crisp UI
display_set_gui_size(window_width, window_height);


