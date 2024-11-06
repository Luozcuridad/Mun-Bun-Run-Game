extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.is_in_group("PlayerCharacter"):
		body.change_state()
		queue_free()
