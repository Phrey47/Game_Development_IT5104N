extends Node2D

func _ready():
	$Label.visible = true
	await get_tree().create_timer(2.0).timeout
	$Label.visible = false
