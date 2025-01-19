extends CharacterBody2D

@onready var body: Node2D = $body
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var jump_request_timer: Timer = $Timer/JumpRequestTimer
@onready var coyote_timer: Timer = $Timer/CoyoteTimer

@onready var sprite_2d: Sprite2D = $body/Sprite2D

@export var pos :Vector2

@onready var floorcheck: RayCast2D = $body/floorcheck

#所有状态
enum State{
	IDLE,
	RUN,
	JUMP,
	FALL,
	LANDING,
	DIE,
}
#方向
enum Direction {
	LEFT = -1,
	RIGHT = +1,
}

@export var direction := Direction.RIGHT:
	set(v):
		direction = v
		if not is_node_ready():
			await ready
		body.scale.x = direction

const RUN_SPEED := 80.0
const FLOOR_ACCELERATION := RUN_SPEED / 0.02
const AIR_ACCELERATION := RUN_SPEED / 0.03
const JUMP_VELOCITY := -200.0

var default_gravity := ProjectSettings.get("physics/2d/default_gravity") * 1.4 as float
var die := false
var player = preload("res://场景/player/player.tscn")

func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("jump"):
		jump_request_timer.start()
	
	if event.is_action_released("jump"):
		jump_request_timer.stop()
		if velocity.y < JUMP_VELOCITY / 3:
			velocity.y = JUMP_VELOCITY / 3

func _ready() -> void:
	randomize()
	var v = randi_range(1,9)
	print(v)
	if v == 1:
		sprite_2d.texture = preload("res://资源/人物/1.png")
	elif v == 2:
		sprite_2d.texture = preload("res://资源/人物/2.png")
	elif v == 3:
		sprite_2d.texture = preload("res://资源/人物/3.png")
	elif v == 4:
		sprite_2d.texture = preload("res://资源/人物/4.png")
	elif v == 5:
		sprite_2d.texture = preload("res://资源/人物/5.png")
	elif v == 6:
		sprite_2d.texture = preload("res://资源/人物/6.png")
	elif v == 7:
		sprite_2d.texture = preload("res://资源/人物/7.png")
	elif v == 8:
		sprite_2d.texture = preload("res://资源/人物/8.png")
	elif v == 9:
		sprite_2d.texture = preload("res://资源/人物/9.png")

func tick_physics(state: State, _delta: float) -> void:
	match state:
		State.IDLE,State.RUN,State.JUMP,State.FALL,State.LANDING:
			move(default_gravity, get_process_delta_time(), 1)
		State.DIE:
			stand(default_gravity, get_process_delta_time(), 1)

func get_next_state(state: State) -> int:
	if die or Input.is_action_just_pressed("die"):
		return StateMachine.KEEP_CURRENT if state == State.DIE else State.DIE
	#实现跳跃
	var can_jump := is_on_floor() or coyote_timer.time_left > 0
	var should_jump := can_jump and jump_request_timer.time_left > 0
	if should_jump and not state == State.DIE:
		return State.JUMP
	match state:
		State.IDLE:
			if not is_zero_approx(velocity.x):
				return State.RUN
		State.RUN:
			if is_zero_approx(velocity.x):
				return State.IDLE
			if velocity.y > 10:
				return State.FALL
		State.JUMP:
			if velocity.y > 10:
				return State.FALL
		State.FALL:
			if is_zero_approx(velocity.y):
				return State.LANDING
		State.LANDING:
			if not animation_player.is_playing():
				return State.IDLE
		State.DIE:
			pass
	return StateMachine.KEEP_CURRENT

func transition_state(from: State, to: State) -> void:
	if from == State.RUN:
		Soundmanger.stop_sfx("run")
	
	match to:
		State.IDLE:
			animation_player.play("idle")
		State.RUN:
			animation_player.play("run")
			Soundmanger.play_sfx("run")
		State.JUMP:
			animation_player.play("jump")
			Soundmanger.play_sfx("jump")
			velocity.y = JUMP_VELOCITY
			coyote_timer.stop()
			jump_request_timer.stop()
		State.FALL:
			animation_player.play("fall")
		State.LANDING:
			animation_player.play("landing")
			Soundmanger.play_sfx("landing")
		State.DIE:
			animation_player.play("die")
			if Game.num != 1:
				Soundmanger.play_sfx("die")
			velocity.x = 0
			Game.num -= 1

func move(gravity: float, delta: float, rate: float) -> void:
	var movement := Input.get_axis("move_left", "move_right")
	var acceleration := FLOOR_ACCELERATION if is_on_floor() else AIR_ACCELERATION
	velocity.limit_length(200)
	if Input.get_action_strength("shift"):
		if floorcheck.is_colliding():
			velocity.x = move_toward(velocity.x, movement * RUN_SPEED * rate, acceleration * delta)
		else:
			velocity.x = 0
	else:
		velocity.x = move_toward(velocity.x, movement * RUN_SPEED * rate, acceleration * delta)
	if abs(velocity.y) <= 330:
		velocity.y += gravity * delta
		if velocity.y > 0:
			velocity.y += 0
	if not is_zero_approx(movement):
		direction = Direction.LEFT if movement < 0 else Direction.RIGHT
	move_and_slide()

func stand(gravity: float, delta: float, rate: float) -> void:
	if abs(velocity.y) <= 330:
		velocity.y += gravity * delta * rate
		if velocity.y > 0:
			velocity.y += 0
	move_and_slide()

func relive() -> void:
	var relive = player.instantiate()
	relive.global_position = pos
	relive.pos = pos
	get_parent().add_child(relive)

func _on_player_body_area_entered(area: Area2D) -> void:
	if area.name == "PlayerDie":
		die = true
