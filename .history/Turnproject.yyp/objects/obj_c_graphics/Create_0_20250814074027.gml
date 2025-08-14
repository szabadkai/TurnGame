//windowed mode setup
window_width = 1280 ;
window_height = 768;
view_width = window_width;
view_height = window_height;

window_set_size(window_width, window_height);
window_set_position(display_get_width()/2 - window_width/2, display_get_height()/2 - window_height/2);
surface_resize(application_surface, view_width, view_height);

//zoom setup
zoom = 5;




