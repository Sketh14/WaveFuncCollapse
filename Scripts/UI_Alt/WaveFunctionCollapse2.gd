extends Node
class_name WaveFunctionCollapse2

@export var debugLabel: Label
@export var gridDimension: Vector2i

# https://www.reddit.com/r/godot/comments/11g91c8/how_to_create_events/
signal tileDataInitialized_sig

# To store the tiles data from Json upon loading
var tilesJsonData

# We will access this map as a 1D array only with multiple rows and columns, each index depicting a tile 
# containing superposition tiles. 
# We will go (Dimension * Row + Column)
var tileMap: Array[Helper.SuperTileCell]

#Stack that will contain all the tiles that ar to be checked in adjacency
var tilesToCheckStack: Array[Helper.TransposedTileData]

# Called when the node enters the scene tree for the first time.
func _ready():
	# var superTileToUse = Helper.SuperTileCell.new()
	LoadAdjacencyJson()
	InitializeData()

func SetCurrentAndShowAvailableTiles(tileID: int):
	# print("Tile ID to check : " + str(tileID))
	# Offset by 1 for buttons ID
	debugLabel.text = str(tileMap[tileID - 1].tilesAvailable)

func LoadAdjacencyJson():
	if not FileAccess.file_exists(UniversalConstants.adjacencyJsonPath):
		printerr("File Does not Exists" + str(UniversalConstants.adjacencyJsonPath))
		return
	var file = FileAccess.open(UniversalConstants.adjacencyJsonPath, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	tilesJsonData = data
	print("Json loaded successfully | tiles List count : " + str(tilesJsonData.tile_info.size()))
	# print("Json Read | Name : " + str(tilesJsonData.tile_info[5].tile_name) + " | Socket Pos X : " + str(tilesJsonData.tile_info[5].socket_values[UniversalConstants.SocketDirection.POSITIVEX]))

# Initialize tiles as well as fill the tilesAvailable list at the start so that the tiles are in a super-position state 
func InitializeData():
	var totalSize = gridDimension.x * gridDimension.y
	var tilesListSize = tilesJsonData.tile_info.size()
	for valX in totalSize:
		var tileCell = Helper.SuperTileCell.new()
		tileMap.append(tileCell)
		# Really don't want to do this here
		for valY in tilesListSize:
			tileCell.tilesAvailable.append(valY)
	tileDataInitialized_sig.emit()
	
	"""
	# Testing if the data is filled out properly
	for valY in tilePrefabsList.size():
		var tilesAvailable = tileMap[2].tilesAvailable[valY]
		print("tileMap[2] | tiles Available[", valY, "] : ", tilesAvailable)
	"""

# TODO: REFACTOR BELOW


## Set a specific tile value and also check for the neighbouring tiles data
func SetTile(tileMapIndex: int, valToSet: int):
	if (tileMap.size() <= tileMapIndex || tileMapIndex < 0):
		print("TileMap Size : " + str(tileMap.size()) + " | CurrentIndex : " + str(tileMapIndex))
		return

	tileMap[tileMapIndex].currentTileIndex = valToSet
	tileMap[tileMapIndex].collapsed = true


	# var createdTile = CreateTile(valToSet, coOrdX, coOrdY)
	# createdTile.position = Vector2(32.0 * coOrdX, 32.0 * coOrdY) # Tiles size is 64 x 64
	# CreateTile(valToSet, coOrdX, coOrdY)
	
	#Set the first 4 adjacent tiles in the immediate vicinity of the current set tile
	# SetTilesToCheckData1(coOrdX, coOrdY)
	SetTilesToCheckData2(tileMapIndex)

	"""
	# Set while loop here and keep repeating unless all the adjoining cells are collapsed 
	while (tilesToCheckStack.size() > 0):
	# if (true):
		var tileToCheck = tilesToCheckStack.pop_back()
		# print("\nGot Tile to check| index : X[" + str(tileToCheck.tileCoOrdX) + "], Y[" + str(tileToCheck.tileCoOrdY) + "]")
		SetTileAdjacency(tileMapIndex, tileToCheck)
		
		#tileMapIndex error | not being set for the neighbours when it is neighbours turn
		# var tempTransposedIndex = tileToCheck.tileCoOrdX + (tileToCheck.tileCoOrdY * gridDimension.y)
		# if(!tileMap[tempTransposedIndex].collapsed):
		# 	SetTilesToCheckData(tileToCheck.tileCoOrdX, tileToCheck.tileCoOrdY)		
	# """


## Helper function to set the Stack which checks the neighbouring tiles of the current selected tile.
## It adds the right/left/bottom/top tiles to the Stack
func SetTilesToCheckData2(tileMapIndex: int):
	# var currentIndex1D = (gridDimension.x * coOrdX) + coOrdY
	var coOrdX = tileMapIndex / gridDimension.x
	var coOrdY = tileMapIndex - (coOrdX * gridDimension.x)
	print("Setting Tile Data|  X[" + str(coOrdX) + "], Y[" + str(coOrdY) + "]")
	return
	
	var tempTileData

	# Create SuperTiles along with Adjacecny Tile check in each possible direction
	var tilePosXMult = 0
	var tilePosYMult = 1
	for tileCountX in 2:
		for tileCountY in 2:
			# print("Instantiating at Position : ", position)
			var tempTileCoOrdX = coOrdX + (1 * tilePosXMult)
			var tempTileCoOrdY = coOrdY + (1 * tilePosYMult)

			if (tempTileCoOrdX >= 0 && tempTileCoOrdX < gridDimension.x
				&& tempTileCoOrdY >= 0 && tempTileCoOrdY < gridDimension.y # Check if within bounds
				&& !tileMap[(gridDimension.x * tempTileCoOrdX) + tempTileCoOrdY].collapsed): # Check if the tile is collapsed or not
				# CreateSuperTile(tempTileCoOrdX, tempTileCoOrdY)
				tempTileData = Helper.TransposedTileData.new()
				tempTileData.tileCoOrdX = tempTileCoOrdX
				tempTileData.tileCoOrdY = tempTileCoOrdY
				# Wrong Below
				# tempTileData.socketDir = ((tileCountY - tileCountX) * tilePosXMult) + ((2 + tileCountY) * tilePosYMult)
				if (tileCountX == 0):
					# Correcting according to Godot
					tempTileData.socketDir = 3 - tileCountY # Up is Negative for Godot
				else:
					tempTileData.socketDir = tileCountY

				tilesToCheckStack.push_back(tempTileData)
				# """
				print("Tile Pushed | tileCountX : " + str(tileCountX) + " | tileCountY : " + str(tileCountY)
						+ " | [" + str(tempTileCoOrdX) + "," + str(tempTileCoOrdY) + "]"
						+ " | socketDir : " + str(tempTileData.socketDir))
				# """

			tilePosYMult = tilePosYMult * -1
			tilePosXMult = tilePosXMult * -1
		tilePosYMult = 0
		tilePosXMult = 1

# Set the next tile according to the adjacency list of the current assigned tile and the direction w.r.t. current tile
# We set a loop and remove the tile indexes in the tilesAvailable list untill all non-compatible tiles are removed
func SetTileAdjacency(currTileIndex: int, tileToCheck: Helper.TransposedTileData) -> int:

	#Compare Socket | "Positive Socket" can only be compared to "Negative Socket" without rotation
	#Search down of the tile
	if (tileMap.size() > currTileIndex && currTileIndex >= 0):
		# print("Checking | Index [" + str(currTileIndex) + "] | SocketDir [" + str(tileToCheck.socketDir) + "]")

		# =========================================>		Getting Adjacent List		<======================================

		var foundTile = false
		
		var currentTilePrefabIndex = tileMap[currTileIndex].currentTileIndex # We assume that the index will be set, as without index, this shouldnt be triggered
		var adjList # Cache List to compare with

		match tileToCheck.socketDir:
			UniversalConstants.SocketDirection.POSITIVEX:
				adjList = tilesJsonData.tile_info[currentTilePrefabIndex].adjacency_list[UniversalConstants.SocketDirection.POSITIVEX]
			UniversalConstants.SocketDirection.NEGATIVEX:
				adjList = tilesJsonData.tile_info[currentTilePrefabIndex].adjacency_list[UniversalConstants.SocketDirection.NEGATIVEX]
			UniversalConstants.SocketDirection.POSITIVEY:
				adjList = tilesJsonData.tile_info[currentTilePrefabIndex].adjacency_list[UniversalConstants.SocketDirection.POSITIVEY]
			UniversalConstants.SocketDirection.NEGATIVEY:
				adjList = tilesJsonData.tile_info[currentTilePrefabIndex].adjacency_list[UniversalConstants.SocketDirection.NEGATIVEY]

		"""
		print("Adjacency List : " + str(adjList) + " | currTileIndex : " + str(currTileIndex)
				+ " | currentTilePrefabIndex : " + str(currentTilePrefabIndex));
		# """
		# =========================================>		Getting Adjacent List		<======================================


		# tilesAvailable should be sorted (in ascending order)
		# Below is to check which tile from the Prefab List can be added above the current tile
		# Should be a better way than this to do the below | Can run a binary search to find the index faster
		#TODO: IMPORTANT | Always check how 1D array index is calculated
		# var tileToCheckIndex1D = tileToCheck.tileCoOrdX + (tileToCheck.tileCoOrdY * gridDimension.y)		#TODO: WRONG
		var tileToCheckIndex1D = (gridDimension.x * tileToCheck.tileCoOrdX) + tileToCheck.tileCoOrdY
		"""
		print("Tile To Check | CoOrdX : " + str(tileToCheck.tileCoOrdX) + " | CoOrdY : " + str(tileToCheck.tileCoOrdY)
			+ " | tileToCheckIndex1D : " + str(tileToCheckIndex1D) + " | tileMap Size : " + str(tileMap.size())
			+ " | SocketDir " + str(tileToCheck.socketDir))
		# """

		var totalCount = tileMap[tileToCheckIndex1D].tilesAvailable.size()
		var tilesAvailableIndexToCheck = 0
		for tileVal in tileMap[tileToCheckIndex1D].tilesAvailable:

			# Skip if the tile at this index is not available
			if (tileVal < 0): # Tile previously has been set to 0
				totalCount -= 1

				# print("tileVal is 0 | Reducing Total Count | totalCount[" + str(totalCount) + "]\n\n")
				continue

			# Get the socket data for the tile which is to be compared
			var tempCompSocketVal # cache value to compare with
			match tileToCheck.socketDir:
				UniversalConstants.SocketDirection.POSITIVEX:
					tempCompSocketVal = tilesJsonData.tile_info[currentTilePrefabIndex].socket_values[UniversalConstants.SocketDirection.NEGATIVEX]
				UniversalConstants.SocketDirection.NEGATIVEX:
					tempCompSocketVal = tilesJsonData.tile_info[currentTilePrefabIndex].socket_values[UniversalConstants.SocketDirection.POSITIVEX]
				UniversalConstants.SocketDirection.POSITIVEY:
					tempCompSocketVal = tilesJsonData.tile_info[currentTilePrefabIndex].socket_values[UniversalConstants.SocketDirection.NEGATIVEY]
				UniversalConstants.SocketDirection.NEGATIVEY:
					tempCompSocketVal = tilesJsonData.tile_info[currentTilePrefabIndex].socket_values[UniversalConstants.SocketDirection.POSITIVEY]
			foundTile = false

			"""
			print("=====================> Checking | tileVal : " + str(tileVal) + "  | socketVal : "
					+ str(tempCompSocketVal) + " <=====================\n\n")
			# """

			# var socketIndex = 0 # THis is for debugging only
			for socketVal in adjList:
				if (socketVal == tempCompSocketVal):
					#Found Compatible Socket
					# print("Found Socket | Socket [" + str(tilesAvailableIndexToCheck) + "] : [" + str(tempCompSocketVal) + "]")
					foundTile = true
					
					#Cell fully collapsed
					if (totalCount == 1):
						tileMap[tileToCheckIndex1D].collapsed = true
						return 1
					break # No Duplicates, so break early
				# else: # Wrong | We need to compare with each tile and then set (-1), if the current comparison tile is not in the current adjacency list
				# 	tileMap[tileToCheckIndex1D].tilesAvailable[tilesAvailableIndexToCheck] = -1;

				# print("[" + str(socketIndex) + "] : " + str(tileMap[tileToCheckIndex1D].tilesAvailable[tilesAvailableIndexToCheck]) + "_" + str(socketVal) + " | ")
				# socketIndex += 1

			#This causes a bit more problem, as in, if there are more than 1 value in the adjacency list, then the values assigned by a 
			#previous match loop in the list, are removed by the very next match loop. And so everything turns to -1
			if (!foundTile):
				totalCount -= 1
				tileMap[tileToCheckIndex1D].tilesAvailable[tilesAvailableIndexToCheck] = -1
				"""
				print("Removing Tile | Socket [" + str(tilesAvailableIndexToCheck) + "] : [" + str(tileVal) + "] | tileValueRemoved : "
						+ str(tileMap[tileToCheckIndex1D].tilesAvailable[tilesAvailableIndexToCheck]));
				# """
			tilesAvailableIndexToCheck += 1
		return 0
	else:
		print("Invalid tileIndexX to search!!\n\n")
		return -1
