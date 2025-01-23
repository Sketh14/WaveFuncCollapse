class_name MainUiController_1 extends Node

@export var debugLabel: Label
@export var solveTileMap: Button
@export var selectionTilesContainer: Control

var selectedTilesBts2: Array[Button]
var waveFunctionHandler: WaveFunctionCollapse2
var selectedTileIndexInMap = 0
# var mainTileSelected = false

func _ready():
	waveFunctionHandler = get_tree().get_root().get_node(UniversalConstants.waveFunctionScriptPath) as WaveFunctionCollapse2
	waveFunctionHandler.UpdateTileData_sig.connect(SetCurrentAndShowAvailableTiles)
	waveFunctionHandler.JsonLoaded_sig.connect(InitializeButtons)

	solveTileMap.connect("pressed",
	func():
		solveTileMap.disabled = true
		waveFunctionHandler.SolveModel())

	# InitializeButtons()
	# DisableAllSelecttionTiles()

# https://docs.godotengine.org/en/stable/classes/class_callable.html
func InitializeButtons():
	var selectionTileBtPrefab = load(UniversalConstants.selectionTileBtPrefabPath)
	var btToInstantiate
	var tilesListSize = waveFunctionHandler.tilesJsonData.tile_info.size() - 1
	var tileTex: TextureRect
	var randomBgIndex: int
	var tileTexIndex: int
	for i in tilesListSize:
		btToInstantiate = selectionTileBtPrefab.instantiate()
		selectionTilesContainer.add_child(btToInstantiate)
		selectedTilesBts2.append(btToInstantiate)
		btToInstantiate.connect("pressed", func(): SetTileViaWaveFunctionHandler(i))
		btToInstantiate.text = str(i)

		"""
		var btArrSize = selectedTilesBts.size()
		# var tileTex: TextureRect
		for i in btArrSize:
			selectedTilesBts[i].connect("pressed", func(): SetTileViaWaveFunctionHandler(i))
			selectedTilesBts[i].text = str(i)
			# selectedTilesBts[i].connect("pressed", func(): print("Button Pressed : " + str(i)))
		"""

		# Setting AtlasTexture of the tile
		# print("Setting Tile Textures")
	# for i in btArrSize:
		tileTexIndex = waveFunctionHandler.tilesJsonData.tile_info[i].atlas_texture_properties[0]

		# Setting the Bg first
		tileTex = btToInstantiate.get_child(0)
		tileTex.texture = waveFunctionHandler.tileAtlasTexture.duplicate()
		# If defined, then get Index of the BG
		if (tileTexIndex == 0):
			tileTex.texture.region = Rect2(waveFunctionHandler.tilesJsonData.tile_info[i].atlas_texture_properties[1],
						waveFunctionHandler.tilesJsonData.tile_info[i].atlas_texture_properties[2],
						UniversalConstants.rectRegionScaleXY, UniversalConstants.rectRegionScaleXY)
		# If not, then get a random BG Index
		else:
			randomBgIndex = randi_range(4, 7)
			tileTex.texture.region = Rect2(waveFunctionHandler.tilesJsonData.tile_info[randomBgIndex].atlas_texture_properties[1],
						waveFunctionHandler.tilesJsonData.tile_info[randomBgIndex].atlas_texture_properties[2],
						UniversalConstants.rectRegionScaleXY, UniversalConstants.rectRegionScaleXY)

		# Setting foreground
		tileTex = btToInstantiate.get_child(1)
		# tileTex.texture = waveFunctionHandler.tileAtlasTextures[waveFunctionHandler.tilesJsonData.tile_info[i].atlas_texture_properties[0]].duplicate()
		# Getting Index of the proper atlas to use
		tileTex.texture = waveFunctionHandler.tileAtlasTexture.duplicate()
		tileTex.texture.region = Rect2(waveFunctionHandler.tilesJsonData.tile_info[i].atlas_texture_properties[1],
					waveFunctionHandler.tilesJsonData.tile_info[i].atlas_texture_properties[2],
					UniversalConstants.rectRegionScaleXY, UniversalConstants.rectRegionScaleXY)
	
	DisableAllSelecttionTiles()


func SetTileViaWaveFunctionHandler(btIndex: int):
	waveFunctionHandler.SetTile(selectedTileIndexInMap, btIndex)

func DisableAllSelecttionTiles():
	var btArrSize = selectedTilesBts2.size()
	for i in btArrSize:
		# print("Disabling Tile : " + str(i))
		selectedTilesBts2[i].visible = false

func SetCurrentAndShowAvailableTiles(tileID: int):
	# print("Tile ID to check : " + str(tileID))

	# Offset by 1 for buttons ID
	selectedTileIndexInMap = tileID
	debugLabel.text = ("Tile ID : " + str(tileID) + " | Tiles Avl: " + str(waveFunctionHandler.tileMap[selectedTileIndexInMap].tilesAvailable)
	+ "\n Collapsed: " + str(waveFunctionHandler.tileMap[selectedTileIndexInMap].collapsed)
	+ "\n TilesCount: " + str(waveFunctionHandler.tileMap[selectedTileIndexInMap].tilesCount))

	var btArrSize = selectedTilesBts2.size()
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
			selectedTilesBts2[i].visible = false
		else:
			selectedTilesBts2[i].visible = true
