class_name MainUiController_1 extends Node

@export var selectedTilesBts: Array[Button]

var waveFunctionHandler: WaveFunctionCollapse2

func _ready():
	waveFunctionHandler = get_tree().get_root().get_node(UniversalConstants.waveFunctionScriptPath) as WaveFunctionCollapse2
	InitializeButtons()

# https://docs.godotengine.org/en/stable/classes/class_callable.html
func InitializeButtons():
	var btArrSize = selectedTilesBts.size()
	for i in btArrSize:
		# selectedTilesBts[i].connect("pressed", waveFunctionHandler.SetTile(0, i))
		selectedTilesBts[i].connect("pressed", func(): print("Button Pressed : " + str(i)))
