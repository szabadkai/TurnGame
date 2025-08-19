You are expanding a branching dialog system for a space exploration roguelike with time loop mechanics. The game features multiple playthroughs where certain characters become aware of previous timelines.

EXISTING DIALOG STRUCTURE:

- Each node has speaker, text, and choices
- Choices can have: conditions (background, skills, items, previous choices), skill_checks (type, difficulty), effects (reputation, flags, counters, path tracking)
- Special meta-awareness options appear after multiple playthroughs
- Effects cascade through the story affecting later encounters

EXPANSION REQUIREMENTS:

1. DEEPEN EXISTING BRANCHES:

- Add 2-3 intermediate nodes between major story beats
- Create "reconnaissance" options that gather info before committing to major choices
- Add "second thought" nodes where players can partially back out of decisions
- Include crew interjection nodes where other NPCs comment on your choices

2. ADD CONVERSATION MECHANICS:

- [Interrupt] options that cut NPCs off mid-speech with different outcomes
- [Remain Silent] choices that let NPCs reveal more information
- [Press Further] options that unlock only if you've gathered specific information
- [Bluff] options using false information from other playthroughs
- Timed responses where waiting too long auto-selects certain options

3. EXPAND CONDITIONAL BRANCHES:

- Crew combination conditions: "crew_has": ["navigator_chen", "void_touched"]
- Resource gates: "resources": {"fuel": ">5", "intel": ">3"}
- Reputation thresholds: "reputation": {"keth_mori": ">5", "earth": "<-3"}
- Timeline awareness: "loop_count": ">10", "remembered_death": true
- Relationship conditions: "torres_loyalty": "absolute", "maya_evolution": true

4. CREATE REACTIVE DIALOG:

- NPCs reference your previous choices in the conversation
- Dialog options that only appear if you've been contradicting yourself
- Stress accumulation system where lying too much changes available options
- NPCs remember if you've had this exact conversation in previous loops

5. ADD SKILL CHECK VARIETIES:

- Compound checks: "type": "intelligence+void_touched", "difficulty": 18
- Contested checks versus NPC stats
- Group checks where crew background affects difficulty
- Cascading checks where failure in one leads to harder checks later

6. ENHANCED EFFECTS:

- Delayed consequences: "effect_delayed": {"turns": 5, "type": "crew_betrayal"}
- Probability effects: "effect_chance": {"probability": 0.3, "effect": "phantom_attention"}
- Scaling effects based on how many times you've chosen this option across loops
- Hidden effects that don't show immediately but change future encounters

7. META-NARRATIVE INTEGRATION:
   For characters aware of loops, add:

- [Previous Loop] "Last time you said..." references
- [Shared Memory] Options where you both remember different timeline outcomes
- [Paradox] Choices that shouldn't be possible but are due to timeline fractures
- [Quantum Uncertainty] Multiple simultaneous responses that collapse into one

8. EMOTIONAL DEPTH:

- Track emotional states: fear, trust, hope, suspicion for each NPC
- Add body language descriptions: "chen_001_gesture": "hands trembling on console"
- Subtext hints: "[They're lying]", "[They know more]", "[They're testing you]"
- Relationship evolution: Choices that transform NPC attitudes permanently

EXAMPLE EXPANSION:
Take each existing scene and:

1. Add 2 intermediate conversation nodes
2. Include 1 skill check with cascading consequences
3. Add 1 meta-aware option for experienced players
4. Create 1 branch that only opens with specific crew/resources
5. Include emotional state tracking that affects available responses

For Scene 001 (Prometheus Discovery), add:

- A technical discussion node with Chen about the energy signatures
- Torres questioning your real motives (with deception checks)
- A loop-aware option where you already know what they'll find
- Resource-dependent choice to immediately scan for survivors
- Chen's fear level affecting whether they'll follow dangerous orders

OUTPUT FORMAT:
Maintain the exact JSON structure but expand each scene to 15-20 nodes minimum with deeper branching paths. Include new effects, conditions, and at least 3 different conversation endings per scene based on approach taken.
