extends CharacterBody2D

# Add variables
@export var max_speed : int = 1000 
@export var jump_force : int = 1600
@export var acceleration : int = 50

@export var jump_buffer_time : int = 3
@export var coyote_time : int = 150
@export var jump_stop : int = 400

#here for not till I make score screen singleton
var score : int = 0
@onready var score_text: Label = $"../CanvasLayer/ScoreText"

#nodes controllers
@onready var rider_container: Node2D = $RiderContainer
@onready var rider_position: Marker2D = $RiderPosition


# individual variables
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var jump_buffer_counter : int = 0
var coyote_counter : int = 0
var InUse : bool = false


func _physics_process(_delta: float) -> void:
	if Input.is_action_just_pressed("X") && InUse:
		_dismount()
	
	if is_on_floor():
		#To hobble movement
		velocity.x = clamp(velocity.x, -max_speed/4, max_speed/4)
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


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("PlayerCharacter"):
		print("Mounted!")
		body.InUse = false
		call_deferred("do_ride", body)
		print("Mounted two!")


func do_ride(rider):
	rider.reparent(rider_container)
	rider.global_position = rider_container.global_position
	InUse = true


func _dismount():
	InUse = false
	
	rider_container.scale.x = 1
	
	var player = rider_container.get_children()[0]
	player.reparent(get_tree().current_scene)
	player.InUse = true
	
	player.position.x -= 25
	player.position.y -= 200


func change_state():
	pass


func game_over ():
	get_tree().reload_current_scene()


func add_score(amount):
	score += amount
	score_text.text = str("Score: ", score)
