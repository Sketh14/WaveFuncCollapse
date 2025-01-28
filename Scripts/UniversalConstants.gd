class_name UniversalConstants

# X is Vertical | Y is Horizontal
enum SocketDirection {POSITIVEX, NEGATIVEY, NEGATIVEX, POSITIVEY}
enum TileMapStatus {DEFAULT, SET, RESET, SOLVE, ADJ_SET}

const pressedColor = Color(0, 0.55, 0, 1)
const textSize = 20
const rectRegionScaleXY = 32
const tileStartingPos = Vector2i(280, -16)
const defaultTileMapPos = Vector2i(32, 224)
const tileDistance = 56
const tileSizeAdd = 4
const waveFunctionScriptPath = "Main02/WaveFunctionCollapse2"
const mainUIControllerScriptPath = "Main02/MainUiController_1"
const adjacencyJsonPath = "res://Resources/TileAdjacencyList.json"
const mainTilePrefabPath = "res://Prefab/UI/MainTileBtPrefab_1.tscn"
const selectionTileBtPrefabPath = "res://Prefab/UI/TileSelectionBtPrefab_1.tscn"