extends Area2D


var is_claimed = false

onready var random_number := rand_range(0, 1000)


func _process(delta: float) -> void:
	position += Vector2(35 * sin(random_number + OS.get_ticks_msec() * 0.001), 3) * delta
	
	if position.y > 610 && !is_claimed:
		call_deferred("queue_free")
