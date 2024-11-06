extends CharacterBody2D
class_name EnemyWalker

var gravity = ProjectSettings.get_setting("physics/2d/default_gravity")
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if not is_on_floor():
		velocity.y += gravity
		
	move_and_slide()


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("PlayerCharacter"):
		body.player_death()
