// crew_system.gml
// Central crew management system for persistent characters across combat and dialog

// Initialize the global crew roster
function init_crew_system() {
    if (!variable_global_exists("crew_roster")) {
        global.crew_roster = [
            {
                id: "torres",
                name: "Torres", 
                full_name: "First Officer Torres",
                role: "First Officer / Tactical",
                character_index: 1,
                max_hp: 10,
                hp: 10,
                status: "Healthy",
                
                // D&D-style stats (tactical specialist)
                strength: 16,
                dexterity: 14, 
                constitution: 15,
                intelligence: 13,
                wisdom: 14,
                charisma: 12,
                
                // Status flags
                available: true,
                injured: false,
                morale: 100,
                
                // Equipment/specializations
                specialties: ["combat", "tactics", "leadership"]
            },
            {
                id: "kim",
                name: "Kim",
                full_name: "Science Officer Kim", 
                role: "Science Officer / Engineer",
                character_index: 2,
                max_hp: 9,
                hp: 9,
                status: "Healthy",
                
                // Science specialist
                strength: 10,
                dexterity: 16,
                constitution: 12, 
                intelligence: 18,
                wisdom: 15,
                charisma: 11,
                
                available: true,
                injured: false,
                morale: 100,
                
                specialties: ["science", "engineering", "computers"]
            },
            {
                id: "chen",
                name: "Chen",
                full_name: "Navigator Chen",
                role: "Navigator / Pilot", 
                character_index: 3,
                max_hp: 10,
                hp: 10,
                status: "Healthy",
                
                // Pilot/navigator
                strength: 12,
                dexterity: 18,
                constitution: 14,
                intelligence: 15,
                wisdom: 16,
                charisma: 13,
                
                available: true,
                injured: false,
                morale: 100,
                
                specialties: ["piloting", "navigation", "evasion"]
            },
            {
                id: "vasquez", 
                name: "Vasquez",
                full_name: "Dr. Vasquez",
                role: "Chief Medical Officer",
                character_index: 4,
                max_hp: 9,
                hp: 9,
                status: "Healthy",
                
                // Medical specialist
                strength: 9,
                dexterity: 14,
                constitution: 13,
                intelligence: 17,
                wisdom: 18,
                charisma: 15,
                
                available: true,
                injured: false,
                morale: 100,
                
                specialties: ["medicine", "biology", "healing"]
            },
            {
                id: "cole",
                name: "Cole", 
                full_name: "Security Chief Cole",
                role: "Security Chief",
                character_index: 5,
                max_hp: 11,
                hp: 11,
                status: "Healthy",
                
                // Security specialist  
                strength: 18,
                dexterity: 15,
                constitution: 17,
                intelligence: 11,
                wisdom: 13,
                charisma: 10,
                
                available: true,
                injured: false,
                morale: 100,
                
                specialties: ["security", "heavy_weapons", "protection"]
            }
        ];
        
        show_debug_message("Crew system initialized with " + string(array_length(global.crew_roster)) + " crew members");
    }
}

// Get crew member by ID
function get_crew_member(crew_id) {
    if (!variable_global_exists("crew_roster")) {
        init_crew_system();
    }
    
    for (var i = 0; i < array_length(global.crew_roster); i++) {
        if (global.crew_roster[i].id == crew_id) {
            return global.crew_roster[i];
        }
    }
    return undefined;
}

// Get available crew members for selection
function get_available_crew() {
    if (!variable_global_exists("crew_roster")) {
        init_crew_system();
    }
    
    var available = array_create(0);
    for (var i = 0; i < array_length(global.crew_roster); i++) {
        if (global.crew_roster[i].available && !global.crew_roster[i].injured) {
            available[array_length(available)] = global.crew_roster[i];
        }
    }
    return available;
}

// Update crew member health/status
function update_crew_member(crew_id, new_hp, new_status) {
    var crew_member = get_crew_member(crew_id);
    if (crew_member != undefined) {
        crew_member.hp = max(0, new_hp);
        crew_member.status = new_status;
        crew_member.injured = (crew_member.hp < crew_member.max_hp * 0.5);
        crew_member.available = (crew_member.hp > 0);
        
        show_debug_message("Updated " + crew_member.name + ": HP=" + string(crew_member.hp) + ", Status=" + crew_member.status);
    }
}

// Set default landing party 
function get_default_landing_party() {
    return ["torres", "kim"]; // First Officer and Science Officer by default
}

// Sync combat results back to crew roster
function sync_combat_to_crew() {
    show_debug_message("Syncing combat results back to crew roster...");
    
    // Find all Player instances and update crew roster
    with (obj_Player) {
        if (variable_instance_exists(id, "crew_id") && crew_id != "") {
            var crew_member = get_crew_member(crew_id);
            if (crew_member != undefined) {
                // Update health and status
                crew_member.hp = hp;
                var health_percent = (hp / max_hp) * 100;
                
                if (hp <= 0) {
                    crew_member.status = "Critically Injured";
                    crew_member.injured = true;
                    crew_member.available = false;
                } else if (health_percent < 25) {
                    crew_member.status = "Badly Wounded"; 
                    crew_member.injured = true;
                } else if (health_percent < 50) {
                    crew_member.status = "Wounded";
                    crew_member.injured = true;
                } else if (health_percent < 75) {
                    crew_member.status = "Lightly Injured";
                    crew_member.injured = false;
                } else {
                    crew_member.status = "Healthy";
                    crew_member.injured = false;
                }
                
                show_debug_message("Updated " + crew_member.name + " - HP: " + string(hp) + "/" + string(max_hp) + " Status: " + crew_member.status);
            }
        }
    }
}