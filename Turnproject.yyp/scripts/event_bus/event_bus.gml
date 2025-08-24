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

