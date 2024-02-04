extends Control

var selectedSuperTileIndex : int
var placeholderTileInde : int

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func set_supertile_with_index(tileIndex : int):
	print("Set SuperTile called with index :  ", tileIndex)

	#Reset once the selected superTile has been set
	selectedSuperTileIndex = -1
