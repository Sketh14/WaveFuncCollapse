extends Node
class_name WaveFunctionCollapse2

@export var debugLabel: Label

# Called when the node enters the scene tree for the first time.
func _ready():
	var superTileToUse = Helper.SuperTileCell.new()
	pass # Replace with function body.

func ShowAvailableTileIdsInDebug(ids: String):
	debugLabel.text = ids
