// Core dialog system functions
// Handles loading, parsing, and managing JSON dialog scenes

// Global dialog system variables
global.current_dialog_scene = undefined;
global.current_dialog_node = undefined;
global.dialog_state = 0; // DialogState.INACTIVE
global.dialog_data = {};
global.dialog_base_path = "datafiles/dialogs/";
global.dialog_scene_selection = false;
global.selected_scene_index = 0;
global.current_scene_image = noone;
global.dialog_exit_room = -1; // optional: room to go after dialog ends

// Load the dialog scene index
function load_dialog_index() {
    var index_path = "datafiles/dialogs/_index.json";
    
    show_debug_message("Loading dialog index from: " + index_path);
    
    // Try to load the index file using GameMaker's included file system
    // For included files, try just the filename first, then explicit folders
    var index_filename = "_index.json";
    try {
        var index_json = load_text_file_safe(index_filename);
        if (index_json != "") {
            show_debug_message("Raw JSON content length: " + string(string_length(index_json)));
            var index_data = json_parse(index_json);
            if (variable_struct_exists(index_data, "scenes")) {
                global.dialog_scene_index = index_data.scenes;
                show_debug_message("Loaded dialog index with " + string(array_length(global.dialog_scene_index)) + " scenes from JSON");
                return true;
            } else {
                show_debug_message("JSON loaded but no 'scenes' property found");
            }
        } else {
            show_debug_message("Empty or failed to load JSON content from " + index_filename);
            // Try with full path as fallback
            index_json = load_text_file_safe(index_path);
            if (index_json != "") {
                var index_data = json_parse(index_json);
                if (variable_struct_exists(index_data, "scenes")) {
                    global.dialog_scene_index = index_data.scenes;
                    show_debug_message("Loaded dialog index with " + string(array_length(global.dialog_scene_index)) + " scenes from full path");
                    return true;
                }
            }
            // Try dialogs folder (runtime includes often flatten to dialogs/)
            var dialogs_index = "dialogs/_index.json";
            index_json = load_text_file_safe(dialogs_index);
            if (index_json != "") {
                var index_data = json_parse(index_json);
                if (variable_struct_exists(index_data, "scenes")) {
                    global.dialog_scene_index = index_data.scenes;
                    show_debug_message("Loaded dialog index with " + string(array_length(global.dialog_scene_index)) + " scenes from dialogs folder");
                    return true;
                }
            }
        }
    } catch (e) {
        show_debug_message("Failed to load dialog index: " + string(e));
    }
    
    // Fallback: comprehensive scene list (all available scenes)
    global.dialog_scene_index = [
        "datafiles/dialogs/scene_001_prometheus_discovery.json",
        "datafiles/dialogs/scene_002_keth_mori_threshold.json",
        "datafiles/dialogs/scene_003_pirate_ambush.json",
        "datafiles/dialogs/scene_004_alien_glyphs.json",
        "datafiles/dialogs/scene_005_watchers_blockade.json",
        "datafiles/dialogs/scene_006_loop_discovery.json",
        "datafiles/dialogs/scene_007_crystal_guardian.json",
        "datafiles/dialogs/scene_008_earth_debrief_victory.json",
        "datafiles/dialogs/scene_009_earth_debrief_assimilation.json",
        "datafiles/dialogs/scene_010_earth_debrief_pact.json",
        "datafiles/dialogs/scene_011_prometheus_wreck_approach.json",
        "datafiles/dialogs/scene_012_prometheus_logs.json",
        "datafiles/dialogs/scene_013_wreck_confrontation.json",
        "datafiles/dialogs/scene_014_departure_earth_launch.json",
        "datafiles/dialogs/scene_015_derelict_satellite.json",
        "datafiles/dialogs/scene_016_cosmic_anomaly.json",
        "datafiles/dialogs/scene_017_broken_probe.json",
        "datafiles/dialogs/scene_018_planetfall_descent.json",
        "datafiles/dialogs/scene_019_landing_zone.json",
        "datafiles/dialogs/scene_020_beast_ambush.json",
        "datafiles/dialogs/scene_021_rescue_or_raid.json",
        "datafiles/dialogs/scene_022_corruption_whisper.json",
        "datafiles/dialogs/scene_023_collapse_escape.json",
        "datafiles/dialogs/scene_024_fractured_space_entry.json",
        "datafiles/dialogs/scene_025_crew_fracture.json",
        "datafiles/dialogs/scene_026_loop_awareness_progression.json",
        "datafiles/dialogs/scene_027_kethmori_sanctuary.json",
        "datafiles/dialogs/scene_028_prometheus_black_site.json",
        "datafiles/dialogs/scene_029_swarm_queen_gambit.json",
        "datafiles/dialogs/scene_030_information_broker.json",
        "datafiles/dialogs/scene_031_nexus_recruitment.json",
        "datafiles/dialogs/scene_032_pandora_anomaly.json",
        "datafiles/dialogs/scene_033_crucible_secret.json",
        "datafiles/dialogs/scene_034_new_horizon_mystery.json",
        "datafiles/dialogs/scene_035_retribution_echoes.json"
    ];
    show_debug_message("Using fallback dialog index with " + string(array_length(global.dialog_scene_index)) + " scenes");
    return false;
}

