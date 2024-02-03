extends Node

#Sockets to be assigned from the editor
@export var posX : int
@export var negX : int
@export var posY : int
@export var negY : int

#Socket Container which will only hold the socket values
@export var socketOnly : OnlySocket

#Adjacency List For each sockets
@export var adjPosX : Array[int]
@export var adjNegX : Array[int]
@export var adjPosY : Array[int]
@export var adjNegY : Array[int]

#Touch Controls
var _selected = false

#This could be optimized maybe
func _ready():
	process_mode = Node.PROCESS_MODE_DISABLED       # Dont need to enable this, this is only a container
	socketOnly = OnlySocket.new()
	socketOnly.PosX = posX;
	socketOnly.PosY = posY;
	socketOnly.NegX = negX;
	socketOnly.NegY = negY;

# @export var shgsr: Array[adjacencyContainer]
# class adjacencyContainer extends Resource:
#     @export var posX : Array[int]
#     @export var negX : Array[int]
#     @export var posY : Array[int]
#     @export var negY : Array[int]



func _on_area_2d_mouse_entered():
	# print("Mouse entered tile")
	pass # Replace with function body.




func _on_area_2d_input_event(viewport:Node, event:InputEvent, shape_idx:int):
	print("Mouse input event")
	pass # Replace with function body.


class OnlySocket extends Node:
	var PosX : int
	var NegX : int
	var PosY : int
	var NegY : int

