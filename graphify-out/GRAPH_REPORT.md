# Graph Report - video-game-project  (2026-10-14)

## Corpus Check
- 36 files · ~1,248,522 words
- Verdict: corpus is large enough that graph structure adds value.
- Unclassified: 1809 file(s) not represented in the graph (top: .uid 455, .gd 425, .import 348)

## Summary
- 592 nodes · 919 edges · 34 communities (22 shown, 12 thin omitted)
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 6 edges (avg confidence: 0.85)
- Token cost: 0 input · 0 output

## Graph Freshness
- Built from commit: `7ba0d0b6`
- Run `git rev-parse HEAD` and compare to check if the graph is stale.
- Run `graphify update .` after code changes (no API cost).

## Community Hubs (Navigation)
- DialogueManager
- godot
- PhantomCamera3D
- PhantomCamera
- ExampleBalloon
- StringName
- PhantomCamera2D
- DialogueLine
- Camera3DResource
- PhantomCameraNoise3D
- PhantomCameraNoiseEmitter2D
- TweenDirectorResource
- LimboAI - Behavior Trees & State Machines for Godot 4
- PhantomCamera3DExtensions
- LimitTargetQueryResult
- FollowLockAxis3D
- Node2D
- FollowMode3D
- Terrain3D
- HammerForge
- FollowMode2D
- FollowLockAxis2D
- LookAtMode
- Zombie AI prototype
- Project working preferences
- MOVEMENT_PROTOTYPE.md
- README.md

## God Nodes (most connected - your core abstractions)
1. `PhantomCamera3D` - 74 edges
2. `PhantomCamera2D` - 57 edges
3. `DialogueManager` - 56 edges
4. `DialogueLine` - 29 edges
5. `PhantomCamera` - 29 edges
6. `ExampleBalloon` - 22 edges
7. `PhantomCameraHost` - 21 edges
8. `Camera3DResource` - 19 edges
9. `PhantomCameraNoise3D` - 19 edges
10. `DialogueLabel` - 18 edges

## Surprising Connections (you probably didn't know these)
- `ExampleBalloon` --references--> `DialogueLine`  [EXTRACTED]
  addons/dialogue_manager/example_balloon/ExampleBalloon.cs → addons/dialogue_manager/DialogueManager.cs
- `DialogueLabel` --references--> `DialogueLine`  [EXTRACTED]
  addons/dialogue_manager/nodes/dialogue_label/DialogueLabel.cs → addons/dialogue_manager/DialogueManager.cs
- `PhantomCameraManager` --references--> `PhantomCamera2D`  [EXTRACTED]
  addons/phantom_camera/scripts/managers/PhantomCameraManager.cs → addons/phantom_camera/scripts/phantom_camera/PhantomCamera2D.cs
- `PhantomCameraManager` --references--> `PhantomCamera3D`  [EXTRACTED]
  addons/phantom_camera/scripts/managers/PhantomCameraManager.cs → addons/phantom_camera/scripts/phantom_camera/PhantomCamera3D.cs
- `PhantomCamera2D` --inherits--> `PhantomCamera`  [EXTRACTED]
  addons/phantom_camera/scripts/phantom_camera/PhantomCamera2D.cs → addons/phantom_camera/scripts/phantom_camera/PhantomCamera.cs

## Import Cycles
- None detected.

## Communities (34 total, 12 thin omitted)

### Community 0 - "DialogueManager"
Cohesion: 0.07
Nodes (14): DialogueManager, AssemblyTypes, GameStates, GetCurrentScene, IgnoreMissingStateValues, IncludeClasses, IncludeDialogueResourceAsSelf, IncludeSingletons (+6 more)

### Community 1 - "godot"
Cohesion: 0.07
Nodes (17): MutationBehaviour, DoNotWait, Skip, Wait, TranslationSource, CSV, Guess, None (+9 more)

### Community 2 - "PhantomCamera3D"
Cohesion: 0.04
Nodes (42): PhantomCamera3D, Attributes, AutoFollowDistance, AutoFollowDistanceDivisor, AutoFollowDistanceMax, AutoFollowDistanceMin, CollisionMask, CullMask (+34 more)

### Community 3 - "PhantomCamera"
Cohesion: 0.05
Nodes (43): InactiveUpdateMode, Always, Never, PhantomCamera, DeadZoneHeight, DeadZoneWidth, FollowDamping, HostLayers (+35 more)

### Community 4 - "ExampleBalloon"
Cohesion: 0.09
Nodes (7): ExampleBalloon, DialogueLine, DialogueLabel, DialogueLine, IsTyping, DialogueResponsesMenu, Responses

### Community 5 - "StringName"
Cohesion: 0.06
Nodes (29): MethodName, PhantomCameraManager, Instance, PhantomCamera2Ds, PhantomCamera3Ds, PhantomCameraHosts, InterpolationMode, Auto (+21 more)

### Community 6 - "PhantomCamera2D"
Cohesion: 0.06
Nodes (33): PhantomCamera2D, AutoZoom, AutoZoomMargin, AutoZoomMax, AutoZoomMin, DrawLimits, FollowAxisLock, FollowDampingValue (+25 more)

