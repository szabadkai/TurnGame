// Script assets have changed for v2.3.0 see
// https://help.yoyogames.com/hc/en-us/articles/360005277377 for more information
function scr_enums(){
enum TURNSTATE {
	active,
	inactive,
	placement
}

enum Dir {
	UP,
	DOWN,
	LEFT,
	RIGHT
}

enum State {
	IDLE,
	RUN,
	ATTACK,
	DIE
}

enum DialogState {
	INACTIVE,
	ACTIVE,
	CHOICE_SELECTION,
	TRANSITIONING,
	COMPLETED
}

// Global high-level game states for navigation
enum GameState {
    MAIN_MENU,
    OVERWORLD,
    COMBAT,
    DIALOG,
    STARMAP
}

enum SkillCheckResult {
	NOT_ATTEMPTED,
	SUCCESS,
	FAILURE,
	CRITICAL_SUCCESS,
	CRITICAL_FAILURE
}

enum EffectType {
	SET_FLAG,
	INCREMENT_COUNTER,
	DECREMENT_COUNTER,
	SET_VALUE,
	DELAYED_EFFECT,
	RESOURCE_CHANGE,
	REPUTATION_CHANGE,
	SCALING_EFFECT
}

// Movement constants
#macro TILE_SIZE 16
#macro MOVEMENT_SPEED 2
#macro MOVEMENT_DURATION 30
#macro LAYER_COLLISION "Tiles_Col"
}
