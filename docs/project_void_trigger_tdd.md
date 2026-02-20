# Project Void-Trigger — Technical Design Document (Phase 1)

## Brief
This document defines the architecture baseline for a modular Godot 4.x top-down shooter using typed GDScript, signal-driven communication, and composition-focused scene design.

## 1) Node Tree Mapping

### 1.1 `main.tscn` (World Root)
- `Node2D` (`Main`)
  - `Node2D` (`World`)
    - `Node2D` (`SpawnPoints`) — optional child `Marker2D` nodes for enemy spawn locations
    - `Node` (`Managers`)
      - `Node` (`GameManager`)
      - `Node` (`SpawnManager`)
      - `Node` (`ScoreManager`)
    - `NavigationRegion2D` (`Navigation`) — optional for AI navigation scaling
  - `CanvasLayer` (`UI`)
    - `Control` (`HUD`)

### 1.2 `scenes/actors/player.tscn`
- `CharacterBody2D` (`Player`)
  - `Sprite2D` (`BodySprite`)
  - `CollisionShape2D` (`BodyCollision`)
  - `Marker2D` (`Muzzle`) — projectile spawn origin, placed ahead of collider
  - `Node` (`Components`)
    - `Node` (`HealthComponent`)
    - `Area2D` (`HitboxComponent`)
      - `CollisionShape2D` (`HitboxCollision`)

### 1.3 `scenes/actors/enemy_basic.tscn`
- `CharacterBody2D` (`EnemyBasic`)
  - `Sprite2D` (`BodySprite`)
  - `CollisionShape2D` (`BodyCollision`)
  - `NavigationAgent2D` (`NavigationAgent`)
  - `Node` (`Components`)
    - `Node` (`HealthComponent`)
    - `Area2D` (`HitboxComponent`)
      - `CollisionShape2D` (`HitboxCollision`)

### 1.4 `scenes/projectiles/bullet.tscn`
- `Area2D` (`Bullet`)
  - `Sprite2D` (`BulletSprite`)
  - `CollisionShape2D` (`BulletCollision`)
  - `VisibleOnScreenNotifier2D` (`ScreenNotifier`) — frees projectile when leaving view

### 1.5 `scenes/ui/hud.tscn`
- `Control` (`HUD`)
  - `MarginContainer` (`TopBar`)
    - `HBoxContainer` (`StatsRow`)
      - `Label` (`ScoreLabel`)
      - `Label` (`HealthLabel`)
  - `CenterContainer` (`OverlayCenter`)
    - `Label` (`GameOverLabel`)

## 2) Signal Bus Definition (Global)

`SignalBus` is an AutoLoad singleton in `scripts/autoloads/signal_bus.gd`.

### 2.1 Global Signals
- `player_spawned(player: CharacterBody2D)`
- `player_damaged(current_health: float, max_health: float)`
- `player_died()`
- `enemy_spawned(enemy: CharacterBody2D)`
- `enemy_died(enemy_position: Vector2, score_value: int)`
- `projectile_fired(origin: Vector2, direction: Vector2, source_group: StringName)`
- `score_changed(new_score: int)`
- `game_state_changed(previous_state: int, new_state: int)`
- `restart_requested()`

### 2.2 Ownership Rules
- **Emitters:** domain owners emit (e.g., `HealthComponent` emits local damage/death, entity script forwards to `SignalBus`).
- **Listeners:** managers/UI listen to `SignalBus`; actors avoid direct manager references.
- **Payload Principle:** send minimal immutable data (primitive values and vectors), not deep node dependencies.

## 3) Game State Management

`GameManager` owns finite state flow using:

```gdscript
enum GameState {
    START,
    PLAYING,
    GAMEOVER
}
```

### 3.1 State Responsibilities
- **START**
  - Reset score/round timers.
  - Spawn player.
  - Transition to `PLAYING` after init frame.
- **PLAYING**
  - Enable enemy spawning and score accrual.
  - Process combat signals.
  - Transition to `GAMEOVER` on `SignalBus.player_died`.
- **GAMEOVER**
  - Disable spawners and actor inputs.
  - Show UI overlay and await `restart_requested`.
  - Reload scene or hard-reset managers, then return to `START`.

### 3.2 Transition Contract
- Every transition must call a single `change_state(next_state: GameState) -> void`.
- `change_state` emits `SignalBus.game_state_changed(previous_state, next_state)`.
- Side-effects live in per-state handlers: `_enter_start`, `_enter_playing`, `_enter_gameover`.

## 4) Data-Driven Resource Strategy

All tweakable combat values use resources under `scripts/resources/`:
- `weapon_stats.gd` + `.tres` instances for fire rate, speed, spread, projectile scene.
- `enemy_stats.gd` + `.tres` instances for HP, speed, score value, contact damage.
- `spawn_wave.gd` + `.tres` instances for enemy type mix and cadence.

This supports scaling (e.g., shotgun, fast enemy) by adding resource instances without changing core systems.

## 5) Collision Layer Matrix (MVP)

- Layer 1: World/Obstacles
- Layer 2: Enemy bodies/hitboxes
- Layer 3: Player bodies/hitboxes
- Layer 4: Player projectiles
- Layer 5: Enemy projectiles

Rules:
- Player bullets (Layer 4) mask Layer 2.
- Enemy bullets (Layer 5) mask Layer 3.
- Enemy contact hitbox masks Layer 3.
- Player hitbox masks Layer 2 and Layer 5 as needed.

## 6) Implementation Sprint Plan (Phase 2 Sequence)

1. Foundations: AutoLoad `SignalBus`, `GameManager`, reusable `HealthComponent` + `HitboxComponent`.
2. Player actor: WASD movement, mouse-facing rotation, fire-rate throttled weapon controller.
3. Projectile: typed velocity, lifetime/off-screen cleanup, damage payload on collision.
4. Enemy actor: simple chase via `NavigationAgent2D` (or direct vector chase fallback), health + death signal.
5. World loop: `SpawnManager`, score updates, restart workflow.
6. HUD: signal-driven health/score/game-over bindings.

## 7) Verification Checklist (Phase 1 readiness)

- Confirm every planned gameplay system has one owner node and one communication path (prefer signals).
- Confirm no manager singletons are directly referenced by actors except `SignalBus`.
- Confirm `Muzzle` marker is placed outside player collider to avoid immediate projectile overlap.
- Confirm collision layers/masks are documented and consistent before creating scenes.
- Confirm all planned scripts will use typed signatures (`-> void`, `float`, `Vector2`, etc.).
