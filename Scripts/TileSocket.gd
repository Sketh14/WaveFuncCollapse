extends Node

#Sockets to be assigned from the editor
@export var posX : int
@export var negX : int
@export var posY : int
@export var negY : int

#Socket Container which will only hold the socket values
@export var socketOnly : OnlySocket

#This should match the way tilesPrefab is set up, or else wrong tiles will be instantiated
var coOrdX : int
var coOrdY : int
var index : int

#Adjacency List For each sockets
@export var adjPosX : Array[int]
@export var adjNegX : Array[int]
@export var adjPosY : Array[int]
@export var adjNegY : Array[int]

#Selection Controls
var _selected = false
var _wave_function_handler = null
var _wave_function_handler_path = "Main01/WaveFunctionCollapse"

#This could be optimized maybe
func _ready():
	process_mode = Node.PROCESS_MODE_DISABLED       # Dont need to enable this, this is only a container
	socketOnly = OnlySocket.new()
	socketOnly.PosX = posX;
	socketOnly.PosY = posY;
	socketOnly.NegX = negX;
	socketOnly.NegY = negY;
	# _wave_function_handler = get_tree().get_root().get_node("TilePrefab").name		#test line to check if the get is working properly or not
	_wave_function_handler = get_tree().get_root().get_node(_wave_function_handler_path)
	if (_wave_function_handler == null):
		print("ERROR!! | WaveFunctionHandler not found!!")

# @export var shgsr: Array[adjacencyContainer]
# class adjacencyContainer extends Resource:
#     @export var posX : Array[int]
#     @export var negX : Array[int]
#     @export var posY : Array[int]
#     @export var negY : Array[int]

func _on_area_2d_input_event(_viewport:Node, event:InputEvent, _shape_idx:int):
	if ((event is InputEventMouseButton) && !_selected):
		_selected = true
		if (_wave_function_handler != null):
			_wave_function_handler.SetTile(0,0,13)
		print("Tile Value Set!!", 0)

class OnlySocket extends Node:
	var PosX : int
	var NegX : int
	var PosY : int
	var NegY : int
