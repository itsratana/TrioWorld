extends CharacterBody2D

@export_group("Player Attribute")
@export var moveSpeed: float = 300.0
@export var jumpValue: float = 0.0
@export var jumpPowerInitial: float= -130
@export var jumpHorizontalPowerInitial: float = 1.8
#@export var canJump = true
@export var jumpChargeTime: float = 0
@export var isHighFall: bool = false
@export var isStun:bool = false
@export var isInAir:bool = false
@export var wasInAir:bool
@export var currentAnim:String = ""
@export var camera_height: int = 1520
@export var camera_limit_lower: int = -50
@export var camera_limit_upper: int = -900

signal change_camera_pos

@onready var playerSprite = $AnimatedSprite2D
@onready var timeNode = $"../Timer"
@onready var finishPanel = $"../Control/CanvasLayer/WellDone"
@onready var powerBar = $PowerBar
@onready var touchScreen = $"../Control/CanvasLayer/TouchControl"
@onready var level = $".."

@onready var jump: AudioStreamPlayer2D = $"../jump"

@export_group("Condition")
@export var lastDirection: float
@export var isCharging:bool = false
@export var isJumping: bool
#@export var canJump: bool = true
@export var hasStartMove:bool
@export var hasWon: bool
@export var toUpdateData: bool
@export var input_enabled := true
@export var coins: int = 0

@export_group("Button Press")
@export var left_press := false
@export var right_press := false
@export var was_left_press := false
@export var was_right_press := false
@export var move_left_pressed := false
@export var move_right_pressed := false

var has_started := false

var lock_x_position := false
var locked_x := 0.0

var direction := 0.0
var score:int

var facingDirection = 1:
	get: return facingDirection
	set(value):
		if value == 0 or value == facingDirection: return
		facingDirection = value
		playerSprite.flip_h = value == -1

func _ready() -> void:
	await get_tree().create_timer(0.1).timeout
	has_started = true
	
	powerBar.hide()
	input_enabled = false
	#set_physics_process(false)
	add_to_group("player")

func _physics_process(delta: float) -> void:
	var left_released := was_left_press and !left_press
	var right_released := was_right_press and !right_press
	was_left_press = left_press
	was_right_press = right_press
	#score = timeNode.formatted_time
	#if Input.is_action_pressed("ui_left") || Input.is_action_just_pressed("ui_right"):
		#pressLeft = !pressLeft
	currentAnim = playerSprite.animation
	isCharging = false
	
	if input_enabled:
		direction = Input.get_axis("move_left", "move_right")
		var button_input := 0.0
		if move_left_pressed:
			button_input -= 1.0
		if move_right_pressed:
			button_input += 1.0
		direction = clamp(direction + button_input, -1.0, 1.0)
	
	if !isJumping && !Input.is_action_pressed("ui_accept") && !isStun:
		facingDirection = direction
	
	if move_left_pressed or move_right_pressed or left_press or right_press:
		if !level.tutorialScreenOn:
			hasStartMove= true
		
	if velocity.y > 3000:
		isHighFall = true
		
	if isJumping:
		if velocity.y > 0 and playerSprite.animation == "jump":
			playerSprite.play("fall")
			pass
		if velocity.x == 0:
			if lastDirection < 0:
				lastDirection = 1.05
				facingDirection = 1
			elif lastDirection > 0:
				lastDirection =-1.05
				facingDirection = -1
		velocity.x = lastDirection * moveSpeed
	else:
		if !isStun: velocity = Vector2(direction * (moveSpeed), velocity.y)
			
		if direction == 0 && !isStun && is_on_floor() && !hasWon:
			if playerSprite.animation not in ["idle", "ground"]:
				playerSprite.play("idle")
		else:
			if !isStun and is_on_floor() and !lock_x_position and playerSprite.animation not in ["run", "ground", "jump", "stun"]:
				playerSprite.play("run")
				AudioManager.play_sfx("Footstep")
		
	if playerSprite.animation in ["fall", "ground", "jump", "idle", "stun"]:
		AudioManager.stop_sfx("Footstep")
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta * 2
		if has_started:
			if velocity.y>100 and !isStun and playerSprite.animation not in ["jump", "land", "stun", "ground"]:
				if playerSprite.animation != "fall":
					playerSprite.play("fall")
				position.x += moveSpeed/200 * delta
	if !has_started and is_on_floor():
		playerSprite.play("idle")
	#if isInAir:
		#velocity.x = lastDirection * (moveSpeed)
	# Handle jump.
	if is_on_floor():
		isJumping = false
		
		if isHighFall:
			StunPhase()
	#print(playerSprite.animation)
	
	#Landing animation----------
	wasInAir = isInAir
	isInAir = not is_on_floor()
	#if wasInAir and is_on_floor():
		#print("current animation: ", playerSprite.animation)
		#playerSprite.play("land")
		#await playerSprite.animation_finished
		#playerSprite.play("idle")
	
	if isStun:
		velocity = Vector2(0.0, velocity.y)
	
	if  is_on_floor() && !isStun:
		#velocity = Vector2(0.0, velocity.y)
		if left_press and !hasWon:
			velocity = Vector2(0.0, velocity.y)
			facingDirection = -1
			ChargeJump()
		elif right_press and !hasWon:
			velocity = Vector2(0.0, velocity.y)
			facingDirection = 1
			ChargeJump()
	
	if is_on_floor() && !isStun:
		if left_released and !hasWon:
			StartJump()
		elif right_released and !hasWon:
			StartJump()
		#canJump = true
		
	if isCharging:
		powerBar.show()
	else:
		if !isJumping :
			await get_tree().create_timer(0.1).timeout
			if !isCharging:
				powerBar.hide()
	
	if hasWon:
		position.x += moveSpeed/10 * delta
		playerSprite.play("run")
		direction = 1
	
	if lock_x_position:
		velocity.x = 0
		position.x = locked_x
		touchScreen.hide()
		if playerSprite.animation != "idle":
			playerSprite.play("idle")
		return
	else:
		touchScreen.show()
	
	move_camera_to_match_player()
	move_and_slide()

