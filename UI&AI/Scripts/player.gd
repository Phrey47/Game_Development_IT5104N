#extends CharacterBody2D
#
#signal died
#
#
#const SPEED = 300.0
#
#@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
#@onready var swing_sword_sound: AudioStreamPlayer2D = $swing_sword
#@onready var hitbox: Area2D = $Hitbox
#@onready var take_damage_sound: AudioStreamPlayer2D = $TakeDamage
#@onready var damage_cooldown: Timer = $DamageCooldown
#
#
#var last_direction: Vector2 = Vector2.RIGHT
#var is_attacking: bool = false
#var is_alive: bool = true  
#var strength: int = 20
#var spawn_position: Vector2
#var max_health: int
#var health: int 
#
#func _ready() -> void:
	##Load health from singleton
	#health = PlayerStats.health
	#max_health = PlayerStats.max_health
	#hitbox.monitoring = false
	#spawn_position = global_position
#
#func _physics_process(_delta: float) -> void:
	#if not is_alive:  # ← also block input when dead
		#return
#
	#if Input.is_action_just_pressed("attack") and not is_attacking:
		#attack()
#
	#if is_attacking:
		#velocity = Vector2.ZERO
		#move_and_slide()
		#return
#
	#process_movement()
	#process_animation()
	#move_and_slide()
#
## MOVEMENT
#func process_movement() -> void:
	#var direction := Input.get_vector("left", "right", "up", "down")
	#if direction != Vector2.ZERO:
		#velocity = direction.normalized() * SPEED
		#last_direction = direction
	#else:
		#velocity = Vector2.ZERO
	#update_hitbox_position()
#
#func process_animation() -> void:
	#if is_attacking:
		#return
	#if velocity != Vector2.ZERO:
		#play_animation("run", last_direction)
	#else:
		#play_animation("idle", last_direction)
#
#func play_animation(prefix: String, dir: Vector2) -> void:
	#if abs(dir.x) >= abs(dir.y):
		#animated_sprite_2d.flip_h = dir.x < 0
		#animated_sprite_2d.play(prefix + "_right")
	#else:
		#animated_sprite_2d.flip_h = false
		#if dir.y < 0:
			#animated_sprite_2d.play(prefix + "_up")
		#else:
			#animated_sprite_2d.play(prefix + "_down")
#
## HITBOX
#func update_hitbox_position() -> void:
	#var offset := 30.0
	#if abs(last_direction.x) >= abs(last_direction.y):
		#hitbox.position = Vector2(offset * sign(last_direction.x), 0)
	#else:
		#if last_direction.y < 0:
			#hitbox.position = Vector2(0, -offset)
		#else:
			#hitbox.position = Vector2(0, offset)
#
## ATTACK
#func attack() -> void:
	#is_attacking = true
	#hitbox.monitoring = true
	#swing_sword_sound.play()
	#play_animation("attack", last_direction)
	#update_hitbox_position()
#
#func _on_animated_sprite_2d_animation_finished() -> void:
	#if is_attacking:
		#is_attacking = false
		#hitbox.monitoring = false
#
#func _on_hitbox_body_entered(body: Node2D) -> void:
	#if is_attacking and body.name.begins_with("Slime"):
		#body.take_damage(strength, position)
#
#func take_damage(amount: int) -> void:
	#if damage_cooldown.time_left > 0:
		#return
	#take_damage_sound.play()
	#health -= amount
	#PlayerStats.health = health
	#print(health)
	##Make player invincible short time
	#damage_cooldown.start()
	#if health <= 0:
		#die()
#
## DEATH
#func die() -> void:
	#if not is_alive:
		#return
	#is_alive = false
	#velocity = Vector2.ZERO
	#animated_sprite_2d.play("death")
	#await animated_sprite_2d.animation_finished
	#await get_tree().create_timer(1.0).timeout
	#died.emit()
	#respawn()
#
#func respawn() -> void:
	## Reset health
	#health = max_health
	#PlayerStats.health = max_health
	#
	## Reset position
	#global_position = spawn_position
	#
	## Reset state
	#is_alive = true
	#is_attacking = false
	#hitbox.monitoring = false
	#velocity = Vector2.ZERO
	#
	#play_animation("idle", last_direction)

extends CharacterBody2D

const SPEED = 300.0
const DASH_SPEED = 800.0
const DASH_DURATION = 0.15  # seconds
const DASH_COOLDOWN = 1.0   # seconds