// Load a dialog scene from JSON file
function load_dialog_scene(scene_id) {
    show_debug_message("Attempting to load dialog scene: " + scene_id);
    
    // For GameMaker's included files, try filename first, then paths
    var file_paths = [
        scene_id + ".json",                                // Just filename (for included files)
        "datafiles/dialogs/" + scene_id + ".json",        // Full path
        "dialogs/" + scene_id + ".json"                    // Short path
    ];
    
    var file_path = "";
    var found_file = false;
    
    for (var i = 0; i < array_length(file_paths); i++) {
        var test_path = file_paths[i];
        if (file_exists(test_path)) {
            file_path = test_path;
            found_file = true;
            show_debug_message("Found scene file at: " + file_path);
            break;
        }
    }
    
    if (!found_file) {
        show_debug_message("Scene file not found at any path for: " + scene_id);
        // Still try the first path in case of access issues
        file_path = file_paths[0];
    }
    
    // Try to load the JSON file
    try {
        var json_content = load_text_file_safe(file_path);
        if (json_content != "") {
            show_debug_message("Raw JSON length: " + string(string_length(json_content)));
            var scene_data = json_parse(json_content);
            
            // Validate the parsed scene data
            if (variable_struct_exists(scene_data, "id") && variable_struct_exists(scene_data, "nodes")) {
                global.current_dialog_scene = scene_data;
                show_debug_message("Successfully loaded dialog scene: " + scene_id + " with " + string(array_length(scene_data.nodes)) + " nodes");
                return true;
            } else {
                show_debug_message("Invalid scene structure for: " + scene_id);
            }
        } else {
            show_debug_message("Empty or failed to load JSON content for: " + scene_id);
        }
    } catch (e) {
        show_debug_message("Failed to parse JSON for scene " + scene_id + ": " + string(e));
    }
    
    
    show_debug_message("Dialog scene not found: " + scene_id);
    return false;
}

// Safe file loading function that handles missing files
function load_text_file_safe(file_path) {
    show_debug_message("Attempting to load file: " + file_path);
    
    // GameMaker's datafiles are accessible directly by their path
    // Try the file path as-is first
    if (file_exists(file_path)) {
        show_debug_message("Found file at path: " + file_path);
        var file_id = file_text_open_read(file_path);
        if (file_id != -1) {
            var content = "";
            while (!file_text_eof(file_id)) {
                var line = file_text_readln(file_id);
                content += line;
            }
            file_text_close(file_id);
            show_debug_message("Successfully loaded " + string(string_length(content)) + " characters from " + file_path);
            return content;
        } else {
            show_debug_message("Failed to open file: " + file_path);
        }
    } else {
        show_debug_message("File does not exist: " + file_path);
    }
    
    // Try with working directory prefix as fallback
    var working_file = working_directory + file_path;
    if (file_exists(working_file)) {
        show_debug_message("Found file in working directory: " + working_file);
        var file_id = file_text_open_read(working_file);
        if (file_id != -1) {
            var content = "";
            while (!file_text_eof(file_id)) {
                var line = file_text_readln(file_id);
                content += line;
            }
            file_text_close(file_id);
            show_debug_message("Successfully loaded " + string(string_length(content)) + " characters from working directory");
            return content;
        }
    }
    
    // Try just the filename in case it's in root
    var filename = filename_name(file_path);
    if (file_exists(filename)) {
        show_debug_message("Found file by filename: " + filename);
        var file_id = file_text_open_read(filename);
        if (file_id != -1) {
            var content = "";
            while (!file_text_eof(file_id)) {
                var line = file_text_readln(file_id);
                content += line;
            }
            file_text_close(file_id);
            show_debug_message("Successfully loaded " + string(string_length(content)) + " characters by filename");
            return content;
        }
    }
    
    show_debug_message("File not found at any location: " + file_path);
    show_debug_message("Working directory: " + working_directory);
    show_debug_message("Application directory: " + program_directory);
    return "";
}

