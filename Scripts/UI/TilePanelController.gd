class_name TilePanelController extends Node

var selectedSuperTileIndex: int
var placeholderTileInde: int

var tiles_grid_container

var debugPrint = ""

#Script References
var selectedSuperTile: SuperTileController # Contain a reference to the selected tile to set
var gridDimensionCache: Vector2i
var _wave_function_handler = null
var _wave_function_handler_path = "Main01/WaveFunctionCollapse"

# Called when the node enters the scene tree for the first time.
func _ready():
	tiles_grid_container = get_child(0)
	_wave_function_handler = get_tree().get_root().get_node(_wave_function_handler_path)
	gridDimensionCache = _wave_function_handler.gridDimension

# This is called from PlaceHolderTileController
# When a Super Tile needs to be assigned a tile, then this function will be called
func set_supertile_with_index(tile_index: int):
	if (selectedSuperTileIndex == -1):
		return
	
	var tempPosY = selectedSuperTileIndex / gridDimensionCache.y;
	var tempPosX = selectedSuperTileIndex % gridDimensionCache.y;
	debugPrint = "Set SuperTile[" + str(tempPosX) + "][" + str(tempPosY) + "] called with index :  " + str(tile_index)
	print(debugPrint)
	_wave_function_handler.SetTile(tempPosX, tempPosY, tile_index)

	# selectedSuperTile.get_child(1).process_mode = Node.PROCESS_MODE_DISABLED
	# selectedSuperTile.visible = false
	selectedSuperTile.queue_free()

	#Reset once the selected superTile has been set
	selectedSuperTileIndex = -1
	turn_all_tiles_off()

#This is called from SuperTileController for now
# When clicking on a super tile | THis function will be called
func set_tiles_in_panel_from_list(super_tile): # tile_index : int
	if (!is_instance_of(super_tile, SuperTileController)):
		return

	selectedSuperTile = super_tile
	var tilesInList = _wave_function_handler.tileMap[selectedSuperTileIndex].tilesAvailable
	for tileVal in tilesInList:
		if (tileVal == -1): continue
		tiles_grid_container.get_child(tileVal).visible = true

func turn_all_tiles_off():
	var tiles_in_tile_panel = tiles_grid_container.get_child_count()
	for i in tiles_in_tile_panel:
		tiles_grid_container.get_child(i).visible = false
