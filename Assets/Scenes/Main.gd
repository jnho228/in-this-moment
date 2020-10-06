extends Node


export var fish_object: PackedScene
export var food_object: PackedScene

onready var screen_size = get_viewport().size

var game_state := 0

# Variables
var fish_count := 0


func _ready() -> void:
	randomize()


func _process(_delta: float) -> void:
	# Input : Refine this later!
	match game_state:
		0:
			if Input.is_action_just_pressed("mouse_left_click"):
				start_game()
				$HUD/TitleLabel.hide()
				$HUD/FishCountLabel.show()
				$AudioStreamPlayer2D.play()
				game_state = 1
		1:
			if Input.is_action_just_pressed("mouse_left_click"):
				spawn_food(get_viewport().get_mouse_position())
				$AudioStreamPlayer2D.play()


func start_game() -> void:
	var fish_amount := randi() % 5 + 5
	for _x in range(fish_amount):
		var rand_color = Color(rand_range(0, 1), rand_range(0, 1), rand_range(0,1))
		var rand_scale = rand_range(0.75,1.25)
		spawn_fish(Vector2(rand_range(0,screen_size.x), rand_range(0,screen_size.y)), rand_range(150,250), rand_range(75, 125), rand_range(25, 75), rand_range(25,125), rand_range(200, 1000), rand_color, Vector2(rand_scale, rand_scale))


func spawn_fish(_position: Vector2, _max_life: float, _max_hunger: float, _max_libido: float, _move_speed: float, _vision_radius: float, _color: Color, _scale: Vector2) -> void:
	var new_fish = fish_object.instance()
	call_deferred("add_child", new_fish)
	
	new_fish.position = _position
	new_fish.max_life = _max_life
	new_fish.max_hunger = _max_hunger
	new_fish.max_libido = _max_libido
	new_fish.move_speed = _move_speed
	new_fish.vision_radius = _vision_radius
	new_fish.set_color(_color)
	new_fish.set_size(_scale)
	
	new_fish.connect("die", self, "_on_Fish_die")
	fish_count += 1
	$HUD.set_fish_count_label(fish_count)


func _on_Fish_die() -> void:
	fish_count -= 1
	$HUD.set_fish_count_label(fish_count)


func spawn_food(_position: Vector2) -> void:
	var new_food = food_object.instance()
	call_deferred("add_child", new_food)
	
	new_food.position = _position