// Create a test dialog scene for demonstration
function create_test_dialog_scene() {
    return {
        id: "scene_001_prometheus_discovery",
        act: 1,
        location: "space_sector_7",
        npcs: ["navigator_chen", "first_officer_torres", "ship_ai_maya"],
        nodes: [
            {
                id: "chen_001",
                speaker: "Navigator Chen",
                text: "Captain, we're picking up a massive energy signature. It's... wait, these readings match our fleet registry. It's the UES Prometheus! [Chen's hands tremble on the console.]",
                choices: [
                    {
                        id: "choice_001a",
                        text: "The flagship? After twenty years? All crew, battle stations.",
                        next: "chen_002a",
                        effects: {
                            crew_alert: "high",
                            torres_trust: -1,
                            chen_fear: 1
                        }
                    },
                    {
                        id: "choice_001b", 
                        text: "That's impossible. Double-check those readings.",
                        next: "chen_002b",
                        effects: {
                            chen_trust: -1,
                            chen_fear: 1
                        }
                    },
                    {
                        id: "choice_001c",
                        text: "Finally. Set course immediately, but approach with caution.",
                        next: "chen_002a",
                        effects: {
                            crew_morale: 1,
                            chen_fear: 0
                        }
                    },
                    {
                        id: "choice_001d",
                        text: "[Void Touched] I can feel the death echoing from it even here.",
                        conditions: {
                            background: "void_touched"
                        },
                        next: "chen_002c",
                        effects: {
                            void_awareness: 1,
                            crew_fear: 1,
                            chen_fear: 2
                        }
                    },
                    {
                        id: "choice_001e",
                        text: "[Remain Silent]",
                        next: "silence_reveal_001",
                        effects: {
                            information_seeking: 1
                        }
                    }
                ]
            },
            {
                id: "chen_002a",
                speaker: "Navigator Chen",
                text: "Sir, I'm not detecting any active systems. She's dead in the water. But... the hull is intact. No signs of combat damage.",
                next: "chen_tech_001"
            },
            {
                id: "chen_002b",
                speaker: "Navigator Chen", 
                text: "I've triple-checked, Captain. It's definitely the Prometheus. Energy signature, hull configuration, even the registration beacon—though it's barely functioning.",
                next: "chen_tech_001"
            },
            {
                id: "chen_002c",
                speaker: "Navigator Chen",
                text: "Captain... you're scaring the crew. But you're right—zero life signs. It's a tomb.",
                next: "chen_tech_001"
            },
            {
                id: "silence_reveal_001",
                speaker: "Navigator Chen",
                text: "[Chen, filling the silence] I'm also seeing micro-fractures along the dorsal spine—like it phased through something. Registration ping is drifting. Captain... this looks wrong.",
                next: "chen_tech_001"
            },
            {
                id: "chen_tech_001",
                speaker: "Navigator Chen",
                text: "If this signature is authentic, the gate wake around Prometheus is... inverted. That shouldn't be possible without catastrophic bleed. We can: run a deep-spectrum scan, sweep for survivors, or try comms spoofing.",
                choices: [
                    {
                        id: "choice_tech_001_interrupt",
                        text: "[Interrupt] Enough theory. Survivors first—now.",
                        next: "chen_scan_001",
                        effects: {
                            contradictions: 1,
                            chen_fear: 1
                        }
                    },
                    {
                        id: "choice_tech_001_listen",
                        text: "[Remain Silent] (Let Chen keep talking.)",
                        next: "chen_tech_001_more",
                        effects: {
                            intel: 1
                        }
                    },
                    {
                        id: "choice_tech_001_compound",
                        text: "[Analysis] If the wake is inverted, correlate subharmonics at 0.7 Hz and 13.2 Hz.",
                        skill_check: {
                            type: "intelligence",
                            difficulty: 18
                        },
                        next: "maya_comms_001",
                        effects: {
                            intel: 2,
                            void_knowledge: 1
                        }
                    }
                ]
            },
            {
                id: "chen_tech_001_more",
                speaker: "Navigator Chen",
                text: "Okay—details: the inverted wake implies Prometheus crossed the gate boundary the wrong way. If we ping at low power, we might tease out any passive beacons without waking... whatever did this.",
                choices: [
                    {
                        id: "choice_tech_more_ping",
                        text: "Low-power ping. Keep us cold.",
                        next: "maya_comms_001",
                        effects: {
                            intel: 1,
                            crew_alert: "medium"
                        }
                    },
                    {
                        id: "choice_tech_more_scan",
                        text: "Run a biosign sweep for cryo leakage.",
                        next: "chen_scan_001",
                        effects: {
                            intel: 1
                        }
                    }
                ]
            },
            {
                id: "maya_comms_001",
                speaker: "Ship AI Maya",
                text: "Signal floor adjusted. I'm separating ghost echoes from legitimate beacons. There is a narrowband distress packet repeating every 11 seconds, origin: Prometheus auxiliary bay.",
                choices: [
                    {
                        id: "choice_comms_remain",
                        text: "[Remain Silent]",
                        next: "crew_interject_maya",
                        effects: {
                            intel: 1
                        }
                    },
                    {
                        id: "choice_comms_press",
                        text: "[Press Further] Decode the packet header and subkeys.",
                        skill_check: {
                            type: "engineering",
                            difficulty: 14
                        },
                        next: "press_further_001",
                        effects: {
                            intel: 2
                        }
                    }
                ]
            },
            {
                id: "chen_scan_001",
                speaker: "Navigator Chen",
                text: "Biosign sweep ready. Note: a full pass burns fuel because we'll have to circle the wreck.",
                choices: [
                    {
                        id: "choice_scan_resource",
                        text: "Authorize a full sweep.",
                        conditions: {
                            resources: {
                                fuel: ">5"
                            }
                        },
                        next: "press_further_001",
                        effects: {
                            fuel: -2,
                            intel: 2,
                            survivor_scan: true
                        }
                    },
                    {
                        id: "choice_scan_minimal",
                        text: "Minimal sweep only. Conserve fuel.",
                        next: "torres_pre_001",
                        effects: {
                            fuel: -1,
                            intel: 1
                        }
                    }
                ]
            },
            {
                id: "press_further_001",
                speaker: "Ship AI Maya",
                text: "Decoded: The distress packet is labeled \"Echo-Containment Breach.\" Subkeys reference experimental gate dampeners and an \"Unlisted Passenger.\"",
                next: "torres_pre_001"
            },
            {
                id: "crew_interject_maya",
                speaker: "Ship AI Maya",
                text: "Telemetry shows the Prometheus isn't drifting randomly. Micro-thrusts are correcting her attitude. Someone—or something—is making sure she points at the gate.",
                next: "torres_pre_001"
            },
            {
                id: "torres_pre_001",
                speaker: "First Officer Torres",
                text: "Captain, before we commit: why are we really here? Salvage regs say we ping Earth Command and wait. You're steering us off-book.",
                choices: [
                    {
                        id: "choice_torres_confront",
                        text: "Because Command buried what happened. We're not giving them a head start.",
                        next: "torres_001",
                        effects: {
                            conspiracy_awareness: 1,
                            torres_doubt: 1
                        }
                    },
                    {
                        id: "choice_torres_deceive",
                        text: "[Lie] We already notified them—encrypted channel.",
                        skill_check: {
                            type: "deception",
                            difficulty: 13
                        },
                        next: "torres_001",
                        effects: {
                            torres_trust: -2,
                            lie_stress: 1
                        }
                    },
                    {
                        id: "choice_torres_silent",
                        text: "[Remain Silent]",
                        next: "torres_001",
                        effects: {
                            torres_suspicion: 1
                        }
                    }
                ]
            },
            {
                id: "torres_001",
                speaker: "First Officer Torres",
                text: "Captain, I'm required to remind you that salvage protocol dictates we report this to Earth Command before boarding.",
                choices: [
                    {
                        id: "choice_002a",
                        text: "We're reporting nothing until we know what happened.",
                        next: "end_scene_independent",
                        effects: {
                            earth_reputation: -2,
                            torres_trust: -1,
                            independent_path: 1
                        }
                    },
                    {
                        id: "choice_002b",
                        text: "Send the report. But we're going in first.",
                        next: "end_scene_report",
                        effects: {
                            earth_reputation: 1,
                            followed_protocol: true
                        }
                    },
                    {
                        id: "choice_002c",
                        text: "Torres, how much do you think Earth Command really wants us to find them?",
                        next: "torres_002",
                        effects: {
                            torres_doubt: 1,
                            conspiracy_awareness: 1
                        }
                    }
                ]
            },
            {
                id: "torres_002",
                speaker: "First Officer Torres",
                text: "...Sir, are you suggesting Earth Command expected them to disappear? That's... that's treason to even consider.",
                next: "end_scene_independent"
            },
            {
                id: "end_scene_report",
                speaker: "Ship AI Maya",
                text: "Report packet queued and transmitted over tight-beam. Earth Command will have it in minutes. The crew exhales—some with relief, some with regret.",
                effects: {
                    ending: "reported_to_earth",
                    crew_morale: 1,
                    earth_reputation: 2
                }
            },
            {
                id: "end_scene_independent",
                speaker: "First Officer Torres", 
                text: "Aye, Captain. No reports. Helm, take us in. If this goes sideways, we're alone.",
                effects: {
                    ending: "independent_boarding",
                    independent_path: 1
                }
            }
        ]
    };
}

