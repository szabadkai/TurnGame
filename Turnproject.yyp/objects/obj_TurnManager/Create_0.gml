randomize();

//create turn list
turn_list = ds_list_create();

// === SPAWN LANDING PARTY ===
// Create player instances based on selected landing party
spawn_landing_party();

//creating a list -objects- adding all instance numbers of character_base
var objects = ds_list_create();
for (var i = 0; i < instance_number(character_base); i++) {
	ds_list_add(objects, instance_find(character_base, i))
}

while (ds_list_size(objects) > 0) {
	ds_list_shuffle(objects);
	ds_list_add(turn_list, objects[| 0]);
	ds_list_delete(objects, 0)
}

ds_list_destroy(objects);

// === DIALOG SYSTEM INITIALIZATION ===
// Initialize enums and dialog system early in game startup
scr_enums();
init_dialog_system();
init_dialog_state();

// === STAR MAP SYSTEM INITIALIZATION ===
// Initialize star map system early in game startup - but only if not already initialized
if (!variable_global_exists("star_map_state")) {
    show_debug_message("TurnManager: Initializing star map for first time");
    init_star_map();
} else {
    show_debug_message("TurnManager: Star map already initialized, preserving state");
}

// === UI SYSTEM FAILSAFE ===
// Force create UI objects if they don't exist - TurnManager runs early so this ensures UI is available
alarm[1] = 5;  // Wait a few steps then force create UI objects

// === SAVE SYSTEM ===
// Apply loaded save data if we're loading a game
if (variable_global_exists("loading_save") && global.loading_save) {
    alarm[2] = 10; // Apply save data after UI is created
}

// === LANDING PARTY SPAWN FUNCTION ===
function spawn_landing_party() {
    show_debug_message("TurnManager: Spawning landing party...");
    
    // Initialize crew system
    init_crew_system();
    
    // Clear existing players (except those already in combat)
    with (obj_Player) {
        if (state != TURNSTATE.active) {
            instance_destroy();
        }
    }
    
    // Default landing party if none selected
    if (!variable_global_exists("landing_party") || array_length(global.landing_party) == 0) {
        show_debug_message("No landing party selected, using default crew");
        global.landing_party = get_default_landing_party(); // Returns crew IDs
    }
    
    // Spawn positions for landing party
    var spawn_positions = [
        {x: 40, y: 104},   // Original player position
        {x: 40, y: 136},   // Second player position
        {x: 72, y: 104},   // Third position
        {x: 72, y: 136},   // Fourth position
        {x: 104, y: 104}   // Fifth position
    ];
    
    // Create player instances for selected landing party
    for (var i = 0; i < array_length(global.landing_party); i++) {
        var crew_id = global.landing_party[i];
        var crew_member = get_crew_member(crew_id);
        
        if (crew_member != undefined) {
            var pos = spawn_positions[i % array_length(spawn_positions)];
            
            show_debug_message("Spawning " + crew_member.full_name + " at (" + string(pos.x) + "," + string(pos.y) + ")");
            
            var player_instance = instance_create_layer(pos.x, pos.y, "Instances", obj_Player);
            if (player_instance != noone) {
                // Set crew member properties from roster
                player_instance.character_name = crew_member.full_name;
                player_instance.crew_id = crew_member.id;
                player_instance.hp = crew_member.hp;
                player_instance.max_hp = crew_member.max_hp;
                player_instance.character_index = crew_member.character_index;
                
                // Set D&D stats from crew member
                player_instance.strength = crew_member.strength;
                player_instance.dexterity = crew_member.dexterity;
                player_instance.constitution = crew_member.constitution;
                player_instance.intelligence = crew_member.intelligence;
                player_instance.wisdom = crew_member.wisdom;
                player_instance.charisma = crew_member.charisma;
                
                // Recalculate combat stats based on actual ability scores
                with (player_instance) {
                    update_combat_stats();
                }
                
                // Initialize sprite system
                init_character_sprite_matrix(player_instance.character_index);
                player_instance.sprite_index = player_instance.spr_matrix[0][0]; // idle down
                
                show_debug_message("Created " + crew_member.full_name + " with " + string(crew_member.hp) + " HP and ID " + crew_member.id);
            }
        } else {
            show_debug_message("ERROR: Could not find crew member with ID: " + string(crew_id));
        }
    }
    
    show_debug_message("Landing party spawn complete. Total players: " + string(instance_number(obj_Player)));
}
