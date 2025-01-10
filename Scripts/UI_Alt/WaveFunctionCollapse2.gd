extends Node
class_name WaveFunctionCollapse2

@export var debugLabel: Label
var adjacencyData

# Called when the node enters the scene tree for the first time.
func _ready():
	# var superTileToUse = Helper.SuperTileCell.new()
	LoadAdjacencyJson()

func ShowAvailableTileIdsInDebug(ids: int):
	debugLabel.text = ids

func LoadAdjacencyJson():
	if not FileAccess.file_exists(UniversalConstants.adjacencyJsonPath):
		printerr("File Does not Exists" + str(UniversalConstants.adjacencyJsonPath))
		return
	var file = FileAccess.open(UniversalConstants.adjacencyJsonPath, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	adjacencyData = data
	# print("Json Read | Name : " + str(adjacencyData.tile_info[5].tile_name) + " | Socket Pos X : " + str(adjacencyData.tile_info[5].socket_values[UniversalConstants.SocketDirection.POSITIVEX]))
