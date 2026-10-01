extends CharacterBody3D

@export_group("Movement")
@export var walk_speed: float = 2.5
@export var sprint_speed: float = 4.1
@export var crouch_speed: float = 1.2

@export var acceleration: float = 12.0
@export var deceleration: float = 20.0

@export_range(0.1, 1.0) var backward_multiplier: float = 0.72
@export_range(0.1, 1.0) var strafe_multiplier: float = 0.85

@export_group("Mouse Look")
@export var mouse_sensitivity: float = 0.002
@export var pitch_limit_degrees: float = 85.0

@export_group("Crouching")
@export var standing_height: float = 1.8
@export var crouching_height: float = 1.1
@export var standing_eye_height: float = 1.65
@export var crouching_eye_height: float = 0.95
@export var crouch_transition_speed: float = 14.0

@export_group("Camera Feedback")
@export var head_bob_enabled: bool = true
@export var bob_amplitude: float = 0.012
@export var bob_phase_per_meter: float = 9.0
@export var camera_return_speed: float = 14.0
@export var landing_feedback_enabled: bool = true

@onready var collision: CollisionShape3D = $CollisionShape3D
@onready var head: Node3D = $Head
@onready var camera_effects: Node3D = $Head/CameraEffects

var capsule: CapsuleShape3D
var standing_query_shape: CapsuleShape3D

var is_crouching: bool = false
var is_sprinting: bool = false

var bob_phase: float = 0.0
var landing_offset: float = 0.0


# FUNCTIONS

func _ready() -> void:
    # Capsule resources can be shared between scene instances.
    # Duplicate this one before modifying its height.
    capsule = collision.shape.duplicate() as CapsuleShape3D
    collision.shape = capsule

    capsule.height = standing_height
    collision.position.y = standing_height * 0.5
    head.position.y = standing_eye_height

    # Slightly inset the standing query so touching the floor
    # doesn't incorrectly count as blocked overhead clearance.
    standing_query_shape = CapsuleShape3D.new()
    standing_query_shape.radius = capsule.radius
    standing_query_shape.height = standing_height - 0.04

    floor_snap_length = 0.25
    floor_constant_speed = true
    floor_stop_on_slope = true

    Input.mouse_mode = Input.MOUSE_MODE_CAPTURED

func _unhandled_input(event: InputEvent) -> void:
    if event.is_action_pressed("ui_cancel"):
        Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
        return

    if event is InputEventMouseButton:
        if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
            Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
        return

    if event is InputEventMouseMotion:
        if Input.mouse_mode != Input.MOUSE_MODE_CAPTURED:
            return

        # Yaw turns the body and therefore the walking direction.
        rotate_y(-event.screen_relative.x * mouse_sensitivity)

        # Pitch only turns the head.
        head.rotation.x -= event.screen_relative.y * mouse_sensitivity

        var limit := deg_to_rad(pitch_limit_degrees)
        head.rotation.x = clampf(head.rotation.x, -limit, limit)

func _physics_process(delta: float) -> void:
    var controls_active := (
        Input.mouse_mode == Input.MOUSE_MODE_CAPTURED
    )

    var movement_input := Vector2.ZERO

    if controls_active:
        movement_input = Input.get_vector(
            "left",
            "right",
            "forward",
            "backward"
        )

    _update_crouching(controls_active)

    _update_horizontal_velocity(
        movement_input,
        controls_active,
        delta
    )

    var was_on_floor := is_on_floor()

    if not was_on_floor:
        velocity += get_gravity() * delta
    elif velocity.y < 0.0:
        velocity.y = 0.0

    # Save the falling speed before collision modifies velocity.
    var vertical_speed_before_move := velocity.y

    move_and_slide()

    if landing_feedback_enabled:
        if not was_on_floor and is_on_floor():
            if vertical_speed_before_move < -2.0:
                landing_offset = -minf(
                    absf(vertical_speed_before_move) * 0.008,
                    0.06
                )

    _update_camera(delta)

func _update_horizontal_velocity(
    movement_input: Vector2,
    controls_active: bool,
    delta: float
) -> void:
    # Sprint only when moving mostly forward.
    is_sprinting = (
        controls_active
        and not is_crouching
        and Input.is_action_pressed("sprint")
        and movement_input.y < -0.5
    )

    var speed := walk_speed

    if is_crouching:
        speed = crouch_speed
    elif is_sprinting:
        speed = sprint_speed

    var local_direction := Vector3(
        movement_input.x * strafe_multiplier,
        0.0,
        movement_input.y
    )

    if movement_input.y > 0.0:
        local_direction.z *= backward_multiplier

    # The body rotates only around Y, so this stays horizontal.
    var target_velocity := global_basis * local_direction * speed

    var horizontal_velocity := Vector3(
        velocity.x,
        0.0,
        velocity.z
    )

    var change_rate := acceleration

    if movement_input.is_zero_approx():
        change_rate = deceleration

    horizontal_velocity = horizontal_velocity.move_toward(
        target_velocity,
        change_rate * delta
    )

    velocity.x = horizontal_velocity.x
    velocity.z = horizontal_velocity.z


func _update_crouching(controls_active: bool) -> void:
    var wants_to_crouch := (
        controls_active
        and Input.is_action_pressed("crouch")
    )

    if wants_to_crouch:
        _set_crouching(true)
    elif is_crouching and _can_stand():
        _set_crouching(false)


func _set_crouching(value: bool) -> void:
    if is_crouching == value:
        return

    is_crouching = value

    var height := standing_height

    if is_crouching:
        height = crouching_height

    # Keep the bottom of the capsule at the player's feet.
    capsule.height = height
    collision.position.y = height * 0.5


func _can_stand() -> bool:
    var query := PhysicsShapeQueryParameters3D.new()
    query.shape = standing_query_shape

    query.transform = Transform3D(
        global_basis,
        global_position + Vector3.UP * standing_height * 0.5
    )

    query.collision_mask = collision_mask
    query.exclude = [get_rid()]

    var hits := get_world_3d().direct_space_state.intersect_shape(
        query,
        1
    )

    return hits.is_empty()


func _update_camera(delta: float) -> void:
    var target_eye_height := standing_eye_height

    if is_crouching:
        target_eye_height = crouching_eye_height

    # Exponential smoothing behaves consistently across frame rates.
    var crouch_blend := 1.0 - exp(
        -crouch_transition_speed * delta
    )

    head.position.y = lerpf(
        head.position.y,
        target_eye_height,
        crouch_blend
    )

    var target_offset := Vector3.ZERO
    var actual_motion := get_position_delta()

    var horizontal_distance := Vector2(
        actual_motion.x,
        actual_motion.z
    ).length()

    if (
        head_bob_enabled
        and is_on_floor()
        and horizontal_distance > 0.0001
    ):
        bob_phase += horizontal_distance * bob_phase_per_meter

        var amplitude := bob_amplitude

        if is_crouching:
            amplitude *= 0.5
        elif is_sprinting:
            amplitude *= 1.25

        target_offset.x = (
            cos(bob_phase * 0.5) * amplitude * 0.5
        )
        target_offset.y = sin(bob_phase) * amplitude

    landing_offset = move_toward(
        landing_offset,
        0.0,
        0.25 * delta
    )

    target_offset.y += landing_offset

    var camera_blend := 1.0 - exp(
        -camera_return_speed * delta
    )

    camera_effects.position = camera_effects.position.lerp(
        target_offset,
        camera_blend
    )