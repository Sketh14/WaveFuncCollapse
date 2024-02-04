extends Node2D

@export var superTileIndex : int

var tilePanelController = null
var tilePanelControllerPath = "Main01/MainCanvasLayer/PlaceHolderTile_Panel"

# Called when the node enters the scene tree for the first time.
func _ready():
	tilePanelController = get_tree().get_root().get_node(tilePanelControllerPath)
	if (tilePanelController == null):
		print("Tile Panel Controller Not Found")

func _on_area_2d_input_event(_viewport:Node, event:InputEvent, _shape_idx:int):
	if (event is InputEventMouseButton && event.is_action_pressed("Clicked")):
		tilePanelController.selectedSuperTileIndex = superTileIndex
		tilePanelController.set_tiles_in_panel_from_list()
		print("Set Super Tile index : ", superTileIndex)
