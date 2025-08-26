// crew_system.gml
// Central crew management system for persistent characters across combat and dialog

// Initialize the global crew roster
function init_crew_system(force_reset = false) {
    if (!variable_global_exists("crew_roster") || force_reset) {
        if (force_reset) {
            show_debug_message("Force resetting crew roster to baseline (new game)");
        }
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
                
                // XP and Level tracking
                level: 1,
                xp: 0,
                xp_to_next_level: 300,
                asis_available: 0,
                
                // Equipment persistence
                equipped_weapon_id: 0,
                
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
                
                // XP and Level tracking
                level: 1,
                xp: 0,
                xp_to_next_level: 300,
                asis_available: 0,
                
                // Equipment persistence
                equipped_weapon_id: 0,
                
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
                
                // XP and Level tracking
                level: 1,
                xp: 0,
                xp_to_next_level: 300,
                asis_available: 0,
                
                // Equipment persistence
                equipped_weapon_id: 0,
                
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
                
                // XP and Level tracking
                level: 1,
                xp: 0,
                xp_to_next_level: 300,
                asis_available: 0,
                
                // Equipment persistence
                equipped_weapon_id: 0,
                
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
                
                // XP and Level tracking
                level: 1,
                xp: 0,
                xp_to_next_level: 300,
                asis_available: 0,
                
                // Equipment persistence
                equipped_weapon_id: 0,
                
                available: true,
                injured: false,
                morale: 100,
                
                specialties: ["security", "heavy_weapons", "protection"]
            },
            {
                id: "reeves",
                name: "Reeves",
                full_name: "Communications Officer Reeves",
                role: "Communications / Intelligence Officer",
                character_index: 6,
                max_hp: 8,
                hp: 6,
                status: "Lightly Injured",
                
                // Communications specialist
                strength: 11,
                dexterity: 13,
                constitution: 12,
                intelligence: 16,
                wisdom: 15,
                charisma: 17,
                
                // XP and Level tracking
                level: 2,
                xp: 450,
                xp_to_next_level: 900,
                asis_available: 0,
                
                // Equipment persistence
                equipped_weapon_id: 0,
                
                available: true,
                injured: true,
                morale: 85,
                
                specialties: ["communications", "intelligence", "diplomacy"]
            },
            {
                id: "murphy",
                name: "Murphy",
                full_name: "Chief Engineer Murphy",
                role: "Chief Engineering Officer",
                character_index: 7,
                max_hp: 12,
                hp: 4,
                status: "Badly Wounded",
                
                // Engineering specialist
                strength: 15,
                dexterity: 12,
                constitution: 16,
                intelligence: 18,
                wisdom: 14,
                charisma: 9,
                
                // XP and Level tracking
                level: 3,
                xp: 1200,
                xp_to_next_level: 2700,
                asis_available: 1,
                
                // Equipment persistence
                equipped_weapon_id: 0,
                
                available: true,
                injured: true,
                morale: 70,
                
                specialties: ["engineering", "repair", "technical_systems"]
            },
            {
                id: "jackson",
                name: "Jackson",
                full_name: "Lieutenant Commander Jackson",
                role: "Executive Officer / Tactical Specialist",
                character_index: 1,
                max_hp: 14,
                hp: 14,
                status: "Healthy",
                
                // Command specialist
                strength: 17,
                dexterity: 16,
                constitution: 15,
                intelligence: 15,
                wisdom: 16,
                charisma: 18,
                
                // XP and Level tracking
                level: 4,
                xp: 3000,
                xp_to_next_level: 6500,
                asis_available: 1,
                
                // Equipment persistence
                equipped_weapon_id: 0,
                
                available: true,
                injured: false,
                morale: 95,
                
                specialties: ["command", "tactics", "weapons", "leadership"]
            },
            {
                id: "rodriguez",
                name: "Rodriguez",
                full_name: "Ensign Rodriguez",
                role: "Junior Science Officer / Xenobiology",
                character_index: 2,
                max_hp: 7,
                hp: 2,
                status: "Critically Injured",
                
                // Science specialist (junior)
                strength: 9,
                dexterity: 14,
                constitution: 10,
                intelligence: 17,
                wisdom: 13,
                charisma: 12,
                
                // XP and Level tracking
                level: 1,
                xp: 100,
                xp_to_next_level: 300,
                asis_available: 0,
                
                // Equipment persistence
                equipped_weapon_id: 0,
                
                available: true, // Include Rodriguez in selection
                injured: true,
                morale: 40,
                
                specialties: ["xenobiology", "research", "analysis"]
            },
            {
                id: "thompson",
                name: "Thompson",
                full_name: "Petty Officer Thompson",
                role: "Operations Specialist / Logistics",
                character_index: 3,
                max_hp: 9,
                hp: 7,
                status: "Wounded",
                
                // Operations specialist
                strength: 13,
                dexterity: 15,
                constitution: 14,
                intelligence: 14,
                wisdom: 16,
                charisma: 11,
                
                // XP and Level tracking
                level: 2,
                xp: 600,
                xp_to_next_level: 900,
                asis_available: 0,
                
                // Equipment persistence
                equipped_weapon_id: 0,
                
                available: true,
                injured: true,
                morale: 80,
                
                specialties: ["logistics", "operations", "supply_management"]
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
        if (global.crew_roster[i].available) {
            // Include all available crew members regardless of injury status
            // Player can choose injured crew but should see their condition
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
                crew_member.max_hp = max_hp;
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
                
                // Sync XP and level progression
                if (variable_instance_exists(id, "xp")) {
                    crew_member.xp = xp;
                }
                if (variable_instance_exists(id, "level")) {
                    crew_member.level = level;
                }
                if (variable_instance_exists(id, "xp_to_next_level")) {
                    crew_member.xp_to_next_level = xp_to_next_level;
                }
                if (variable_instance_exists(id, "asis_available")) {
                    crew_member.asis_available = asis_available;
                }
                
                // Sync ability scores (in case they were improved via ASI)
                if (variable_instance_exists(id, "strength")) {
                    crew_member.strength = strength;
                }
                if (variable_instance_exists(id, "dexterity")) {
                    crew_member.dexterity = dexterity;
                }
                if (variable_instance_exists(id, "constitution")) {
                    crew_member.constitution = constitution;
                }
                if (variable_instance_exists(id, "intelligence")) {
                    crew_member.intelligence = intelligence;
                }
                if (variable_instance_exists(id, "wisdom")) {
                    crew_member.wisdom = wisdom;
                }
                if (variable_instance_exists(id, "charisma")) {
                    crew_member.charisma = charisma;
                }
                
                // Sync equipment
                if (variable_instance_exists(id, "equipped_weapon_id")) {
                    crew_member.equipped_weapon_id = equipped_weapon_id;
                }
                
                show_debug_message("Updated " + crew_member.name + " - HP: " + string(hp) + "/" + string(max_hp) + " Status: " + crew_member.status + " Level: " + string(crew_member.level) + " XP: " + string(crew_member.xp));
            }
        }
    }
}