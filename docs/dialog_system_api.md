# Dialog System API Documentation

## Overview

The Dialog System is a comprehensive narrative engine for managing branching conversations, skill checks, state tracking, and story progression. It uses JSON-based scene files and provides rich functionality for creating complex interactive stories.

## Core Components

### 1. Dialog System (`dialog_system.gml`)
Main system for loading and managing dialog scenes.

### 2. Dialog Manager (`obj_DialogManager`)
Object responsible for UI rendering and input handling.

### 3. Dialog Evaluator (`dialog_evaluator.gml`)
Handles conditions, skill checks, and effects processing.

### 4. Dialog State (`dialog_state.gml`)
Manages persistent state including flags, counters, and resources.

## Scene File Format

Dialog scenes are stored as JSON files in `datafiles/dialogs/` following this structure:

```json
{
    "id": "scene_001_prometheus_discovery",
    "act": 1,
    "location": "space_sector_7",
    "triggers": ["prometheus_scan"],
    "npcs": ["navigator_chen", "first_officer_torres", "ship_ai_maya"],
    "nodes": [...]
}
```

### Required Scene Properties

- **id**: Unique scene identifier (string)
- **act**: Act number (integer) 
- **location**: Location identifier (string)
- **nodes**: Array of dialog nodes

### Optional Scene Properties

- **triggers**: Array of trigger identifiers
- **npcs**: Array of NPC identifiers present in scene

## Node Structure

Each dialog node represents a single piece of dialog or interaction:

```json
{
    "id": "chen_001",
    "speaker": "navigator_chen", 
    "text": "Dialog text here",
    "next": "optional_direct_next_node",
    "choices": [...],
    "emotional_state": {...},
    "effects": {...}
}
```

### Required Node Properties

- **id**: Unique node identifier within scene
- **speaker**: Speaker identifier or display name
- **text**: Dialog text content

### Optional Node Properties

- **next**: Direct navigation to next node (for non-choice nodes)
- **choices**: Array of choice objects (for branching nodes)
- **emotional_state**: Initial emotional state for this node
- **effects**: Effects applied when node is reached

## Choice Structure

Choices represent player options and branch points:

```json
{
    "id": "choice_001a",
    "text": "The flagship? After twenty years? All crew, battle stations.",
    "next": "chen_002a",
    "conditions": {...},
    "skill_check": {...},
    "effects": {...}
}
```

### Required Choice Properties

- **id**: Unique choice identifier within scene
- **text**: Choice display text
- **next**: Target node ID or "end_scene"

### Optional Choice Properties

- **conditions**: Conditions for choice availability
- **skill_check**: Skill check configuration
- **effects**: Effects applied when choice is selected

## Conditions System

Conditions determine when choices are available or when certain logic triggers.

### Supported Condition Types

#### Background Conditions
```json
{
    "background": "void_touched"
}
```

#### Loop Count Conditions
```json
{
    "loop_count": ">10"
}
```
Supports operators: `>`, `>=`, `<`, `<=`, `=`

#### Stat Conditions
```json
{
    "intel": ">=3",
    "fuel": ">5"
}
```

#### Emotion Conditions
```json
{
    "emotions": {
        "chen_fear": ">2",
        "torres_trust": ">=0"
    }
}
```

#### Resource Conditions
```json
{
    "resources": {
        "fuel": ">5",
        "supplies": ">=2"
    }
}
```

#### Remembered Events
```json
{
    "remembered_event": "prometheus_disaster"
}
```

#### Flag Conditions
```json
{
    "phantom_attention": true,
    "crew_betrayal": false
}
```

#### Extended Conditions (Implementation-Specific)
```json
{
    "has_flag": "timeline_fracture",
    "crew_has": ["navigator_chen", "void_touched"],
    "skill_check_result": "success"
}
```

## Skill Check System

Skill checks provide dice-based challenge resolution:

```json
{
    "skill_check": {
        "type": "intelligence",
        "difficulty": 18,
        "contested": {
            "value": 15
        },
        "group_modifiers": [
            {
                "condition": {"void_touched": true},
                "delta": "+2"
            }
        ]
    }
}
```

### Skill Check Properties

- **type**: Skill type (intelligence, deception, engineering, etc.)
- **difficulty**: Target DC (1-30)
- **contested**: Optional contested check configuration
- **group_modifiers**: Conditional modifiers

### Supported Skill Types

#### Core Skills
- `intelligence` / `int`: INT-based checks
- `deception`: CHA-based deception
- `diplomacy`: CHA-based social interaction
- `engineering`: INT-based technical knowledge
- `leadership`: CHA-based command
- `willpower`: WIS-based mental resistance

#### Extended Skills (Implementation-Specific)
- `piloting`: Specialized navigation and ship handling
- `tech` / `engineering`: Technical systems and hacking
- `strength`: Physical power and endurance
- `group_athletics`: Team-based physical challenges