// Start a dialog scene
function start_dialog_scene(scene_id, starting_node_id = undefined) {
    if (!load_dialog_scene(scene_id)) {
        return false;
    }
    
    // Load scene background image
    load_scene_image(scene_id);
    
    // Find starting node
    var nodes = global.current_dialog_scene.nodes;
    var start_node = undefined;
    
    if (starting_node_id == undefined) {
        // Use first node as default
        if (array_length(nodes) > 0) {
            start_node = nodes[0];
        }
    } else {
        // Find specific node
        for (var i = 0; i < array_length(nodes); i++) {
            if (nodes[i].id == starting_node_id) {
                start_node = nodes[i];
                break;
            }
        }
    }
    
    if (start_node == undefined) {
        show_debug_message("Could not find starting node for dialog scene");
        return false;
    }
    
    global.current_dialog_node = start_node;
    global.dialog_state = 1; // DialogState.ACTIVE
    
    // Make sure dialog manager exists in current room for overlay display
    var dialog_manager = instance_find(obj_DialogManager, 0);
    if (dialog_manager != noone) {
        dialog_manager.transition_alpha = 1;
    } else {
        show_debug_message("No DialogManager found - dialog system requires DialogManager in room");
    }
    
    return true;
}

// Get current dialog node
function get_current_dialog_node() {
    return global.current_dialog_node;
}

