// obj_DialogManager Draw GUI Event
// Handle dialog UI rendering

// Only draw if dialog is active or scene selection is active
if (global.dialog_state == 0 && !global.dialog_scene_selection) { // DialogState.INACTIVE and not selecting scenes
    return;
}

// Apply transition alpha
draw_set_alpha(transition_alpha);

// Draw scene selection if active
if (global.dialog_scene_selection) {
    // Draw background
    var bg_color = c_black;
    draw_set_color(bg_color);
    draw_set_alpha(0.8 * transition_alpha);
    draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
    draw_set_alpha(transition_alpha);
    
    // Scene selection properties
    var scene_list = get_scene_list();
    var center_x = display_get_gui_width() / 2;
    var center_y = display_get_gui_height() / 2;
    var box_width = 600;
    var box_height = 400;
    var box_x = center_x - box_width / 2;
    var box_y = center_y - box_height / 2;
    
    // Draw selection box
    draw_set_color(c_dkgray);
    draw_rectangle(box_x, box_y, box_x + box_width, box_y + box_height, false);
    draw_set_color(c_white);
    draw_rectangle(box_x, box_y, box_x + box_width, box_y + box_height, true);
    
    // Draw title
    draw_set_font(-1);
    draw_set_color(c_yellow);
    var title_text = "Select Dialog Scene";
    var title_x = center_x - string_width(title_text) / 2;
    draw_text(title_x, box_y + 20, title_text);
    
    // Draw scene list
    var list_start_y = box_y + 60;
    var item_height = 25;
    var visible_items = min(12, array_length(scene_list));
    var scroll_offset = max(0, global.selected_scene_index - visible_items + 1);
    
    for (var i = 0; i < visible_items; i++) {
        var scene_index = scroll_offset + i;
        if (scene_index >= array_length(scene_list)) break;
        
        var scene_id = scene_list[scene_index];
        var display_name = get_scene_display_name(scene_id);
        var item_y = list_start_y + (i * item_height);
        
        // Highlight selected item
        if (scene_index == global.selected_scene_index) {
            draw_set_color(c_yellow);
            draw_text(box_x + 15, item_y, ">");
            draw_set_color(c_white);
        } else {
            draw_set_color(c_ltgray);
        }
        
        draw_text(box_x + 40, item_y, display_name);
    }
    
    // Draw instructions
    var instruction_y = box_y + box_height - 40;
    draw_set_color(c_gray);
    draw_text(box_x + 20, instruction_y, "Up/Down: Navigate | Enter/I: Select | ESC: Cancel");
    
    // Draw scene count
    var count_text = string(global.selected_scene_index + 1) + " / " + string(array_length(scene_list));
    draw_text(box_x + box_width - 80, instruction_y, count_text);
    
    // Draw preview of current scene image
    if (global.selected_scene_index >= 0 && global.selected_scene_index < array_length(scene_list)) {
        var selected_scene_id = scene_list[global.selected_scene_index];
        
        // Prefer new scene-id filenames, fallback to numbered
        var parts = string_split(selected_scene_id, "_");
        var scene_num = (array_length(parts) >= 2) ? parts[1] : "001";
        
        var preview_paths = [
            selected_scene_id + ".png",
            "dialogs/images/" + selected_scene_id + ".png",
            "datafiles/dialogs/images/" + selected_scene_id + ".png",
            scene_num + ".png",
            "dialogs/images/" + scene_num + ".png",
            "datafiles/dialogs/images/" + scene_num + ".png"
        ];
        
        for (var p = 0; p < array_length(preview_paths); p++) {
            var preview_path = preview_paths[p];
            if (file_exists(preview_path)) {
                try {
                    var preview_sprite = sprite_add(preview_path, 1, false, false, 0, 0);
                    if (preview_sprite != -1 && sprite_exists(preview_sprite)) {
                        // Draw small preview
                        var preview_size = 80;
                        var preview_x = box_x + box_width - preview_size - 20;
                        var preview_y = box_y + 60;
                        
                        draw_sprite_stretched(preview_sprite, 0, preview_x, preview_y, preview_size, preview_size);
                        
                        // Clean up preview sprite
                        sprite_delete(preview_sprite);
                        break;
                    }
                } catch (e) {
                    // Ignore preview loading errors
                }
            }
        }
    }
    
    // Reset alpha and return (don't draw regular dialog)
    draw_set_alpha(1);
    return;
}