#### Special Skills
- `void_touched`: Special background modifier (+2 if flag is set)
- Background-based bonuses for specific character types

### Compound Skills

Combine multiple modifiers with `+`:
```json
{
    "type": "intelligence+void_touched"
}
```

## Effects System

Effects modify game state when nodes are reached or choices are selected.

### Direct Effects
```json
{
    "effects": {
        "chen_fear": 1,
        "torres_trust": -2,
        "fuel": -1,
        "crew_alert": "high"
    }
}
```

### Structured Effects

#### Increment Effects
```json
{
    "inc": {
        "intel": 2,
        "crew_morale": 1
    }
}
```

#### Decrement Effects  
```json
{
    "dec": {
        "fuel": 1,
        "supplies": 2
    }
}
```

#### Set Effects
```json
{
    "set": {
        "crew_alert": "maximum",
        "gate_access": true
    }
}
```

#### Chance Effects
```json
{
    "effect_chance": {
        "probability": 0.25,
        "effect": "phantom_attention"
    }
}
```

#### Delayed Effects
```json
{
    "effect_delayed": {
        "turns": 5,
        "type": "crew_betrayal",
        "who": "first_officer_torres"
    }
}
```

#### Scaling Effects
```json
{
    "scaling_effect": {
        "counter": "analysis_calls", 
        "effect": "insight_stacking",
        "scale_factor": 1.5
    }
}
```

## API Functions

### Core System Functions

#### `init_dialog_system()`
Initialize the dialog system and load scene index.

#### `load_dialog_scene(scene_id)`
Load a specific dialog scene by ID.
- **Returns**: `true` on success, `false` on failure

#### `start_dialog_scene(scene_id, starting_node_id = undefined)`
Start a dialog scene, optionally at a specific node.
- **Returns**: `true` on success, `false` on failure

#### `end_dialog_scene()`
End the current dialog scene and process completion effects.

### Navigation Functions

#### `goto_dialog_node(node_id)`
Navigate to a specific node within the current scene.
- **Returns**: `true` on success, `false` on failure

#### `get_current_dialog_node()`
Get the currently active dialog node.
- **Returns**: Node object or `undefined`

#### `find_dialog_node(node_id)`
Find a node by ID in the current scene.
- **Returns**: Node object or `undefined`

### Choice System

#### `get_available_choices()`
Get all available choices for the current node, filtered by conditions.
- **Returns**: Array of choice objects

#### `select_dialog_choice(choice)`
Select and process a dialog choice, applying effects and navigation.

#### `is_choice_available(choice)`
Check if a specific choice meets its conditions.
- **Returns**: `boolean`

### State Management

#### `set_dialog_flag(flag_name, value)`
Set a persistent dialog flag.

#### `get_dialog_flag(flag_name)`
Get a dialog flag value.
- **Returns**: Flag value or `false` if not set

#### `set_dialog_counter(counter_name, value)`
Set a numeric counter value.

#### `get_dialog_counter(counter_name)` 
Get a counter value.
- **Returns**: Counter value or `0` if not set

#### `set_dialog_resource(resource_name, value)`
Set a resource amount (fuel, supplies, etc.).

#### `get_dialog_resource(resource_name)`
Get a resource amount.
- **Returns**: Resource value or `0` if not set

#### `set_dialog_emotion(emotion_name, value)`
Set an NPC emotion level.

#### `get_dialog_emotion(emotion_name)`
Get an NPC emotion level.
- **Returns**: Emotion value or `0` if not set

### Condition Evaluation

#### `evaluate_dialog_conditions(conditions)`
Evaluate a conditions object against current game state.
- **Returns**: `true` if all conditions pass, `false` otherwise

#### `perform_skill_check(skill_check_data)`
Perform a skill check with d20 roll and modifiers.
- **Returns**: Result code (1=SUCCESS, 2=FAILURE, 3=CRITICAL_SUCCESS, 4=CRITICAL_FAILURE)

### Scene Management

#### `get_scene_list()`
Get list of all available scene IDs.
- **Returns**: Array of scene ID strings

#### `get_scene_display_name(scene_id)`
Convert scene ID to display name.
- **Returns**: Formatted display name string

#### `load_scene_image(scene_id)`
Load background image for a scene.
- **Returns**: `true` on success, `false` on failure

### Progression System

#### `handle_dialog_scene_completion(scene_id, scene_effects)`
Process scene completion for star map progression and unlocks.

#### `increment_loop_count()`
Increment the meta-gaming loop counter.

## Integration Requirements

### Required Objects in Room

- **obj_DialogManager**: Must be present for dialog UI rendering
- **obj_Player**: Required for skill check modifiers

### Global Variables

