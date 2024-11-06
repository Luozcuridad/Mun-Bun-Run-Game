extends Area2D

@onready var sprite_2d: Sprite2D = $Sprite2D
@onready var collision_shape_2d: CollisionShape2D = $CollisionShape2D

var bob_height : float = 5.0
var bob_speed : float = 5.0
@onready var start_y : float = global_position.y
var t : float = 0.0


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	t += delta
	var d = (sin(t * bob_speed) + 1) / 2
	
	global_position.y = start_y + (d * bob_height)

func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("PlayerCharacter"):
		body.mark_checkpoint()
		sprite_2d.set_frame(12)
		collision_shape_2d.disabled = true
