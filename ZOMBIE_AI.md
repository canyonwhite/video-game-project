# Zombie AI prototype

Open this worktree's `project.godot` in Godot 4.7.2. Open
`src/scenes/zombie_test_room.tscn` and press F6. The existing main scene is unchanged.
Navigation is baked from the test room's static colliders at startup.

WASD / mouse: move and look. Shift: forward sprint. Ctrl/C: crouch.
Escape releases the cursor; click captures it. R resets health and the encounter.
H emits a test noise at your position (audible within the configured sight range).
Left click while aiming at the zombie within 3 m deals 20 damage: stagger it,
then kill it after three hits. The HUD displays player health and AI state.

## Behavior

The editable LimboAI resource is `ai/trees/zombie.tres`. Its dynamic selector
prioritizes death, stagger, committed attack, recognition, confirmed-target chase, last-seen
investigation/search, then idle. Tasks live in `ai/tasks`.
The zombie updates perception, blackboard, behavior tree, and movement in that order.
Only the actor calls `move_and_slide`, once per physics tick.

Sight uses range, horizontal/vertical field of view, and nine occlusion rays
across the upper body, torso, and legs, adjusted for the current crouch capsule.
At least eight of nine samples must be visible continuously for one second before
chase or a new attack can start. The zombie stays planted in RECOGNIZE during
this interval. A partial glimpse records a location and starts investigation;
any drop below the threshold resets recognition and investigates the last seen
position. Reacquisition requires a fresh full second. The HUD shows visibility
percentage and recognition progress. Tune `recognition_duration` and
`recognition_visibility_threshold` in the zombie Inspector. These samples are a
physics approximation of body visibility, not a screen-pixel measurement.
Lost targets do not update
the last-seen point. Attacks have a windup, one hit attempt, and a recovery period;
damage rechecks visibility, reach, and facing. Stagger and death interrupt attacks.
Noise supplies a location, not a continuously tracked player reference.

## Integration

Instance `src/scenes/zombie.tscn` in a level with baked navigation. Put the player
in the `player` group and provide `take_damage(amount)` for combat integration.
Layer 1 is world, layer 2 is player, layer 3 is zombie in this demo. Match sight
and movement masks to your real level. Zombie origin is at its feet; scale stays 1.
Configure speeds, sight, memory, search, and attack timing in the Inspector.
Use the `model_scene` export to replace the capsule with an imported model whose
feet are at the origin and whose front faces -Z. The current model is untracked
in the original checkout, so it is intentionally not copied into this worktree.
The demo player extends the existing movement script with health; production
movement and the production player scene are unchanged.

This is a single-enemy prototype: no animation/root motion, door handling,
crowd avoidance, or production weapon system. A dead zombie retains collision.
The noise and click-damage controls are testing helpers.

## Validation

Run `godot --headless --path . --script res://tests/zombie_ai_test.gd` after importing
the project. Tests cover perception, pathfinding, target memory, attack timing and
escape, stagger/death priority, and missing targets.

Behavior checks include recognition timing, visibility thresholds, interrupted
sightings, and close-range attack gating alongside the original combat/navigation cases.
An OpenGL render of the demo was also captured and inspected.
The initial headless editor import reported errors in the existing Terrain3D and
Asset Placer editor plugins; those plugins were not modified. They did not affect
the clean runtime demo or behavior test results.