The system manages these global variables automatically:
- `global.dialog_flags`: Persistent boolean flags
- `global.dialog_counters`: Numeric counters  
- `global.dialog_reputation`: Faction standings
- `global.dialog_resources`: Resource amounts
- `global.dialog_emotions`: NPC emotional states
- `global.loop_count`: Meta-gaming loop counter
- `global.player_background`: Character background

### File Structure

```
datafiles/dialogs/
├── _index.json                 # Scene registry
├── _metadata.json              # System metadata
├── scene_001_*.json           # Scene files
├── scene_002_*.json
└── images/                     # Scene background images
    ├── 001.png                # Legacy numbered format
    ├── scene_001_*.png        # New named format
    └── ...
```

## Best Practices

### Scene Design

1. **Node IDs**: Use descriptive, unique IDs (`chen_001`, `torres_response_angry`)
2. **Speaker Names**: Consistent speaker identifiers for NPCs
3. **Text Length**: Keep dialog text under 200 characters for readability
4. **Choice Limits**: Maximum 6 choices per node for UI constraints

### Condition Design

1. **Balanced Gating**: Don't lock players out of progression paths
2. **Clear Requirements**: Make skill check requirements obvious
3. **Fallback Paths**: Always provide alternative routes

### Effects Design

1. **Meaningful Impact**: Effects should feel consequential
2. **State Consistency**: Track related stats together
3. **Progression Logic**: Link effects to unlock conditions

### Performance

1. **Scene Size**: Keep individual scenes under 100 nodes
2. **Asset Loading**: Optimize background image sizes
3. **State Cleanup**: Reset temporary flags between scenes

## Example Usage

```gml
// Initialize system
init_dialog_system();

// Start a scene
if (start_dialog_scene("scene_001_prometheus_discovery")) {
    // Scene started successfully
    var current_node = get_current_dialog_node();
    var choices = get_available_choices();
    
    // Process player choice
    if (array_length(choices) > 0) {
        select_dialog_choice(choices[0]);
    }
}

// Check state
if (get_dialog_flag("prometheus_explored")) {
    unlock_star_system("system_002");
}
```

This dialog system provides a flexible foundation for complex narrative experiences while maintaining clear structure and extensibility.

## Changelog

### Dialog System Fixes Applied

#### Critical Fixes (Completed)

**Contested Skill Check Format Standardization**
Fixed non-compliant contested skill check format in 5 scene files:

1. **scene_002_keth_mori_threshold.json** - Node: `shal_meta_response_003`
   - **Before**: `"type": "contested_check", "skill": "willpower", "vs": "archive_containment_field", "vs_difficulty": 16`
   - **After**: `"type": "willpower", "contested": {"npc": "archive_containment_field", "value": 16}`

2. **scene_010_earth_debrief_pact.json** - Node: `holt_meta_response`  
   - **Before**: `"type": "contested_check", "skill": "willpower", "vs": "holt_interrogation", "vs_difficulty": 17`
   - **After**: `"type": "willpower", "contested": {"npc": "holt_interrogation", "value": 17}`

3. **scene_012_prometheus_logs.json** - Node: `logs_decryption`
   - **Before**: `"type": "contested_check", "skill": "computer_science", "vs": "data_corruption", "vs_difficulty": 15`
   - **After**: `"type": "engineering", "contested": {"npc": "data_corruption", "value": 15}`
   - **Note**: Also updated skill type from non-standard `computer_science` to standard `engineering`

4. **scene_023_collapse_escape.json** - Node: `escape_chen_power_reroute_013`
   - **Before**: `"type": "contested_check", "skill": "engineering", "vs": "collapse_rate", "vs_difficulty": 16`
   - **After**: `"type": "engineering", "contested": {"npc": "collapse_rate", "value": 16}`

5. **scene_024_fractured_space_entry.json** - Node: `fracture_direct_prelude_008`
   - **Before**: `"type": "contested_check", "skill": "piloting+shields", "vs": "fracture_turbulence", "vs_difficulty": 17`
   - **After**: `"type": "piloting", "contested": {"npc": "fracture_turbulence", "value": 17}`
   - **Note**: Removed compound skill `piloting+shields` to use standard `piloting` skill

#### API Documentation Updates

- **Extended Skill Types**: Documented implementation-specific skills found in scenes (`piloting`, `tech`, `strength`, `group_athletics`)
- **Extended Conditions**: Documented implementation-specific conditions (`has_flag`, `crew_has`, `skill_check_result`)
- **Standardization**: All contested skill checks now follow consistent format

#### Compliance Status

- **Before Fixes**: 30 scene files had structural compliance, 5 had critical issues
- **After Fixes**: 35 scene files fully structurally compliant
- **Remaining**: 113 minor formatting warnings (direct effects vs structured effects)

The dialog system now maintains full API compliance across all scene files while preserving the rich gameplay mechanics and narrative complexity.