@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D
@onready var swing_sword_sound: AudioStreamPlayer2D = $swing_sword
@onready var hitbox: Area2D = $Hitbox
@onready var take_damage_sound: AudioStreamPlayer2D = $TakeDamage
@onready var damage_cooldown: Timer = $DamageCooldown

var last_direction: Vector2 = Vector2.RIGHT
var is_attacking: bool = false
var is_alive: bool = true
var is_dashing: bool = false
var dash_cooldown_left: float = 0.0
var strength: int = 20
var spawn_position: Vector2
var max_health: int
var health: int

signal died

func _ready() -> void:
	health = PlayerStats.health
	max_health = PlayerStats.max_health
	hitbox.monitoring = false
	spawn_position = global_position

func _physics_process(delta: float) -> void:
	if not is_alive:
		return

	# Reduce cooldown every frame
	if dash_cooldown_left > 0:
		dash_cooldown_left -= delta

	if Input.is_action_just_pressed("attack") and not is_attacking and not is_dashing:
		attack()

	if Input.is_action_just_pressed("dash") and not is_dashing and dash_cooldown_left <= 0:
		start_dash()

	if is_attacking:
		velocity = Vector2.ZERO
		move_and_slide()
		return

	process_movement()
	process_animation()
	move_and_slide()

# MOVEMENT
func process_movement() -> void:
	if is_dashing:
		return  # dash controls velocity directly

	var direction := Input.get_vector("left", "right", "up", "down")
	if direction != Vector2.ZERO:
		velocity = direction.normalized() * SPEED
		last_direction = direction
	else:
		velocity = Vector2.ZERO

	update_hitbox_position()

func process_animation() -> void:
	if is_attacking or is_dashing:
		return
	if velocity != Vector2.ZERO:
		play_animation("run", last_direction)
	else:
		play_animation("idle", last_direction)

func play_animation(prefix: String, dir: Vector2) -> void:
	if abs(dir.x) >= abs(dir.y):
		animated_sprite_2d.flip_h = dir.x < 0
		animated_sprite_2d.play(prefix + "_right")
	else:
		animated_sprite_2d.flip_h = false
		if dir.y < 0:
			animated_sprite_2d.play(prefix + "_up")
		else:
			animated_sprite_2d.play(prefix + "_down")

# HITBOX
func update_hitbox_position() -> void:
	var offset := 30.0
	if abs(last_direction.x) >= abs(last_direction.y):
		hitbox.position = Vector2(offset * sign(last_direction.x), 0)
	else:
		if last_direction.y < 0:
			hitbox.position = Vector2(0, -offset)
		else:
			hitbox.position = Vector2(0, offset)

# DASH
func start_dash() -> void:
	is_dashing = true
	dash_cooldown_left = DASH_COOLDOWN
	velocity = last_direction.normalized() * DASH_SPEED

	# Optional: make invincible during dash
	damage_cooldown.start()

	await get_tree().create_timer(DASH_DURATION).timeout
	is_dashing = false
	velocity = Vector2.ZERO

# ATTACK
func attack() -> void:
	is_attacking = true
	hitbox.monitoring = true
	swing_sword_sound.play()
	play_animation("attack", last_direction)
	update_hitbox_position()

func _on_animated_sprite_2d_animation_finished() -> void:
	if is_attacking:
		is_attacking = false
		hitbox.monitoring = false

func _on_hitbox_body_entered(body: Node2D) -> void:
	if is_attacking and body.name.begins_with("Slime"):
		body.take_damage(strength, position)

# TAKE DAMAGE
func take_damage(amount: int) -> void:
	if damage_cooldown.time_left > 0:
		return
	take_damage_sound.play()
	health -= amount
	PlayerStats.health = health
	print(health)
	damage_cooldown.start()

	if health <= 0:
		die()

# DEATH
func die() -> void:
	if not is_alive:
		return
	is_alive = false
	velocity = Vector2.ZERO
	animated_sprite_2d.play("death")
	await animated_sprite_2d.animation_finished
	died.emit()
	await get_tree().create_timer(1.0).timeout
	respawn()

func respawn() -> void:
	health = max_health
	PlayerStats.health = max_health
	global_position = spawn_position
	is_alive = true
	is_attacking = false
	is_dashing = false
	hitbox.monitoring = false
	velocity = Vector2.ZERO
	play_animation("idle", last_direction)
