"""
This is the Controller for UI Tile which can be selected to set the selected Super Tile
"""

extends Control

@export var tileIndex: int
@export var tileLabel: Label

var tilePanelController = null
var tilePanelControllerPath = "Main01/MainCanvasLayer/PlaceHolderTile_Panel"

# Called when the node enters the scene tree for the first time.
func _ready():
	tileLabel.text = str(tileIndex)
	tilePanelController = get_tree().get_root().get_node(tilePanelControllerPath)
	if (tilePanelController == null):
		print("Tile Panel Controller Not Found")

func _on_button_pressed():
	print("Button Pressed : ", tileIndex)
	tilePanelController.set_supertile_with_index(tileIndex)