// Find node by ID in current scene
function find_dialog_node(node_id) {
    if (global.current_dialog_scene == undefined) {
        return undefined;
    }
    
    var nodes = global.current_dialog_scene.nodes;
    for (var i = 0; i < array_length(nodes); i++) {
        if (nodes[i].id == node_id) {
            return nodes[i];
        }
    }
    
    return undefined;
}

// Navigate to next dialog node
function goto_dialog_node(node_id) {
    var next_node = find_dialog_node(node_id);
    if (next_node != undefined) {
        global.current_dialog_node = next_node;
        global.dialog_state = 1; // DialogState.ACTIVE
        return true;
    } else {
        show_debug_message("Could not find dialog node: " + node_id);
        return false;
    }
}

// Check if a choice is available based on conditions
function is_choice_available(choice) {
    if (variable_struct_exists(choice, "conditions")) {
        return evaluate_dialog_conditions(choice.conditions);
    }
    return true;
}

// Get available choices for current node
function get_available_choices() {
    var node = get_current_dialog_node();
    if (node == undefined || !variable_struct_exists(node, "choices")) {
        return [];
    }
    
    var available_choices = [];
    var choices = node.choices;
    
    for (var i = 0; i < array_length(choices); i++) {
        if (is_choice_available(choices[i])) {
            array_push(available_choices, choices[i]);
        }
    }
    
    return available_choices;
}

