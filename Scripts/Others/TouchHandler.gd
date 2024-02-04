extends Node

#3d Settings
@export var _mainCam3D : Camera3D
var world3d : World3D

#2d Settings
@export var _mainCam2D : Camera2D
var world2d : World2D

#Raycast Controls
@export var collision_mask = 1
var ray_length: float

# Called when the node enters the scene tree for the first time.
func _ready():
	world3d = _mainCam3D.get_world_3d()
	world2d = _mainCam2D.get_world_2d()

func _input(event):
	if event is InputEventMouseButton:
		raycast_from_mouse_3d(event.position)
		print("Mouse Click detected at : ", event.position)

## This might not work with this setting as the scene is setup in 2D
func raycast_from_mouse_3d(mouse_pos):
	#Get Current physics state
	var space_state = world3d.direct_space_state

	#Dont need this for now, as we will be taking the mouse position at click
	#gets the current position of the mouse in the viewport
	# var mouse_pos = get_viewport().get_mouse_position()

	var ray_start = _mainCam3D.project_ray_origin(mouse_pos)
	var ray_end = ray_start +_mainCam3D.project_ray_normal(mouse_pos) * ray_length

	# var params = PhysicsRayQueryParameters3D.new()
	var raycast_query = PhysicsRayQueryParameters3D.create(ray_start, ray_end, collision_mask)
	raycast_query.collide_with_areas = true

	#Get the ray hit
	var intersection = space_state.intersect_ray(raycast_query)

	if (!intersection.is_empty()):
		var pos = intersection.position
		print("Hit Position : ", pos)

