// obj_TravelConfirmationDialog Draw GUI Event
// Render travel confirmation dialog

if (!dialog_visible || dialog_alpha <= 0) return;

// Draw semi-transparent overlay behind dialog - use GUI dimensions
draw_set_color(c_black);
draw_set_alpha(0.5 * dialog_alpha);
draw_rectangle(0, 0, display_get_gui_width(), display_get_gui_height(), false);

// Draw dialog background
draw_set_color(dialog_background_color);
draw_set_alpha(dialog_background_alpha * dialog_alpha);
draw_rectangle(dialog_x, dialog_y, dialog_x + dialog_width, dialog_y + dialog_height, false);

// Draw dialog border
draw_set_color(dialog_border_color);
draw_set_alpha(0.8 * dialog_alpha);
draw_rectangle(dialog_x, dialog_y, dialog_x + dialog_width, dialog_y + dialog_height, true);

// Draw dialog content based on state
if (dialog_state == "CONFIRMATION") {
    draw_confirmation_dialog();
} else if (dialog_state == "LANDING_PARTY") {
    draw_landing_party_selection();
}

// Reset draw settings
draw_set_color(c_white);
draw_set_alpha(1.0);
draw_set_halign(fa_left);
draw_set_valign(fa_top);


function draw_confirmation_dialog() {
    if (variable_struct_exists(system_info, "name")) {
        // Draw title
        draw_set_color(dialog_title_color);
        draw_set_alpha(dialog_alpha);
        draw_set_halign(fa_center);
        draw_set_valign(fa_top);
        draw_text(dialog_x + dialog_width/2, dialog_y + dialog_padding, "Travel Confirmation");
        
        // Draw system information
        draw_set_color(dialog_text_color);
        draw_set_halign(fa_center);
        var info_y = dialog_y + dialog_padding + 25;
        
        draw_text(dialog_x + dialog_width/2, info_y, "Travel to:");
        draw_set_color(c_yellow);
        
        // Wrap system name if too long
        var system_name_text = system_info.name;
        var max_text_width = dialog_width - (dialog_padding * 2);
        
        if (string_width(system_name_text) > max_text_width) {
            // Split long names
            var words = string_split(system_name_text, " ");
            var line1 = "";
            var line2 = "";
            var current_line = line1;
            
            for (var i = 0; i < array_length(words); i++) {
                var test_text = (current_line == "" ? words[i] : current_line + " " + words[i]);
                if (string_width(test_text) <= max_text_width) {
                    current_line = test_text;
                    if (current_line == line1) line1 = current_line;
                    else line2 = current_line;
                } else if (line1 == "") {
                    line1 = current_line;
                    current_line = words[i];
                    line2 = current_line;
                } else {
                    break;
                }
            }
            
            draw_text(dialog_x + dialog_width/2, info_y + 20, line1);
            if (line2 != "") {
                draw_text(dialog_x + dialog_width/2, info_y + 35, line2);
            }
        } else {
            draw_text(dialog_x + dialog_width/2, info_y + 20, system_name_text);
        }
        
        // Show additional system info if available
        if (variable_struct_exists(system_info, "type")) {
            draw_set_color(c_ltgray);
            var type_y = (string_width(system_name_text) > max_text_width) ? info_y + 55 : info_y + 40;
            var type_text = "(" + system_info.type + ")";
            
            // Truncate type if too long
            if (string_width(type_text) > max_text_width) {
                while (string_width(type_text + "...") > max_text_width && string_length(type_text) > 5) {
                    type_text = string_delete(type_text, string_length(type_text), 1);
                }
                type_text += "...)";
            }
            
            draw_text(dialog_x + dialog_width/2, type_y, type_text);
        }
    }

    // Draw buttons
    var button_y = dialog_y + button_y_offset;

    // Confirm button
    var confirm_x = dialog_x + dialog_width/2 - button_width - button_spacing/2;
    draw_set_color(confirm_button_hover ? button_hover_color : button_normal_color);
    draw_set_alpha(0.7 * dialog_alpha);
    draw_rectangle(confirm_x, button_y, confirm_x + button_width, button_y + button_height, false);

    draw_set_color(c_white);
    draw_set_alpha(dialog_alpha);
    draw_rectangle(confirm_x, button_y, confirm_x + button_width, button_y + button_height, true);

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(confirm_x + button_width/2, button_y + button_height/2, "Confirm");

    // Cancel button
    var cancel_x = dialog_x + dialog_width/2 + button_spacing/2;
    draw_set_color(cancel_button_hover ? button_hover_color : button_normal_color);
    draw_set_alpha(0.7 * dialog_alpha);
    draw_rectangle(cancel_x, button_y, cancel_x + button_width, button_y + button_height, false);

    draw_set_color(c_white);
    draw_set_alpha(dialog_alpha);
    draw_rectangle(cancel_x, button_y, cancel_x + button_width, button_y + button_height, true);

    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(cancel_x + button_width/2, button_y + button_height/2, "Cancel");

    // Draw keyboard shortcuts hint
    draw_set_color(c_ltgray);
    draw_set_alpha(0.7 * dialog_alpha);
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    var hint_text = "Enter/Y - Confirm  |  Esc/N - Cancel";
    var hint_width = string_width(hint_text);
    var max_hint_width = dialog_width - (dialog_padding * 2);

    // Truncate hint if too long
    if (hint_width > max_hint_width) {
        hint_text = "Enter - Confirm  |  Esc - Cancel";
    }

    draw_text(dialog_x + dialog_width/2, dialog_y + dialog_height - 25, hint_text);
}

function draw_landing_party_selection() {
    // Draw title
    draw_set_color(dialog_title_color);
    draw_set_alpha(dialog_alpha);
    draw_set_halign(fa_center);
    draw_set_valign(fa_top);
    draw_text(dialog_x + dialog_width/2, dialog_y + dialog_padding, "Select Landing Party");

    // Draw crew list
    draw_set_color(dialog_text_color);
    draw_set_halign(fa_left);
    var list_y = dialog_y + dialog_padding + 30;
    for (var i = 0; i < array_length(global.crew); i++) {
        var member = global.crew[i];
        var member_y = list_y + (i * 20);
        var is_selected = (array_indexOf(landing_party, i) != -1);

        // Draw checkbox
        var check_x = dialog_x + dialog_padding;
        draw_rectangle(check_x, member_y, check_x + 12, member_y + 12, true);
        if (is_selected) {
            draw_line(check_x, member_y, check_x + 12, member_y + 12);
            draw_line(check_x, member_y + 12, check_x + 12, member_y);
        }

        // Draw member name and status
        var text_x = check_x + 20;
        var member_text = member.name + " (" + member.status + ", " + string(member.hp) + " HP)";
        draw_text(text_x, member_y, member_text);
    }

    // Draw Launch button
    var button_y = dialog_y + dialog_height - 40;
    var launch_button_x = dialog_x + dialog_width/2 - button_width/2;
    draw_set_color(c_green);
    draw_rectangle(launch_button_x, button_y, launch_button_x + button_width, button_y + button_height, false);
    draw_set_color(c_white);
    draw_set_halign(fa_center);
    draw_set_valign(fa_middle);
    draw_text(launch_button_x + button_width/2, button_y + button_height/2, "Launch");
}