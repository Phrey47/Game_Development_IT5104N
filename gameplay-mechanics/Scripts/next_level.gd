extends Area2D

func _on_body_entered(body):
	if body.is_in_group("Player"):
		var current_scene = get_tree().current_scene.name
		print("Current scene: ", current_scene)
		if current_scene == "Level_1":
			get_tree().call_deferred("change_scene_to_file", "res://Scenes/level_2.tscn")
		
		
