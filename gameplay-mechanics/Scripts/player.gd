extends CharacterBody2D
# === Movement ===
const SPEED := 300.0
const ACCELERATION := 500.0
const FRICTION := 1000.0
const JUMP_VELOCITY := -400.0
# === Dodge ===
const DODGE_SPEED := 500.0
const DODGE_TIME := 0.2
const DODGE_COOLDOWN := 0.6
var is_dodging := false
var can_dodge := true
var dodge_timer := 0.0
var cooldown_timer := 0.0
# === Facing ===
var facing_direction := 1  # 1 = right, -1 = left

func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY
	handle_dodge(delta)
	if not is_dodging:
		var direction := Input.get_axis("move_left", "move_right")
		if direction != 0:
			velocity.x = move_toward(velocity.x, direction * SPEED, ACCELERATION * delta)
			# Only flip when direction actually changes
			if direction > 0 and facing_direction != 1:
				facing_direction = 1
				$AnimatedSprite2D.flip_h = false
			elif direction < 0 and facing_direction != -1:
				facing_direction = -1
				$AnimatedSprite2D.flip_h = true
		else:
			velocity.x = move_toward(velocity.x, 0.0, FRICTION * delta)
	
	move_and_slide()
	update_animation()

func update_animation() -> void:
	if not is_on_floor():
		$AnimatedSprite2D.play("Jump")
	elif velocity.x != 0:
		$AnimatedSprite2D.play("Run")
	else:
		$AnimatedSprite2D.play("Idle")

func handle_dodge(delta: float) -> void:
	if Input.is_action_just_pressed("dodge") and can_dodge and not is_dodging:
		is_dodging = true
		can_dodge = false
		dodge_timer = DODGE_TIME
		var direction := Input.get_axis("move_left", "move_right")
		if direction == 0:
			if velocity.x != 0:
				direction = sign(velocity.x)
			else:
				direction = 1
		velocity.x = direction * DODGE_SPEED
		velocity.y = 0
	if is_dodging:
		dodge_timer -= delta
		if dodge_timer <= 0:
			is_dodging = false
			cooldown_timer = DODGE_COOLDOWN
	if not can_dodge:
		cooldown_timer -= delta
		if cooldown_timer <= 0:
			can_dodge = true
