extends State
class_name EnemyWalkIdle

var move_direction: Vector2
var wander_time: float

func randomize_wander():
	move_direction = Vector2(randf_range(-1, 1), randf_range(-1, 1)).normalized()
	wander_time = randf_range(1, 3)

func Enter():
	randomize_wander()

func Update(_delta: float) -> void:
	if wander_time > 0:
		wander_time -= _delta
	else:
		randomize_wander()
