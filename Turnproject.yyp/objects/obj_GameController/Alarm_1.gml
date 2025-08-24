// obj_GameController Alarm[1] Event
// Delayed save data application via event bus

show_debug_message("GameController: Emitting save_data_loaded event");
scr_event_emit("save_data_loaded", {});