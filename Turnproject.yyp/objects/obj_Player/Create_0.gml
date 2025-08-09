// Core game stats
state = TURNSTATE.inactive;
max_moves = 2;
moves = 2;
hp = 10;
max_hp = 10;

// Base combat stats (without weapon bonuses)
base_attack_bonus = 2;
base_damage_modifier = 1; 
base_defense_score = 13;

// Current combat stats (base + weapon bonuses)
attack_bonus = base_attack_bonus;
damage_modifier = base_damage_modifier;
defense_score = base_defense_score;

// Weapon system
equipped_weapon_id = 0;
weapon_name = "Fists";
weapon_attack_bonus = 1;
weapon_damage_dice = "1d1";
weapon_damage_modifier = 0;
weapon_defense_bonus = 0;
weapon_special_type = "none";

// Status effects
frozen_turns = 0;
burn_turns = 0;

// Initialize weapons and update stats
init_weapons();
update_combat_stats();

is_anim = false;
target_enemy = 0;

enum Dir {UP,
			DOWN,
			LEFT,
			RIGHT};

enum State {IDLE,
			RUN,
			ATTACK};

spr_matrix = [
    [ch1_up_idle, ch1_up_run, ch1_up_att],
    [ch1_down_idle, ch1_down_run, ch1_down_att],
    [ch1_left_idle, ch1_left_run, ch1_left_att],
    [ch1_right_idle, ch1_right_run, ch1_right_att]
];

dir = Dir.DOWN;
anim_state = State.IDLE;
image_speed = 1.0;