// Select a choice and navigate
function select_dialog_choice(choice) {
    // Process effects
    if (variable_struct_exists(choice, "effects")) {
        process_dialog_effects(choice.effects);
    }
    
    // Handle skill check if present
    if (variable_struct_exists(choice, "skill_check")) {
        var result = perform_skill_check(choice.skill_check);
        choice.skill_check_result = result;
    }
    
    // Navigate to next node
    if (variable_struct_exists(choice, "next")) {
        if (choice.next == "end_scene") {
            end_dialog_scene();
        } else {
            goto_dialog_node(choice.next);
        }
    } else {
        // No next node specified, end scene
        end_dialog_scene();
    }
}

// End current dialog scene
function end_dialog_scene() {
    global.dialog_state = 0; // DialogState.INACTIVE
    global.current_dialog_scene = undefined;
    global.current_dialog_node = undefined;
    
    // Clean up scene background image
    if (global.current_scene_image != noone && sprite_exists(global.current_scene_image)) {
        sprite_delete(global.current_scene_image);
        global.current_scene_image = noone;
    }
    
    show_debug_message("Dialog scene ended");

    // Optional: transition to a target room if configured
    if (global.dialog_exit_room != -1) {
            room_goto(Room1);
            return;
        }
    }
}

// Get scene metadata
function get_dialog_scene_info() {
    if (global.current_dialog_scene == undefined) {
        return {};
    }
    
    return {
        id: global.current_dialog_scene.id,
        act: global.current_dialog_scene.act,
        location: global.current_dialog_scene.location,
        npcs: global.current_dialog_scene.npcs
    };
}

// Get list of scene IDs from index
function get_scene_list() {
    if (!variable_global_exists("dialog_scene_index")) {
        return ["scene_001_prometheus_discovery"];
    }
    
    var scene_ids = [];
    for (var i = 0; i < array_length(global.dialog_scene_index); i++) {
        var full_path = global.dialog_scene_index[i];
        // Extract scene ID from path like "datafiles/dialogs/scene_001_prometheus_discovery.json"
        var scene_filename = filename_name(full_path);
        var scene_id = filename_change_ext(scene_filename, "");
        array_push(scene_ids, scene_id);
    }
    
    return scene_ids;
}

// Get scene display name from scene ID
function get_scene_display_name(scene_id) {
    // Convert scene_001_prometheus_discovery to "001: Prometheus Discovery"
    var parts = string_split(scene_id, "_");
    if (array_length(parts) >= 3) {
        var scene_num = parts[1];
        var scene_name = "";
        for (var i = 2; i < array_length(parts); i++) {
            if (i > 2) scene_name += " ";
            scene_name += string_upper(string_char_at(parts[i], 1)) + string_copy(parts[i], 2, string_length(parts[i]) - 1);
        }
        return scene_num + ": " + scene_name;
    }
    return scene_id;
}

