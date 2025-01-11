class_name MainUiController_1 extends Node

@export var debugLabel: Label
@export var selectedTilesBts: Array[Button]

var waveFunctionHandler: WaveFunctionCollapse2
var selectedTileIndexInMap = 0
# var mainTileSelected = false

func _ready():
	waveFunctionHandler = get_tree().get_root().get_node(UniversalConstants.waveFunctionScriptPath) as WaveFunctionCollapse2
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
	debugLabel.text = str(waveFunctionHandler.tileMap[selectedTileIndexInMap].tilesAvailable)

	var availableTilesIndex = 0
	var btTilesIndex = 0
	var btArrSize = selectedTilesBts.size()
	var availableTilesCount = waveFunctionHandler.tileMap[selectedTileIndexInMap].tilesAvailable.size()
	while btTilesIndex != btArrSize:
		if (availableTilesIndex < availableTilesCount &&
			waveFunctionHandler.tileMap[selectedTileIndexInMap].tilesAvailable[availableTilesIndex] == btTilesIndex):
			selectedTilesBts[btTilesIndex].visible = true
			availableTilesIndex += 1
			btTilesIndex += 1
		else:
			selectedTilesBts[btTilesIndex].visible = false
			btTilesIndex += 1
