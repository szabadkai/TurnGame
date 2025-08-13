//windowed mode setup
window_width = 320;
window_height = 180;
view_width = window_width;
view_height = window_height;

window_set_size(window_width, window_height);
window_set_position(display_get_width()/2 - window_width/2, display_get_height()/2 - window_height/2);
surface_resize(application_surface, view_width, view_height);

//enable window resizing
window_set_fullscreen(false);
window_set_rectangle(window_get_x(), window_get_y(), window_width, window_height);

//zoom setup
zoom = 3;




