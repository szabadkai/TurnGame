// Weapons registry scaffold (ID-keyed)

function registry_weapons_init() {
  if (!variable_global_exists("Registry")) global.Registry = {};
  if (!variable_struct_exists(global.Registry, "weapons")) {
    global.Registry.weapons = {};
  }
}

function weapon_register(_id, _data) {
  registry_weapons_init();
  global.Registry.weapons[$ _id] = _data;
}

function weapon_get(_id) {
  registry_weapons_init();
  if (variable_struct_exists(global.Registry.weapons, _id)) {
    return global.Registry.weapons[$ _id];
  }
  return undefined;
}

