// obj_StarMapManager Step Event
// Handle star map updates and state management

// Handle returning from dialog room
// (Pending scene handling is done by DialogManager in Room_Dialog)

// ESC key to return to main menu
if (keyboard_check_pressed(vk_escape)) {
    room_goto(Room_MainMenu);
}