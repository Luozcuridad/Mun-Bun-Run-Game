extends CharacterBody2D

# Add variables
@export var max_speed : int = 1000 
@export var jump_force : int = 1600
@export var acceleration : int = 50

@export var jump_buffer_time : int = 3
@export var coyote_time : int = 150
@export var jump_stop : int = 400

#here for now till make the result screen singleton
var score : int = 0
@onready var score_text: Label = $"../CanvasLayer/ScoreText"

#nodes controllers
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var sprite_2d: Sprite2D = $Sprite2D

# individual variables
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var jump_buffer_counter : int = 0
var coyote_counter : int = 0
var InUse: bool = true

func _physics_process(_delta: float) -> void:
	collision_shape_2d.disabled = not InUse
	
	if is_on_floor():
		#To hobble movement
		velocity.x = clamp(velocity.x, -max_speed, max_speed)
		coyote_counter = coyote_time
	
	if not is_on_floor():
		#To speedup movement on air
		velocity.x = clamp(velocity.x, -max_speed, max_speed)
		if coyote_counter > 0:
			coyote_counter -= 1
		velocity.y += gravity
		if velocity.y > 2000:
			velocity.y = 2000
	
	# Horizontal movement
	if Input.is_action_pressed("ui_right") && InUse:
		velocity.x += acceleration
	elif Input.is_action_pressed("ui_left") && InUse:
		velocity.x -= acceleration
	else :
		velocity.x = lerpf(velocity.x,0,0.2)
	
	#Jump and buffer time
	if Input.is_action_pressed("Z") && InUse:
		jump_buffer_counter = jump_buffer_time
	
	if jump_buffer_counter > 0:
		jump_buffer_counter -= 1
	
	if jump_buffer_counter > 0 and coyote_counter > 0:
		velocity.y = -jump_force
		jump_buffer_counter = 0
		coyote_counter = 0
	
	#Stop upwards movement by releasing the button
	if Input.is_action_just_released("Z"):
		if velocity.y < 0:
			velocity.y += jump_stop
	
	move_and_slide()

func change_state():
	pass

func game_over ():
	get_tree().reload_current_scene()


func add_score(amount):
	score += amount
	score_text.text = str("Score: ", score)
