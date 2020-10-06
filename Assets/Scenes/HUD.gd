extends CanvasLayer


func set_fish_count_label(amount: int) -> void:
	$FishCountLabel.text = "Fish Alive: " + str(amount)
