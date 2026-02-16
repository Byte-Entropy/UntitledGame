# Isometric Souls-like (2D) — Project Roadmap

## Project Summary

A 2D action RPG built in `Godot 4.x` focused on high-stakes combat, stamina management, and "fake" 3D depth. The game uses a 2:1 isometric projection to create a sense of verticality and exploration typical of the "Souls" genre.

- **Engine:** `Godot 4.x`
- **Language:** `GDScript`
- **Art Style:** Pixel Art / Isometric

---

## Current Status

> We are currently in the transition between Phase 1 (Core Foundation) and Phase 2 (Combat).

- **Active Sprint:** Implementing I-Frames for dodging and finishing the Y-Sort depth system.
- **Recent Milestone:** Standardized Hitbox/Hurtbox system completed.

---

## 1. Core Logic & Mechanics

This section covers the "under the hood" systems and player interactions.

### Movement & Physics

- Custom Cartesian-to-Isometric vector conversion.
- State Machine: `IDLE`, `MOVE`, `JUMP`, `ROLL`, and `ATTACK`.
- Z-Axis Simulation: Visual jumping independent of ground collision.

### Combat Systems

- Impact & Stagger: Heavy hits interrupt enemy actions or player movement.
- Stamina Management: Resource drain for sprinting, jumping, and rolling.
- Armor Weight: Equipment affects movement speed and dodge efficiency.

### Interaction & Persistence

- Swords in Stones: Acts as the primary saving mechanic and world checkpoint.
- Environmental Interaction: Terrain effects like water slowing movement or grass hiding entities.

---

## 2. World Design & Art

Focuses on the "Isometric Illusion" and the progression of the game world.

### Perspective Puzzles

- Utilizing the 2:1 projection for verticality puzzles, hidden shortcuts, and ladders.
- Lever-based mechanics to alter the environment.

### Depth Management

- Dynamic Y-Sorting for actors and tile layers.
- Transparency triggers for occluded players behind walls.

### The World (Zones)

- **The Prairies:** A chill starting area with NPCs, shops, and minor slime threats.
- **The Forest:** Increased difficulty featuring bears and skeletons.
- **The Sunken Cathedral:** A magic-heavy zone filled with Deacons.
- **The Overgrown Fortress:** A semi-abandoned military site (Outskirts → Outer → Inner).
- **The Obsidian Peak:** The final imposing climb through snow and darkness.

---

## 3. Enemies & AI

The game features a variety of threats ranging from simple blobs to complex sentinels.

### Enemy Roster

- **Slimes:** Basic "Move Toward" AI found in the Prairies and Forest.
- **Skeletons & Bears:** Aggressive melee threats with telegraphing.
- **Deacons:** Magic-based ranged enemies.
- **Sentinels:** Advanced AI found guarding the Overgrown Fortress.

### AI Logic

- `NavigationAgent2D` for pathfinding around isometric obstacles.
- State-based behavior: `Idle` → `Patrol` → `Aggro` → `Attack`.

---

## 4. Roadmap & Future Tasks

- [ ] Visual Juice: Screen shake on heavy impact and dust particles for movement.
- [ ] Elevation Logic: Dynamic collision mask swapping for multi-layer stairs.
- [ ] Persistence: Save system for player stats and world state to `user://savegame.json`.