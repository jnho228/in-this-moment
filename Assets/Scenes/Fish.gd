extends Area2D


signal die

enum Gender {FEMALE, MALE}
var male_names = ["Bob", "Stamp", "Fankle", "Phone", "Apple"]
var female_names = ["Sally", "Tiffany", "Spoons", "Cupholder", "Lisa"]
var my_name := ""

var is_alive := true
onready var gender = Gender.MALE if randi() % 2 == 0 else Gender.FEMALE

var life := 0.0
var hunger := 0.0
var libido := 0.0

var max_life := 1.0
var max_hunger := 1.0
var max_libido := 1.0
var move_speed := 1.0
var vision_radius := 1.0

var my_food = null
var my_partner = null

onready var random_position := Vector2(rand_range(0, 1024), rand_range(0, 600))
onready var random_number := rand_range(0, 1000)


func _ready() -> void:
	$InformationPanel/AgeBar.max_value = max_life
	$InformationPanel/HungerBar.max_value = max_hunger
	
	my_name = male_names[randi() % male_names.size()] if gender == Gender.MALE else female_names[randi() % female_names.size()]
	
	$InformationPanel/NameLabel.text = my_name


func _process(delta: float) -> void:
	if is_alive:
		# Track life
		life += delta
		
		if life >= max_life:
			die()
		
		$InformationPanel/AgeBar.value = life
		
		# Track hunger
		hunger += delta
		
		if hunger >= (max_hunger / 3):
			find_food()
			if my_food:
				if move_to(my_food.position, delta) < 15:
					eat()
		
		if hunger >= max_hunger:
			die()
		
		$InformationPanel/HungerBar.value = hunger
		
		# Track sex drive
		libido += delta
		
		if libido >= max_libido && ((libido/max_libido) > (hunger / max_hunger)):
			find_partner()
			if my_partner:
				if move_to(my_partner.position, delta) < 15:
					mate()
		
		if !my_food && !my_partner:
			# Random movement
			if move_to(random_position, delta) < 5:
				random_position = Vector2(rand_range(0, 1024), rand_range(0, 600))
	else:
		# Do dead stuff like float up and die.
		position += Vector2(50 * sin(random_number + OS.get_ticks_msec() * 0.001), -10) * delta
		
		if position.y < -10:
			call_deferred("queue_free")


func die() -> void:
	emit_signal("die")
	is_alive = false
	$Sprite.flip_v = true
	$Sprite.self_modulate = Color(1, 1, 1, 0.75)
	
	if my_food:
		my_food.is_claimed = false
	
	if my_partner:
		my_partner.my_partner = null
	
	my_food = null
	my_partner = null


func find_food() -> void:
	if my_food:
		if my_partner:
			my_partner.my_partner = null
			my_partner = null
		return
	
	if !my_food:
		$RayCast2D.cast_to = Vector2(vision_radius, 0)
		$RayCast2D.force_raycast_update()
		if $RayCast2D.is_colliding():
			if $RayCast2D.get_collider().get_collision_layer_bit(1) && $RayCast2D.get_collider().is_claimed != true:
				my_food = $RayCast2D.get_collider()
				my_food.is_claimed = true
		else:
			$RayCast2D.rotation_degrees += 0.1


func find_partner() -> void:
	if my_partner: 
		if my_food:
			my_food.is_claimed = false
			my_food = null
		return
	
	if !my_partner:
		$RayCast2D.cast_to = Vector2(vision_radius, 0)
		$RayCast2D.force_raycast_update()
		if $RayCast2D.is_colliding():
			if $RayCast2D.get_collider().get_collision_layer_bit(0) && $RayCast2D.get_collider().my_partner == null && $RayCast2D.get_collider().gender != gender && $RayCast2D.get_collider().is_alive:
				my_partner = $RayCast2D.get_collider()
				my_partner.my_partner = self
		else:
			$RayCast2D.rotation_degrees += 0.1


func move_to(target_position: Vector2, delta: float) -> float:
	var direction := (target_position - position).normalized()
	# Add in a sin for vague water-like movement??
	direction *= move_speed if my_food || my_partner else (move_speed * sin(random_number + life) + (move_speed / 4))
	position += direction * delta
	
	# Add extra sprite flipping here later
	$Sprite.flip_h = direction.x < 0
	
	return position.distance_to(target_position)


func eat() -> void:
	my_food.call_deferred("queue_free")
	my_food = null
	hunger = 0


func mate() -> void:
	if gender == Gender.FEMALE:
		var _max_life = ((max_life + my_partner.max_life) / 2) + rand_range(-3, 3)
		var _max_hunger = ((max_hunger + my_partner.max_hunger) / 2) + rand_range(-3, 3)
		var _max_libido = ((max_libido + my_partner.max_libido) / 2) + rand_range(-3, 3)
		var _move_speed = ((move_speed + my_partner.move_speed) / 2) + rand_range(-3, 3)
		var _vision_radius = ((vision_radius + my_partner.vision_radius) / 2) + rand_range(-3, 3)
		var _color = get_color() if randi() % 2 == 0 else my_partner.get_color()
		var _scale = get_size() if randi() % 2 == 0 else my_partner.get_size()
		
		get_parent().spawn_fish(position, _max_life, _max_hunger, _max_libido, _move_speed, _vision_radius, _color, _scale)
	
	my_partner.libido = 0
	libido = 0
	my_partner.my_partner = null
	my_partner = null


func _on_Fish_mouse_entered():
	$InformationPanel.show()


func _on_Fish_mouse_exited():
	$InformationPanel.hide()


func set_color(_color: Color) -> void:
	$Sprite.self_modulate = _color


func get_color() -> Color:
	return $Sprite.self_modulate


func set_size(_scale: Vector2) -> void:
	$Sprite.scale = _scale


func get_size() -> Vector2:
	return $Sprite.scale
