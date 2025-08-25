/// portrait_utils.gml
/// Utilities to resolve and draw crew portraits safely.

function portraits_get_sprite_for_crew(crew_id) {
    if (is_undefined(crew_id) || crew_id == "") return -1;

    // 0) Explicit global map override (supports struct or ds_map)
    if (variable_global_exists("portraits_map")) {
        var mapped_name = undefined;
        var pm = global.portraits_map;
        if (is_struct(pm)) {
            if (variable_struct_exists(pm, crew_id)) mapped_name = variable_struct_get(pm, crew_id);
        } else if (ds_exists(pm, ds_type_map)) {
            if (ds_map_exists(pm, crew_id)) mapped_name = pm[? crew_id];
        }
        if (!is_undefined(mapped_name)) {
            var spr0 = asset_get_index(mapped_name);
            if (spr0 != -1) return spr0;
        }
    }

    // Try common naming conventions without path prefixes
    var candidates = [
        "spr_portrait_" + crew_id,
        "portrait_" + crew_id,
        crew_id + "_portrait",
        "portraits_" + crew_id,
        "crew_portrait_" + crew_id,
        "spr_" + crew_id + "_portrait"
    ];

    for (var i = 0; i < array_length(candidates); i++) {
        var spr = asset_get_index(candidates[i]);
        if (spr != -1) return spr;
    }

    return -1;
}

function portraits_get_sprite_for_entity(entity) {
    if (!instance_exists(entity)) return -1;
    // Prefer an explicit field on the entity if provided
    if (variable_instance_exists(entity.id, "portrait_sprite")) {
        var sprx = entity.portrait_sprite;
        if (!is_undefined(sprx) && sprx != -1) return sprx;
    }
    // Prefer explicit crew_id on players
    if (object_get_name(entity.object_index) == "obj_Player") {
        if (variable_instance_exists(entity.id, "crew_id")) {
            var spr = portraits_get_sprite_for_crew(entity.crew_id);
            if (spr != -1) return spr;
        }
        // Fallback: attempt by character_name (lowercase, no spaces)
        if (variable_instance_exists(entity.id, "character_name")) {
            var key = string_lower(string_replace_all(entity.character_name, " ", "_"));
            var spr2 = portraits_get_sprite_for_crew(key);
            if (spr2 != -1) return spr2;
        }
    }
    // Optional: generic enemy portrait hook
    // var is_enemy = (object_get_name(entity.object_index) == "obj_Enemy");
    // if (is_enemy) {
    //     var enemy_spr = asset_get_index("spr_portrait_enemy");
    //     if (enemy_spr != -1) return enemy_spr;
    // }
    return -1;
}

function portraits_draw_fit(spr, x1, y1, x2, y2) {
    if (spr == -1) return false;
    var w = x2 - x1;
    var h = y2 - y1;
    var sw = sprite_get_width(spr);
    var sh = sprite_get_height(spr);
    if (sw <= 0 || sh <= 0) return false;
    var scale = min(w / sw, h / sh);
    // Draw from top-left corner instead of center
    draw_sprite_ext(spr, 0, x1, y1, scale, scale, 0, c_white, 1);
    return true;
}
