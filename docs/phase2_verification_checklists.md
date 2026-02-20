# Project Void-Trigger — Phase 2 Verification Checklists

## `scripts/autoloads/signal_bus.gd`
- Launch scene and verify no direct manager node dependencies are required for score/health UI updates.
- Confirm player death updates HUD without direct HUD references from actor scripts.
- Pitfall: Missing AutoLoad registration in `project.godot` will make all signal calls fail.

## `scripts/components/health_component.gd`
- Add temporary damage call in `_ready` and confirm `damaged` signal emits with decreasing values.
- Confirm `died` emits only when health reaches zero.
- Pitfall: Setting `max_health` after `_ready()` requires calling `reset_health()`.

## `scripts/components/hitbox_component.gd`
- Ensure hitbox collision shape overlaps actor bounds and receives projectile `Area2D` events.
- Confirm only areas exposing `get_damage()` affect health.
- Pitfall: Wrong `health_component_path` silently disables damage routing.

## `scripts/actors/player.gd`
- Verify WASD movement directions match screen orientation and speed feels responsive.
- Verify mouse-look rotates player toward cursor at all times.
- Verify hold-fire respects throttle (`fire_rate`) and does not spam infinitely.
- Pitfall: Place `Muzzle` outside player collider; otherwise bullets may self-collide.

## `scripts/projectiles/bullet.gd`
- Confirm projectile travels in fired direction and despawns on contact/lifetime timeout.
- Confirm bullets remove themselves when touching enemy hitboxes.
- Pitfall: If collision layer/mask mismatch, bullets pass through enemies.

## `scripts/actors/enemy_basic.gd`
- Confirm enemy acquires player target and chases continuously.
- Confirm enemy death emits score payload and enemy frees itself.
- Pitfall: Missing `NavigationAgent2D` or nav setup can stop movement; fallback may be needed for non-nav maps.

## Managers (`game_manager.gd`, `spawn_manager.gd`, `score_manager.gd`, `projectile_manager.gd`)
- Verify game flow: START → PLAYING, and PLAYING → GAMEOVER after player death.
- Verify enemy spawn cadence respects `spawn_interval` and `max_alive_enemies`.
- Verify score increments on enemy death and resets on restart.
- Verify pressing `R` in GAMEOVER respawns player and restarts spawning.
- Pitfall: Incorrect node paths in `main.tscn` exports break spawns/projectile parenting.

## `scripts/ui/hud.gd`
- Confirm score and health labels update from signals only.
- Confirm game over label appears only in GAMEOVER state.
- Pitfall: If `GameManager` class_name is missing, enum check in HUD fails.

## Collision Matrix Validation
- Layer 2: Enemies (`EnemyBasic` + enemy hitboxes).
- Layer 3: Player body/hitbox.
- Layer 4: Player bullets.
- Layer 5 reserved for enemy bullets.
- Verify masks: bullets target enemies, enemy contact targets player.
