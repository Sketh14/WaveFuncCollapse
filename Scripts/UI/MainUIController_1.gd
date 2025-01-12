class_name MainUiController_1 extends Node

@export var debugLabel: Label
@export var selectedTilesBts: Array[Button]

var waveFunctionHandler: WaveFunctionCollapse2
var selectedTileIndexInMap = 0
# var mainTileSelected = false

func _ready():
	waveFunctionHandler = get_tree().get_root().get_node(UniversalConstants.waveFunctionScriptPath) as WaveFunctionCollapse2
	waveFunctionHandler.UpdateTileData_sig.connect(SetCurrentAndShowAvailableTiles)

	InitializeButtons()
	DisableAllTiles()

# https://docs.godotengine.org/en/stable/classes/class_callable.html
func InitializeButtons():
	var btArrSize = selectedTilesBts.size()
	for i in btArrSize:
		selectedTilesBts[i].connect("pressed", func(): SetTileViaWaveFunctionHandler(i))
		selectedTilesBts[i].text = str(i)
		# selectedTilesBts[i].connect("pressed", func(): print("Button Pressed : " + str(i)))

func SetTileViaWaveFunctionHandler(btIndex: int):
	waveFunctionHandler.SetTile(selectedTileIndexInMap, btIndex)

func DisableAllTiles():
	var btArrSize = selectedTilesBts.size()
	for i in btArrSize:
		# print("Disabling Tile : " + str(i))
		selectedTilesBts[i].visible = false

func SetCurrentAndShowAvailableTiles(tileID: int):
	# print("Tile ID to check : " + str(tileID))

	# Offset by 1 for buttons ID
	selectedTileIndexInMap = tileID
	debugLabel.text = ("Tile ID : " + str(tileID) + " | Tiles Avl: " + str(waveFunctionHandler.tileMap[selectedTileIndexInMap].tilesAvailable)
	+ "\n Collapsed: " + str(waveFunctionHandler.tileMap[selectedTileIndexInMap].collapsed))


	var btArrSize = selectedTilesBts.size() - 1
	"""
		var availableTilesIndex = 0
		var btTilesIndex = 0
		var availableTilesCount = waveFunctionHandler.tileMap[selectedTileIndexInMap].tilesAvailable.size()

		# Array is sorted which is why, this below is possible		# This is Wrong
		while btTilesIndex != btArrSize:
			if (availableTilesIndex < availableTilesCount &&
				waveFunctionHandler.tileMap[selectedTileIndexInMap].tilesAvailable[availableTilesIndex] == btTilesIndex):
				selectedTilesBts[btTilesIndex].visible = true
				availableTilesIndex += 1
				btTilesIndex += 1
			else:
				selectedTilesBts[btTilesIndex].visible = false
				btTilesIndex += 1
	"""

	# As the tile has been collapsed, it should not have any available possible tiles to be placed on it
	# if (waveFunctionHandler.tileMap[selectedTileIndexInMap].collapsed): return

	for i in btArrSize:
		if (waveFunctionHandler.tileMap[selectedTileIndexInMap].collapsed
			|| waveFunctionHandler.tileMap[selectedTileIndexInMap].tilesAvailable[i] == -1):
			selectedTilesBts[i].visible = false
		else:
			selectedTilesBts[i].visible = true
