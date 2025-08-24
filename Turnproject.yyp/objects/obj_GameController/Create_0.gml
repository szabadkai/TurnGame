// Minimal event bus

function scr_event_bus_init() {
  if (!variable_global_exists("events")) {
    global.events = {};
  }
}

function scr_event_subscribe(_name, _handler) {
  scr_event_bus_init();
  if (!variable_struct_exists(global.events, _name)) {
    global.events[$ _name] = [];
  }
  array_push(global.events[$ _name], _handler);
}

function scr_event_emit(_name, _data) {
  scr_event_bus_init();
  if (!variable_struct_exists(global.events, _name)) return;
  var _list = global.events[$ _name];
  for (var i = 0; i < array_length(_list); i++) {
    var _fn = _list[i];
    try {
      _fn(_data);
    } catch (e) {
      show_debug_message("Event handler error for '" + string(_name) + "': " + string(e));
    }
  }
}



// Helper for logging
function scr_log(_message) {
  scr_event_emit("log", _message);
}

// Helper for autosave
function scr_autosave(_reason) {
  scr_event_emit("autosave", {reason: _reason});
}
// Persistent controller for global init and navigation/event bus

// Ensure single instance
if (instance_number(obj_GameController) > 1) {
  instance_destroy();
  return;
}

persistent = true;

// Initialize services
scr_event_bus_init();
scr_nav_init();

// Infer initial state from current room (no transition)
switch (room) {
  case Room_MainMenu: global.nav.state = GameState.MAIN_MENU; break;
  case Room_StarMap:  global.nav.state = GameState.STARMAP;   break;
  case Room_Dialog:   global.nav.state = GameState.DIALOG;    break;
  default:            global.nav.state = GameState.OVERWORLD; break;
}
// Subscribe to log and autosave events
scr_event_subscribe("log", function(_data) {
  var _msg = (variable_struct_exists(_data, "message") ? _data.message : string(_data));
  if (variable_global_exists("combat_log")) {
    global.combat_log(string(_msg));
  } else {
    show_debug_message(string(_msg));
  }
});

scr_event_subscribe("autosave", function(_data) {
  // centralize autosave policy here
  try {
    auto_save_game();
    var _reason = variable_struct_exists(_data, "reason") ? _data.reason : "unknown";
    show_debug_message("Autosave event processed (reason: " + string(_reason) + ")");
  } catch (e) {
    show_debug_message("Autosave event failed: " + string(e));
  }
});