func _wait_until_landed() -> void:
	while not is_on_floor():
		await get_tree().process_frame

func move_camera_to_match_player():
	if position.y < camera_limit_upper:
		camera_limit_lower -= camera_height
		camera_limit_upper -= camera_height
		change_camera_pos.emit(camera_limit_upper + 500)
	
	if position.y > camera_limit_lower:
		camera_limit_lower += camera_height
		camera_limit_upper += camera_height
		change_camera_pos.emit(camera_limit_upper)

func ChargeJump():
	jumpChargeTime += .2
	powerBar.value = jumpChargeTime
	isCharging = true
		
	if playerSprite.animation not in ["stun", "fall", "jump"]:
		if playerSprite.animation != "ground":
			playerSprite.play("ground")
	#canJump = false
	if jumpChargeTime > 12:
		StartJump()

func StartJump():
	AudioManager.play_sfx("Jump")
	lastDirection = 0
	#if Input.is_action_just_pressed("ui_right") || Input.is_action_pressed("ui_right"):
		#lastDirection = jumpHorizontalPowerInitial
		#facingDirection == 1
	#if Input.is_action_just_pressed("ui_left") || Input.is_action_pressed("ui_left"):
		#lastDirection = -jumpHorizontalPowerInitial
		#facingDirection == -1
	if facingDirection == 1:
		lastDirection = jumpHorizontalPowerInitial
	if facingDirection == -1:
		lastDirection = -jumpHorizontalPowerInitial
	
	if playerSprite.animation != "jump":
		playerSprite.play("jump")
	
	#canJump = false
	isJumping = true
	velocity.y = jumpPowerInitial * jumpChargeTime
	velocity.x = lastDirection * (moveSpeed/10)
	
	ResetJump()
func ResetJump():
	#canJump = true
	jumpValue = jumpPowerInitial
	jumpChargeTime = 0

func StunPhase():
	isHighFall = false
	isStun = true
	if playerSprite.animation != "stun":
		playerSprite.play("stun")
	$StunDuration.start()

func _on_timer_timeout() -> void:
	isStun = false
	if is_on_floor() and !hasWon:
		playerSprite.play("idle")

func _on_area_2d_body_entered(body) -> void:
	$"../Finish/AnimationPlayer".play("Finish Animation")
	input_enabled = false
	toUpdateData = true
	
	await _wait_until_landed()
	locked_x = position.x  # Freeze current x position
	lock_x_position = true
	
	$"../Control/CanvasLayer/AnimationPlayer".play("coinx5000")
	await get_tree().create_timer(3).timeout
	GameManager.coin_global += 5000
	GameManager.update_coin_to_playfab()
	
	await get_tree().create_timer(2).timeout #wait for animation to finish
	hasWon = true
	lock_x_position = false
	
	await get_tree().create_timer(1).timeout
	finishPanel.show()
	$"../Control/CanvasLayer/WellDone/Score".text = timeNode.formatted_time
	if timeNode.formatted_time > LeaderboardData.get_own_formatted_score():
		$"../Control/CanvasLayer/WellDone/HighestScore".text = LeaderboardData.get_own_formatted_score()
	else:
		$"../Control/CanvasLayer/WellDone/HighestScore".text = timeNode.formatted_time

#jump button
func _on_left_button_down() -> void:
	if input_enabled:
		left_press = true

func _on_left_button_up() -> void:
	if input_enabled:
		left_press = false

func _on_right_button_down() -> void:
	if input_enabled:
		right_press = true

func _on_right_button_up() -> void:
	if input_enabled:
		right_press = false

#walk button
func _on_move_left_button_down() -> void:
	if input_enabled:
		move_left_pressed = true

func _on_move_left_button_up() -> void:
	if input_enabled:
		move_left_pressed = false

func _on_move_right_button_down() -> void:
	if input_enabled:
		move_right_pressed = true

func _on_move_right_button_up() -> void:
	if input_enabled:
		move_right_pressed = false
