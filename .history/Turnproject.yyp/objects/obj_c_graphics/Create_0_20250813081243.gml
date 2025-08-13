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
var surf = application_surface;

if (!surface_exists(surf))
{
    surf = surface_create(internal_width, internal_height);
}

surface_set_target(surf);
draw_clear(c_black);

// Draw all your game stuff here
// (You may need to put your actual game drawing in a script for reuse)

surface_reset_target();
var final_w = internal_width  * scale;
var final_h = internal_height * scale;

// Center on screen
var offset_x = (win_w - final_w) div 2;
var offset_y = (win_h - final_h) div 2;

draw_surface_ext(surf, offset_x, offset_y, scale, scale, 0, c_white, 1);

window_set_size(internal_width * scale, internal_height * scale);

//zoom setup
zoom = 1;




