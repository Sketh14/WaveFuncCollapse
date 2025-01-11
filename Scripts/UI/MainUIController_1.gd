class_name MainUiController_1 extends Node

@export var debugLabel: Label
@export var selectedTilesBts: Array[Button]

var waveFunctionHandler: WaveFunctionCollapse2
var selectedTileIndexInMap = 0

func _ready():
	waveFunctionHandler = get_tree().get_root().get_node(UniversalConstants.waveFunctionScriptPath) as WaveFunctionCollapse2
	InitializeButtons()

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
		selectedTilesBts[i].visible = false

func SetCurrentAndShowAvailableTiles(tileID: int):
	# print("Tile ID to check : " + str(tileID))
	# Offset by 1 for buttons ID
	selectedTileIndexInMap = tileID - 1
	debugLabel.text = str(waveFunctionHandler.tileMap[selectedTileIndexInMap].tilesAvailable)
