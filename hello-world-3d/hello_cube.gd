extends Node3D

# How fast the HelloCube moves
var speed := 2.0
var direction := 1

# Child nodes
@onready var label := $Text
@onready var box := $Box

func _ready():
	# Wait one frame to make sure Label3D geometry is ready
	call_deferred("fit_box_to_text")

func _process(delta):
	# Move the parent along X
	position.x += speed * direction * delta

	# Bounce at edges
	if position.x > 3:
		position.x = 3
		direction = -1
	elif position.x < -3:
		position.x = -3
		direction = 1

func fit_box_to_text():
	# Get the bounding box of the text
	var aabb = label.get_aabb()
	var size = aabb.size

	# Optional padding
	var padding := Vector3(0.2, 0.2, 0.1)

	# Resize the box mesh
	if box.mesh is BoxMesh:
		box.mesh.size = size + padding
	else:
		push_error("Box must be a BoxMesh")

	# Center the box on the text
	box.position = aabb.position + size * 0.5
