extends CharacterBody2D

# Add variables
@export var max_speed : int = 200 
@export var jump_force : int = 500
@export var acceleration : int = 25

@export var jump_buffer_time : int = 3
@export var coyote_time : int = 150
@export var jump_stop : int = 125

#To put in singleton later maybe
var score : int = 0
var retry_counter: int = 0
@onready var score_text: Label = $"../CanvasLayer/ScoreText"
@onready var score_text_2: Label = $"../CanvasLayer/ScoreText2"


@onready var player: CharacterBody2D = $Player
@onready var phantom_camera_2d: PhantomCamera2D = $"../PhantomCamera2D"

var respawn_position: Vector2i

@onready var level_timer: Timer = $LevelTimer
@onready var total_time_seconds: int = 0

#nodes controllers
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D
@onready var animation_player: AnimationPlayer = $Sprite2D/AnimationPlayer
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer


# individual variables
var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
var jump_buffer_counter : int = 0
var coyote_counter : int = 0
var InUse : bool = true


func _ready() -> void:
	level_timer.start()
	animation_player.play("Idle")



func _physics_process(_delta: float) -> void:
	if is_on_floor():
		#speed/2 To hobble movement on land
		velocity.x = clamp(velocity.x, -max_speed/2, max_speed/2)
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
	if Input.is_action_pressed("Z"):
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


func camera_shake():
	phantom_camera_2d.noise.frequency = 150
	await get_tree().create_timer(0.05).timeout # waits for 1 second
	phantom_camera_2d.noise.frequency = 0


func frame_freeze(timeScale, duration):
	Engine.time_scale = timeScale
	await get_tree().create_timer(duration * timeScale).timeout # waits for 1 second
	Engine.time_scale = 1.0


func add_score(amount):
	score += amount
	print(str("Score: ", score, " Retries: ", retry_counter))
	score_text.text = str("Score: ", score)


func _on_level_timer_timeout() -> void:
	total_time_seconds += 1
	var minutes = int(total_time_seconds / 60.0)
	var seconds = total_time_seconds - minutes * 60
	score_text_2.text = str("Time: ",'%02d:%02d' % [minutes, seconds])


func mark_checkpoint():
	respawn_position.x = global_position.x
	respawn_position.y = global_position.y - 50


func player_death ():
	#collision_shape_2d.disabled = true #Juice part 1
	velocity.y = -1500
	animation_player.play("Death")
	InUse = false
	audio_stream_player.play()
	
	retry_counter += 1 #Score system
	add_score(-1000)
	
	camera_shake() #Juice part 2
	frame_freeze(0.05, 1.5)
	await get_tree().create_timer(1.5).timeout # waits for 1 second
	
	#collision_shape_2d.disabled = false #Respawn system
	global_position = respawn_position
	animation_player.play("Idle")
	InUse = true