// Get scene image path from scene ID
function get_scene_image_path(scene_id) {
    // Prefer explicit scene-id filenames first, e.g. dialogs/images/scene_001_prometheus_discovery.png
    var id_first_paths = [
        scene_id + ".png", // included files by filename
        "dialogs/images/" + scene_id + ".png",
        "datafiles/dialogs/images/" + scene_id + ".png"
    ];
    for (var i = 0; i < array_length(id_first_paths); i++) {
        if (file_exists(id_first_paths[i])) {
            return id_first_paths[i];
        }
    }

    // Then try legacy numbered images (001.png, 002.png, ...)
    var parts = string_split(scene_id, "_");
    if (array_length(parts) >= 2) {
        var scene_num = parts[1];
        var num_paths = [
            scene_num + ".png",
            "dialogs/images/" + scene_num + ".png",
            "datafiles/dialogs/images/" + scene_num + ".png"
        ];
        for (var j = 0; j < array_length(num_paths); j++) {
            if (file_exists(num_paths[j])) {
                return num_paths[j];
            }
        }
    }

    // Default fallback to 001
    var default_paths = [
        "001.png",
        "dialogs/images/001.png",
        "datafiles/dialogs/images/001.png"
    ];
    for (var k = 0; k < array_length(default_paths); k++) {
        if (file_exists(default_paths[k])) {
            return default_paths[k];
        }
    }
    return "";
}

// Load scene image as sprite
function load_scene_image(scene_id) {
    // Clean up previous image
    if (global.current_scene_image != noone && sprite_exists(global.current_scene_image)) {
        sprite_delete(global.current_scene_image);
        global.current_scene_image = noone;
    }
    
    // Prefer explicit scene-id filenames first, then numbered fallbacks
    var parts = string_split(scene_id, "_");
    if (array_length(parts) >= 2) {
        var scene_num = parts[1];

        var image_paths = [
            scene_id + ".png",                                         // Included by filename
            "dialogs/images/" + scene_id + ".png",                    // New preferred path
            "datafiles/dialogs/images/" + scene_id + ".png",          // New preferred path (full)
            scene_num + ".png",                                         // Legacy numbered
            "dialogs/images/" + scene_num + ".png",                    // Legacy numbered path
            "datafiles/dialogs/images/" + scene_num + ".png",          // Legacy numbered full
            working_directory + "dialogs/images/" + scene_id + ".png", // WD + new
            working_directory + scene_id + ".png",                      // WD + filename
            working_directory + "dialogs/images/" + scene_num + ".png",// WD + legacy
            working_directory + scene_num + ".png"                      // WD + filename legacy
        ];
        
        for (var i = 0; i < array_length(image_paths); i++) {
            var image_path = image_paths[i];
            show_debug_message("Trying image path: " + image_path + " (exists: " + string(file_exists(image_path)) + ")");
            
            if (file_exists(image_path)) {
                try {
                    global.current_scene_image = sprite_add(image_path, 1, false, false, 0, 0);
                    if (global.current_scene_image != -1 && sprite_exists(global.current_scene_image)) {
                        show_debug_message("Successfully loaded scene image: " + image_path);
                        return true;
                    } else {
                        show_debug_message("sprite_add returned invalid sprite for: " + image_path);
                        if (global.current_scene_image != -1) {
                            sprite_delete(global.current_scene_image);
                            global.current_scene_image = noone;
                        }
                    }
                } catch (e) {
                    show_debug_message("Failed to load scene image " + image_path + ": " + string(e));
                }
            }
        }
        
        // Try default image if specific one fails
        var default_paths = [
            "001.png",
            "dialogs/images/001.png",                              // Path that works in runtime
            "datafiles/dialogs/images/001.png",
            working_directory + "dialogs/images/001.png",
            working_directory + "001.png"
        ];
        
        for (var i = 0; i < array_length(default_paths); i++) {
            var image_path = default_paths[i];
            if (file_exists(image_path)) {
                try {
                    global.current_scene_image = sprite_add(image_path, 1, false, false, 0, 0);
                    if (global.current_scene_image != -1 && sprite_exists(global.current_scene_image)) {
                        show_debug_message("Loaded default scene image: " + image_path);
                        return true;
                    }
                } catch (e) {
                    show_debug_message("Failed to load default image " + image_path + ": " + string(e));
                }
            }
        }
    }
    
    show_debug_message("No scene image could be loaded for: " + scene_id);
    return false;
}

