// Internal resolution
internal_width  = 320;
internal_height = 180;

// Get the current window size
win_w = window_get_width();
win_h = window_get_height();

// Figure out how many times the internal size can fit (integer scale)
scale_x = floor(win_w / internal_width);
scale_y = floor(win_h / internal_height);
scale   = min(scale_x, scale_y); // Keep aspect ratio



window_set_size(window_width, window_height);
window_set_position(display_get_width()/2 - window_width/2, display_get_height()/2 - window_height/2);
surface_resize(application_surface, view_width, view_height);

//zoom setup
zoom = 1;




