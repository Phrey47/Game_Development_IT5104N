extends Label

func _ready() -> void:
	print("label started")  # ← check Output panel for this
	modulate.a = 1.0
	await get_tree().create_timer(2.0).timeout
	print("fading now")  # ← check this prints after 2 seconds
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 1.0)
	await tween.finished
	queue_free()