// Draw scene background image or fallback color
if (global.current_scene_image != noone && sprite_exists(global.current_scene_image)) {
    // Draw scene background image
    draw_set_alpha(transition_alpha);
    var img_w = sprite_get_width(global.current_scene_image);
    var img_h = sprite_get_height(global.current_scene_image);
    var gui_w = display_get_gui_width();
    var gui_h = display_get_gui_height();
    
    // Scale image to fit screen while maintaining aspect ratio
    var scale_x = gui_w / img_w;
    var scale_y = gui_h / img_h;
    var scale = min(scale_x, scale_y);
    
    var draw_w = img_w * scale;
    var draw_h = img_h * scale;
    var draw_x = (gui_w - draw_w) / 2;
    var draw_y = (gui_h - draw_h) / 2;
    
    draw_sprite_stretched(global.current_scene_image, 0, draw_x, draw_y, draw_w, draw_h);
    
    // Add dark overlay for readability
    draw_set_color(c_black);
    draw_set_alpha(0.3 * transition_alpha);
    draw_rectangle(0, 0, gui_w, gui_h, false);
    draw_set_alpha(transition_alpha);
} else {
    // Draw solid color background as fallback
    var bg_color = c_black;
    draw_set_color(bg_color);
    draw_set_alpha(0.8 * transition_alpha);
    draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);
    draw_set_alpha(transition_alpha);
}

// Get current node info
var current_node = get_current_dialog_node();
if (current_node == undefined) {
    draw_set_alpha(1);
    return;
}

// Dialog box properties
var dialog_margin = 40;
var dialog_height = 200;
var dialog_y = display_get_gui_height() - dialog_height - dialog_margin;
var dialog_width = display_get_gui_width() - (dialog_margin * 2);

// Draw dialog box background
draw_set_color(c_dkgray);
draw_rectangle(dialog_margin, dialog_y, dialog_margin + dialog_width, dialog_y + dialog_height, false);

// Draw dialog box border
draw_set_color(c_white);
draw_rectangle(dialog_margin, dialog_y, dialog_margin + dialog_width, dialog_y + dialog_height, true);

// Draw speaker name
var speaker_name = current_node.speaker ?? "Unknown";
var name_y = dialog_y - 30;
draw_set_font(-1); // Default font
draw_set_color(c_yellow);
draw_text(dialog_margin + 10, name_y, speaker_name);

// Draw dialog text
var text_margin = 20;
var text_x = dialog_margin + text_margin;
var text_y = dialog_y + text_margin;
var text_width = dialog_width - (text_margin * 2);

draw_set_color(c_white);
draw_text_ext(text_x, text_y, current_node.text, 16, text_width);

// Draw choices if in choice selection mode
if (global.dialog_state == 2) { // DialogState.CHOICE_SELECTION
    var choices = get_available_choices();
    var choice_start_y = text_y + 80;
    var choice_spacing = 25;
    
    for (var i = 0; i < array_length(choices); i++) {
        var choice_y = choice_start_y + (i * choice_spacing);
        var choice_text = choices[i].text;
        
        // Highlight selected choice
        if (i == selected_choice_index) {
            draw_set_color(c_yellow);
            draw_text(text_x - 15, choice_y, ">");
            draw_set_color(c_white);
        } else {
            draw_set_color(c_ltgray);
        }
        
        // Show choice number and text
        draw_text(text_x, choice_y, string(i + 1) + ". " + choice_text);
    }
}

// Draw instructions
var instruction_y = display_get_gui_height() - 30;
draw_set_color(c_gray);
draw_set_font(-1);

if (global.dialog_state == 2) { // DialogState.CHOICE_SELECTION
    draw_text(dialog_margin, instruction_y, "Use Arrow Keys to navigate, Enter to select, ESC to exit");
} else {
    draw_text(dialog_margin, instruction_y, "Press Space/Enter to continue, ESC to exit");
}

// Debug info
if (dialog_debug) {
    draw_set_color(c_lime);
    var scene_id = "None";
    var node_id = "None";
    if (global.current_dialog_scene != undefined) scene_id = global.current_dialog_scene.id;
    if (current_node != undefined) node_id = current_node.id;
    
    var debug_text = "Scene: " + scene_id + " | Node: " + node_id + " | State: " + string(global.dialog_state) + " | Alpha: " + string(transition_alpha);
    draw_text(10, 10, debug_text);
    var mode_text = global.dialog_scene_selection ? "Scene Selection" : "Dialog";
    draw_text(10, 25, "Room: " + room_get_name(room) + " | Press I for " + mode_text);
    
    // Show image info
    var image_debug = "Image: ";
    if (global.current_scene_image != noone && sprite_exists(global.current_scene_image)) {
        image_debug += "Loaded (" + string(global.current_scene_image) + ")";
    } else {
        image_debug += "None (" + string(global.current_scene_image) + ")";
    }
    draw_text(10, 40, image_debug);
    
    // Show current stats
    var stats_y = 55;
    draw_text(10, stats_y, "Intel: " + string(get_dialog_stat("intel")));
    draw_text(10, stats_y + 15, "Fuel: " + string(get_dialog_resource("fuel")));
    draw_text(10, stats_y + 30, "Earth Rep: " + string(get_dialog_reputation("earth")));
    draw_text(10, stats_y + 45, "Loop Count: " + string(global.loop_count));
}

// Reset alpha
draw_set_alpha(1);