// Start scene selection mode
function start_scene_selection() {
    show_debug_message("Starting scene selection...");
    global.dialog_scene_selection = true;
    global.selected_scene_index = 0;
    global.dialog_state = 1; // DialogState.ACTIVE
    
    // Make sure dialog manager exists
    var dialog_manager = instance_find(obj_DialogManager, 0);
    if (dialog_manager != noone) {
        dialog_manager.transition_alpha = 1;
    }
}

// Navigate scene selection
function navigate_scene_selection(direction) {
    var scene_list = get_scene_list();
    global.selected_scene_index += direction;
    
    if (global.selected_scene_index < 0) {
        global.selected_scene_index = array_length(scene_list) - 1;
    }
    if (global.selected_scene_index >= array_length(scene_list)) {
        global.selected_scene_index = 0;
    }
    
    show_debug_message("Selected scene index: " + string(global.selected_scene_index));
}

// Select current scene and start dialog
function select_current_scene() {
    var scene_list = get_scene_list();
    if (global.selected_scene_index >= 0 && global.selected_scene_index < array_length(scene_list)) {
        var selected_scene = scene_list[global.selected_scene_index];
        show_debug_message("Starting scene: " + selected_scene);
        
        global.dialog_scene_selection = false;
        start_dialog_scene(selected_scene);
    }
}

// Demo dialog function
function start_demo_dialog() {
    show_debug_message("Starting demo dialog...");
    if (start_dialog_scene("scene_001_prometheus_discovery")) {
        show_debug_message("Demo dialog started successfully");
    } else {
        show_debug_message("Failed to start demo dialog");
    }
}

// Initialize dialog system
function init_dialog_system() {
    // Initialize global dialog data
    if (!variable_global_exists("dialog_flags")) {
        global.dialog_flags = {};
    }
    if (!variable_global_exists("dialog_counters")) {
        global.dialog_counters = {};
    }
    if (!variable_global_exists("dialog_reputation")) {
        global.dialog_reputation = {};
    }
    if (!variable_global_exists("dialog_resources")) {
        global.dialog_resources = {fuel: 20, supplies: 10};
    }
    if (!variable_global_exists("loop_count")) {
        global.loop_count = 0;
    }
    
    // Check what files are available
    show_debug_message("Dialog system initialized");
    show_debug_message("Working directory: " + working_directory);
    show_debug_message("Program directory: " + program_directory);
    show_debug_message("Checking for datafiles/dialogs/_index.json: " + string(file_exists("datafiles/dialogs/_index.json")));
    show_debug_message("Checking for datafiles/dialogs/scene_001_prometheus_discovery.json: " + string(file_exists("datafiles/dialogs/scene_001_prometheus_discovery.json")));
    
    // Load and display the scene index
    load_dialog_index();
    show_debug_message("Final scene count: " + string(array_length(global.dialog_scene_index)));
    
    // Test file availability in runtime
    show_debug_message("Testing runtime file access:");
    show_debug_message("- Working directory: " + working_directory);
    show_debug_message("- Program directory: " + program_directory);
    
    // Test different file paths that might work in GameMaker
    var test_files = [
        "_index.json",
        "datafiles/dialogs/_index.json", 
        "dialogs/_index.json",
        "001.png",
        "datafiles/dialogs/images/001.png",
        "dialogs/images/001.png",
        "scene_001_prometheus_discovery.json",
        "datafiles/dialogs/scene_001_prometheus_discovery.json"
    ];
    
    for (var i = 0; i < array_length(test_files); i++) {
        var test_file = test_files[i];
    show_debug_message("- File exists " + test_file + ": " + string(file_exists(test_file)));
    }
}

// Configure which room to enter after dialog ends
function set_dialog_exit_room(room_ref) {
    // room_ref can be a room asset index or a room name string (e.g., "Room1")
    if (is_string(room_ref)) {
        global.dialog_exit_room = room_ref; // resolve later to avoid compile-time dependency
    } else {
        global.dialog_exit_room = room_ref;
    }
    show_debug_message("Dialog exit room set to: " + string(room_ref));
}
