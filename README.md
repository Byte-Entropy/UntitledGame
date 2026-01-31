
# Isometric Souls-like (2D) — Project Roadmap

**Engine:** Godot 4.x  
**Language:** GDScript  
**Art Style:** Pixel Art / Isometric (2:1 projection)  
**Core Mechanics:** Stamina management, precise combat, Z-axis simulation

---

## Phase 1 — Core Foundation *(Current Status)*

**Goal:** A character that feels good to control, interacts with the "fake" 3D world correctly, and manages resources.

### 1.1 Physics & Projection
- [x] **Input Map:** Configure WASD (Movement) + Shift (Sprint) + Space (Action/Jump)
- [x] **Isometric Math:** Convert Cartesian inputs (WASD) into Isometric vectors (Cartesian to Iso)
- [x] **Collision:** Setup CharacterBody2D collision box (feet only) for accurate depth
- [x] **Camera:** Implement Camera2D with position smoothing (child of Player or RemoteTransform)

### 1.2 Movement & State Machine
- [x] **State Machine V1:** Implement Enum-based states (IDLE, MOVE, JUMP)
- [x] **Visuals:** Implement "Bobbing" sine-wave animation for walking
- [x] **Directional Sprites:** 4-Directional sprite swapping based on velocity
- [x] **Z-Axis Simulation:** Visual jumping (sprite.y offset) independent of physics collision

### 1.3 Resource Management
- [x] **Stamina System:** Drain on sprint/jump, regen on idle
- [x] **UI Integration:** TextureProgressBar anchored to screen (HUD)
- [ ] **Stamina Polish:** Add "Exhausted" state (cannot sprint until stamina > 20%)

---

## Phase 2 — Combat Architecture

**Goal:** Implement the "Crunch" — hitting things and getting hit.

### 2.1 Advanced Movement (The "Souls" Feel)
- [ ] **Dodge Roll:** Add ROLL state with high velocity burst and ignoring input during animation
- [ ] **I-Frames:** Implement "Invincibility Frames" during the middle of the roll
- [ ] **Hit Stop:** Tiny time freeze (0.1s) when damage is dealt for impact

### 2.2 Hitbox/Hurtbox System
- [ ] **Hurtbox Class:** Create a standardized Area2D class that receives damage (used by Player and Enemies)
- [ ] **Hitbox Class:** Create a standardized Area2D class that deals damage
- [ ] **Signal Bus:** Connect on_area_entered to subtract HP

### 2.3 Player Combat
- [ ] **Attack State:** Add ATTACK state that stops movement
- [ ] **Combo System:** Allow chaining 2-3 attacks if clicked with correct timing
- [ ] **Visuals:** Add weapon swipe sprites or separate weapon pivot rotation

---

## Phase 3 — World & Elevation *(The "Isometric Illusion")*

**Goal:** Solving the hardest part of 2D isometric games—height and depth.

### 3.1 Depth Sorting
- [x] **Y-Sort:** Configure TileMapLayers and Actors for correct occlusion
- [ ] **Transparency:** Detect when Player is behind a wall and turn the wall semi-transparent

### 3.2 "Fake" Elevation (Stairs/Cliffs)
- [ ] **Elevation Logic:** Create a variable `current_layer` (0, 1, 2)
- [ ] **Collision Masks:** Change collision masks dynamically (e.g., on Layer 1, ignore Layer 0 walls)
- [ ] **Stairs Triggers:** Area2D zones that transition z_height and current_layer smoothly

### 3.3 Level Design
- [ ] **TileSet Setup:** Define collision polygons for walls, pits, and water
- [ ] **Navigation:** Bake NavigationRegion2D for enemy pathfinding

---

## Phase 4 — Enemies & AI

**Goal:** Creating resistance.

### 4.1 Basic Enemy (The "Slime")
- [ ] **Stats:** HP, Damage, Speed
- [ ] **Detection:** Area2D ("Aggro Range") to detect Player
- [ ] **Behavior:** Simple "Move Toward" logic

### 4.2 Advanced AI (The "Knight")
- [ ] **State Machine:** Idle → Patrol → Chase → Attack → Stunned
- [ ] **Pathfinding:** Use NavigationAgent2D to avoid walls while chasing
- [ ] **Telegraphing:** Visual flash before attacking to give Player time to dodge

---

## Phase 5 — Systems & Polish

**Goal:** Turning a prototype into a game loop.

### 5.1 Interactive Objects
- [ ] **Interactable Class:** Press 'E' to talk/open
- [ ] **Chests:** Animation + Loot drop
- [ ] **Bonfires:** Save point that respawns enemies and refills potions

### 5.2 NPC & Dialogue
- [ ] **Dialogue System:** Simple JSON or Resource-based text parser
- [ ] **UI:** Typing effect for text display

### 5.3 Menus & Persistence
- [ ] **Main Menu:** Start, Settings (Audio/Controls), Quit
- [ ] **Pause Menu:** Freeze Engine.time_scale
- [ ] **Save System:** Save Player Position, Stats, and Inventory to `user://savegame.json`

---

## Phase 6 — Juice *(Visual Feedback)*

**Goal:** Make it feel professional.

- [ ] **Particles:** Dust clouds when running/rolling
- [ ] **Screen Shake:** On taking damage or heavy attacks
- [ ] **Lighting:** PointLight2D for torches and atmosphere
- [ ] **Audio:** Footsteps (synced to bobbing), Swing SFX, Impact SFX