### Community 7 - "DialogueLine"
Cohesion: 0.07
Nodes (21): DialogueLine, Character, ConcurrentLines, ExtraGameStates, Id, InlineMutations, NextId, Responses (+13 more)

### Community 8 - "Camera3DResource"
Cohesion: 0.06
Nodes (21): DialogueMarker2D, DialogueMarker3D, Camera3DResource, CullMask, Far, Fov, FrustumOffset, HOffset (+13 more)

### Community 9 - "PhantomCameraNoise3D"
Cohesion: 0.07
Nodes (22): MethodName, PhantomCameraNoiseEmitter3D, Continuous, DecayTime, Duration, GrowthTime, Noise, NoiseEmitterLayer (+14 more)

### Community 10 - "PhantomCameraNoiseEmitter2D"
Cohesion: 0.08
Nodes (19): MethodName, PhantomCameraNoiseEmitter2D, Continuous, DecayTime, Duration, GrowthTime, Noise, NoiseEmitterLayer (+11 more)

### Community 11 - "TweenDirectorResource"
Cohesion: 0.09
Nodes (16): MethodName, PhantomCameraTweenDirector, TweenDirector, MethodName, TweenDirectorResource, FromPhantomCameras, FromTweenResources, FromType (+8 more)

### Community 12 - "LimboAI - Behavior Trees & State Machines for Godot 4"
Cohesion: 0.13
Nodes (14): Compiling from source, Contributing, Demonstration, Features, First steps, For GDExtension, Getting LimboAI, License (+6 more)

### Community 14 - "LimitTargetQueryResult"
Cohesion: 0.25
Nodes (3): LimitTargetQueryResult, IsCollisionShape2D, IsTileMapLayer

### Community 15 - "FollowLockAxis3D"
Cohesion: 0.22
Nodes (9): FollowLockAxis3D, None, X, XY, XYZ, XZ, Y, YZ (+1 more)

### Community 17 - "FollowMode3D"
Cohesion: 0.25
Nodes (8): FollowMode3D, Framed, Glued, Group, None, Path, Simple, ThirdPerson

### Community 18 - "Terrain3D"
Cohesion: 0.25
Nodes (7): Contributing, Credit, Features, Games Using Terrain3D, Getting Started, License, Terrain3D

### Community 19 - "HammerForge"
Cohesion: 0.29
Nodes (6): Enable it, HammerForge, Links, Upgrading, What this plugin writes, Your first level

### Community 20 - "FollowMode2D"
Cohesion: 0.29
Nodes (7): FollowMode2D, Framed, Glued, Group, None, Path, Simple

### Community 22 - "FollowLockAxis2D"
Cohesion: 0.40
Nodes (5): FollowLockAxis2D, None, X, Xy, Y

### Community 23 - "LookAtMode"
Cohesion: 0.40
Nodes (5): LookAtMode, Group, Mimic, None, Simple

### Community 24 - "Zombie AI prototype"
Cohesion: 0.40
Nodes (4): Behavior, Integration, Validation, Zombie AI prototype

## Knowledge Gaps
- **256 isolated node(s):** `Wait`, `DoNotWait`, `Skip`, `None`, `Guess` (+251 more)
  These have ≤1 connection - possible missing edges or undocumented components. (Counts symbols only; 352 node(s) total have ≤1 connection when file, concept and rationale nodes are included.)
- **12 thin communities (<3 nodes) omitted from report** — run `graphify query` to explore isolated nodes.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `PhantomCamera3D` connect `PhantomCamera3D` to `godot`, `PhantomCamera`, `StringName`, `Camera3DResource`, `PhantomCameraNoise3D`, `PhantomCamera3DExtensions`, `FollowLockAxis3D`, `FollowMode3D`, `Node3D`, `LookAtMode`, `.EmitNoise`?**
  _High betweenness centrality (0.245) - this node is a cross-community bridge._
- **What connects `Wait`, `DoNotWait`, `Skip` to the rest of the system?**
  _256 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `DialogueManager` be split into smaller, more focused modules?**
  _Cohesion score 0.06915113871635611 - nodes in this community are weakly interconnected._
- **Why does `PhantomCamera2D` connect `PhantomCamera2D` to `godot`, `PhantomCamera`, `StringName`, `Camera3DResource`, `PhantomCameraNoiseEmitter2D`, `TweenDirectorResource`, `LimitTargetQueryResult`, `Node2D`, `FollowMode2D`, `FollowLockAxis2D`, `.GetLimit`, `.EmitNoise`?**
  _High betweenness centrality (0.181) - this node is a cross-community bridge._
- **Should `godot` be split into smaller, more focused modules?**
  _Cohesion score 0.06938775510204082 - nodes in this community are weakly interconnected._
- **Why does `PhantomCamera` connect `PhantomCamera` to `DialogueManager`, `godot`, `PhantomCamera3D`, `StringName`, `PhantomCamera2D`?**
  _High betweenness centrality (0.135) - this node is a cross-community bridge._
- **Should `PhantomCamera3D` be split into smaller, more focused modules?**
  _Cohesion score 0.0425531914893617 - nodes in this community are weakly interconnected._