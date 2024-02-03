extends Node

#Raycast Controls
@export var _mainCam : Camera2D
var world2d : World2D
var ray_length: float

# Called when the node enters the scene tree for the first time.
func _ready():
	world2d = _mainCam.get_world_2d()

func _input(event):
	if event is InputEventMouseButton:
		print("Mouse Click detected at : ", event.position)

## This might not work with this setting as the scene is setup in 2D
func raycast_from_mouse(m_pos, collision_mask):
	var ray_start = _mainCam.project_ray_origin(m_pos)
	var ray_end = ray_start + _mainCam.project_ray_normal(m_pos) * ray_length
	var space_state = world2d.direct_space_state
	
	if space_state == null:
		return
	
	var query = PhysicsRayQueryParameters3D.create(ray_start, ray_end, collision_mask)
	query.collide_with_areas = true
	
	return space_state.intersect_ray(query)
