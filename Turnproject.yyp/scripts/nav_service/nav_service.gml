// Navigation service for room/state transitions

function scr_nav_init() {
  if (!variable_global_exists("nav")) {
    global.nav = {
      state: undefined,
      prev_state: undefined,
      payload: undefined,
      stack: []
    };
  }
}

function scr_nav_room_for_state(_state) {
  switch (_state) {
    case GameState.MAIN_MENU: return Room_MainMenu;
    case GameState.OVERWORLD: return Room1;
    case GameState.STARMAP:   return Room_StarMap;
    case GameState.DIALOG:    return Room_Dialog;
    case GameState.COMBAT:    return Room1;
    default:                  return room;
  }
}

function scr_nav_go(_state, _payload) {
  scr_nav_init();
  var _current = global.nav.state;
  if (_current != undefined) {
    array_push(global.nav.stack, _current);
  }
  global.nav.prev_state = _current;
  global.nav.state = _state;
  global.nav.payload = _payload;

  var _target_room = scr_nav_room_for_state(_state);
  if (_target_room != room) {
    room_goto(_target_room);
  }
}

function scr_nav_back() {
  scr_nav_init();
  if (array_length(global.nav.stack) > 0) {
    var _state = array_pop(global.nav.stack);
    global.nav.prev_state = global.nav.state;
    global.nav.state = _state;
    var _target_room = scr_nav_room_for_state(_state);
    if (_target_room != room) {
      room_goto(_target_room);
    }
  }
}

