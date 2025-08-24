// Shared file IO helpers

function scr_file_read_text(_paths) {
  for (var i = 0; i < array_length(_paths); i++) {
    var _p = _paths[i];
    if (file_exists(_p)) {
      var _id = file_text_open_read(_p);
      if (_id != -1) {
        var _content = "";
        while (!file_text_eof(_id)) {
          _content += file_text_readln(_id);
        }
        file_text_close(_id);
        return _content;
      }
    }
  }
  return "";
}

function scr_file_write_text(_path, _text) {
  var _id = file_text_open_write(_path);
  if (_id == -1) return false;
  file_text_write_string(_id, string(_text));
  file_text_close(_id);
  return true;
}

