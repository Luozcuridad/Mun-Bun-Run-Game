extends Node2D

@onready var zone_1: Path2D = $CameraControls/Zone1
@onready var zone_2: Path2D = $CameraControls/Zone2
@onready var pcam: PhantomCamera2D = $PhantomCamera2D
@onready var player: CharacterBody2D = $Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	player.mark_checkpoint()


func _on_transition_1_body_entered(body: Node2D) -> void:
	if body.is_in_group("PlayerCharacter"):
		pcam.set_follow_path(zone_1)


func _on_transition_2_body_entered(body: Node2D) -> void:
	if body.is_in_group("PlayerCharacter"):
		pcam.set_follow_path(zone_2)


func _on_kill_zone_body_entered(body: Node2D) -> void:
	if body.is_in_group("PlayerCharacter"):
		body.player_death()
