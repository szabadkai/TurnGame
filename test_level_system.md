# Enhanced D&D Level-Up System - Test Guide

## System Components Implemented

### 1. **Ability Scores System**
- ✅ Six core ability scores: STR, DEX, CON, INT, WIS, CHA
- ✅ Ability modifiers calculated as `floor((score - 10) / 2)`
- ✅ Different starting stats for each character archetype:
  - Aria: STR-focused fighter [14,13,12,10,11,9]
  - Bran: DEX-focused ranger [12,14,11,9,13,10]  
  - Cora: CON-focused tank [13,12,14,11,10,9]
  - Dex: INT-focused strategist [10,11,12,14,13,9]
  - Erin: WIS-focused cleric [11,10,13,12,14,9]

### 2. **Proficiency Bonus Progression**
- ✅ D&D 5e progression: +2 (1-4), +3 (5-8), +4 (9-12), +5 (13-16), +6 (17-20)
- ✅ Applies to attack rolls automatically

### 3. **Combat System Integration**
- ✅ Attack bonus = proficiency + STR/DEX mod + weapon bonus
- ✅ Damage modifier = STR/DEX mod + weapon bonus  
- ✅ Armor Class = base AC + DEX mod + special bonuses
- ✅ Finesse weapons (Rapier, Assassin's Blade) use DEX instead of STR

### 4. **HP Calculation**
- ✅ Players: 8 + CON mod at level 1, then 5 + CON mod per level
- ✅ Enemies: 3 + CON mod (using d6 hit die)
- ✅ Retroactive HP adjustment when CON increases

### 5. **Ability Score Improvement (ASI)**
- ✅ Available at levels 4, 8, 12, 16, 20
- ✅ Interactive overlay with +/- buttons
- ✅ Distribute 2 points: two abilities +1 each OR one ability +2
- ✅ Maximum ability score of 20
- ✅ Automatic trigger on level-up for ASI levels
- ✅ Manual access via 'I' key if ASI pending

### 6. **Enhanced Player Details**
- ✅ Shows all ability scores with modifiers
- ✅ Displays proficiency bonus
- ✅ Combat stat breakdown (Prof + Ability + Weapon)
- ✅ "[ASI AVAILABLE]" indicator when pending

### 7. **XP Balance Adjustments**
- ✅ Increased enemy XP values for faster testing: 60, 75, 50, 85, 40
- ✅ Maintained 1.2x scaling per level

## Test Scenarios

### **Test 1: Basic Level Up (Level 1→2)**
1. Start new game
2. Kill 2 enemies (should gain ~120-170 XP)
3. Verify level up message shows HP gain and proficiency (should stay +2)
4. Check player details to see updated stats

### **Test 2: First ASI (Level 1→4)**  
1. Kill enough enemies to reach level 4 (~400+ XP)
2. Verify ASI overlay automatically appears
3. Test +/- buttons to allocate 2 points
4. Try invalid operations (exceed 20, allocate >2 points)
5. Confirm and verify stats updated

### **Test 3: Proficiency Increase (Level 1→5)**
1. Reach level 5 (~600+ XP)
2. Verify proficiency bonus increases from +2 to +3
3. Check that attack bonuses updated accordingly
4. Verify ASI available at level 4 if not used

### **Test 4: CON Increase HP Bonus**
1. At ASI level, increase Constitution by +2
2. Verify retroactive HP gain (level × CON mod increase)
3. Check max HP and current HP both increased

### **Test 5: Multiple Characters**
1. Verify each character has different starting ability scores
2. Test party-wide XP distribution still works
3. Verify different characters can have different ASI states

### **Test 6: Combat Integration**
1. Test DEX-based weapons (Rapier) use DEX for attacks
2. Test STR-based weapons use STR for attacks  
3. Verify AC calculation includes DEX modifier
4. Test damage calculation uses appropriate ability mod

## Manual Testing Steps

### Quick Level 4 Test:
```
1. Start game
2. Press 'I' to check initial stats
3. Kill 6-7 enemies (should reach level 4)
4. ASI overlay should appear automatically
5. Allocate +1 STR, +1 CON
6. Confirm and check updated stats
```

### Combat Stats Verification:
```
1. Note initial attack bonus in details page
2. Level up and increase STR/DEX
3. Switch weapons to test finesse vs. regular
4. Verify attack bonus calculation matches displayed formula
```

The system is now ready for comprehensive testing with D&D-style progression mechanics!