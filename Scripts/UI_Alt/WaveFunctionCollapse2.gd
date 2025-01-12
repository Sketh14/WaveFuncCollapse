extends Node
class_name WaveFunctionCollapse2

@export var debugLabel: Label
@export var gridDimension: Vector2i

# """
# FoR Testing
@export var testAdjForUnCollapsedBt: Button
# """

# https://www.reddit.com/r/godot/comments/11g91c8/how_to_create_events/
signal UpdateTileData_sig(tileID: int)

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

	# """
	# TESTING
	# var superTileToUse = Helper.SuperTileCell.new()
	testAdjForUnCollapsedBt.connect("pressed", TestSetTileAdjacencyForUnCollapsedTile)
	# """

	LoadAdjacencyJson()
	InitializeData()

func SetCurrentAndShowAvailableTiles(tileID: int):
	# print("Tile ID to check : " + str(tileID))
	# Offset by 1 for buttons ID
	debugLabel.text = str(tileMap[tileID].tilesAvailable)

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
	var tilesListSize = tilesJsonData.tile_info.size() - 1
	for valX in totalSize:
		var tileCell = Helper.SuperTileCell.new()
		tileMap.append(tileCell)
		# Really don't want to do this here
		for valY in tilesListSize:
			tileCell.tilesAvailable.append(valY)
			"""
			# Testing
				if valX != 3:
					tileCell.tilesAvailable.append(valY)
				else:
					if (valY % 3) == 0:
						# print("Adding tile : " + str(valY))
						tileCell.tilesAvailable.append(valY)
			"""

	# UpdateTileData_sig.emit()
	
	"""
	# Testing if the data is filled out properly
	for valY in tilePrefabsList.size():
		var tilesAvailable = tileMap[2].tilesAvailable[valY]
		print("tileMap[2] | tiles Available[", valY, "] : ", tilesAvailable)
	"""

# TODO: REFACTOR BELOW

# """
# For Testing
func TestSetTileAdjacencyForUnCollapsedTile():
	var testTileData

	testTileData = Helper.TransposedTileData.new()
	testTileData.tileCoOrdX = 0
	testTileData.tileCoOrdY = 3
	testTileData.socketDir = UniversalConstants.SocketDirection.POSITIVEX

	SetTileAdjacency(9, testTileData)
# """


## Set a specific tile value and also check for the neighbouring tiles data
func SetTile(tileMapIndex: int, valToSet: int):
	if (tileMap.size() <= tileMapIndex || tileMapIndex < 0):
		print("TileMap Size : " + str(tileMap.size()) + " | CurrentIndex : " + str(tileMapIndex))
		return

	tileMap[tileMapIndex].currentTileIndex = valToSet
	tileMap[tileMapIndex].collapsed = true
	UpdateTileData_sig.emit(tileMapIndex)

	# var createdTile = CreateTile(valToSet, coOrdX, coOrdY)
	# createdTile.position = Vector2(32.0 * coOrdX, 32.0 * coOrdY) # Tiles size is 64 x 64
	# CreateTile(valToSet, coOrdX, coOrdY)
	
	#Set the first 4 adjacent tiles in the immediate vicinity of the current set tile
	SetTilesToCheckData2(tileMapIndex)

	# """
	# Set while loop here and keep repeating unless all the adjoining cells are collapsed 
	var stackPoppdCount = 0 # For Debugging
	# while (tilesToCheckStack.size() > 0):
	if (true):
		var tileToCheck = tilesToCheckStack.pop_back()
		# print("\nGot Tile to check| index : X[" + str(tileToCheck.tileCoOrdX) + "], Y[" + str(tileToCheck.tileCoOrdY) + "]")
		SetTileAdjacency(tileMapIndex, tileToCheck)

		# Again Set the first 4 adjacent tiles in the immediate vicinity of the popped tile
		# SetTilesToCheckData2((gridDimension.x * tileToCheck.coOrdX) + tileToCheck.coOrdY)

		# For Debugging
		# stackPoppdCount += 1
		# if (stackPoppdCount > 2): break

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
	print("Setting Tile Data | tileMapIndex : " + str(tileMapIndex) + " | X[" + str(coOrdX) + "], Y[" + str(coOrdY) + "]")
	
	var tempTileData

	# Create SuperTiles along with Adjacecny Tile check in each possible direction
	var tilePosXMult = 0
	var tilePosYMult = 1
	for tileCountX in 2:
		for tileCountY in 2:
			# print("Instantiating at Position : ", position)
			var tempTileCoOrdX = coOrdX + (1 * tilePosXMult)
			var tempTileCoOrdY = coOrdY + (1 * tilePosYMult)

			if (!tileMap[(gridDimension.x * tempTileCoOrdX) + tempTileCoOrdY].collapsed # Check if the tile is collapsed or not
				&& tempTileCoOrdX >= 0 && tempTileCoOrdX < gridDimension.x
				&& tempTileCoOrdY >= 0 && tempTileCoOrdY < gridDimension.y): # Check if within bounds
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
func SetTileAdjacency(selectedTileIndex: int, tileToCheck: Helper.TransposedTileData) -> int:
	if (tileMap.size() <= selectedTileIndex || selectedTileIndex < 0):
		print("Invalid tileIndexX to search!!\n\n")
		return -1

	#Compare Socket | "Positive Socket" can only be compared to "Negative Socket" without rotation
	#Search down of the tile

	print("Checking | Index [" + str(selectedTileIndex) + "] | SocketDir [" + str(tileToCheck.socketDir) + "]"
		+ " | currentTileIndex: " + str(tileMap[selectedTileIndex].currentTileIndex)
		+ " | Dir : X[" + str(tileToCheck.tileCoOrdX) + "], Y[" + str(tileToCheck.tileCoOrdY) + "]")
	# =========================================>		Getting Adjacent List		<======================================

	# We assume that the index will be set, as without index, this shouldnt be triggered
	# var selectedTileValue = tileMap[selectedTileIndex].currentTileIndex

	"""
	# No Need as we are directly checking for Socket Direction
		# var adjList # Cache List to compare with
		var socketDirectionToCheck

		match tileToCheck.socketDir:
			UniversalConstants.SocketDirection.POSITIVEX:
				socketDirectionToCheck = UniversalConstants.SocketDirection.POSITIVEX
				# adjList = tilesJsonData.tile_info[selectedTileValue].adjacency_list[UniversalConstants.SocketDirection.POSITIVEX]
			UniversalConstants.SocketDirection.NEGATIVEX:
				socketDirectionToCheck = UniversalConstants.SocketDirection.NEGATIVEX
				# adjList = tilesJsonData.tile_info[selectedTileValue].adjacency_list[UniversalConstants.SocketDirection.NEGATIVEX]
			UniversalConstants.SocketDirection.POSITIVEY:
				socketDirectionToCheck = UniversalConstants.SocketDirection.POSITIVEY
				# adjList = tilesJsonData.tile_info[selectedTileValue].adjacency_list[UniversalConstants.SocketDirection.POSITIVEY]
			UniversalConstants.SocketDirection.NEGATIVEY:
				socketDirectionToCheck = UniversalConstants.SocketDirection.NEGATIVEY
				# adjList = tilesJsonData.tile_info[selectedTileValue].adjacency_list[UniversalConstants.SocketDirection.NEGATIVEY]
	"""

	# """
	print("Adjacency List : " + str(tilesJsonData.tile_info[tileMap[selectedTileIndex].currentTileIndex].adjacency_list[tileToCheck.socketDir]));
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

	var foundTile = false
	var availableTilesSize = tileMap[tileToCheckIndex1D].tilesAvailable.size()

	if (tileMap[selectedTileIndex].collapsed):
		var compSocketVal # cache value to compare with
		var totalAvailableTiles = availableTilesSize
		var currentAdjTileVal = -1

		# Get the "Available Tiles" list of the "Tile To Check"
		for i in availableTilesSize:

			# Skip if the tile at this index is not available
			if (tileMap[tileToCheckIndex1D].tilesAvailable[i] < 0): # Tile previously has been set to -1
				totalAvailableTiles -= 1
				# print("i is 0 | Reducing Total Count | availableTilesSize[" + str(availableTilesSize) + "]\n\n")
				continue

			# Get the socket data for the tile which is to be compared
			match tileToCheck.socketDir:
				UniversalConstants.SocketDirection.POSITIVEX:
					compSocketVal = (tilesJsonData.tile_info[i].socket_values[UniversalConstants.SocketDirection.NEGATIVEX])
				UniversalConstants.SocketDirection.NEGATIVEX:
					compSocketVal = (tilesJsonData.tile_info[i].socket_values[UniversalConstants.SocketDirection.POSITIVEX])
				UniversalConstants.SocketDirection.POSITIVEY:
					compSocketVal = (tilesJsonData.tile_info[i].socket_values[UniversalConstants.SocketDirection.NEGATIVEY])
				UniversalConstants.SocketDirection.NEGATIVEY:
					compSocketVal = (tilesJsonData.tile_info[i].socket_values[UniversalConstants.SocketDirection.POSITIVEY])
			foundTile = false

			"""
			print("=====================> Checking | i : " + str(i)
					+ " | TilesAvailable Val : " + str(tileMap[tileToCheckIndex1D].tilesAvailable[i])
					+ " | adjSocketVal : " + str(compSocketVal) + " <=====================\n\n")
			# """

			# var socketIndex = 0 # THis is for debugging only
				
			# Get the comaptible socket values in the respective "Adjacency List" of the "Current Selected Tile" 
			# which is in the direction of the "Tile To Compare"
			# for adjSocketVal in adjList:
			for adjSocketVal in (tilesJsonData.tile_info[(tileMap[selectedTileIndex].currentTileIndex)]
								.adjacency_list[tileToCheck.socketDir]):
				# print("Adjacency Socket Val : " + str(adjSocketVal))

				# Check if the "Comparison Tile's" "Socket Value" in the desired direction is equal to the adjacency socket value 
				if (compSocketVal == adjSocketVal):
					currentAdjTileVal = i
					# print("Found Socket | Socket [" + str(tilesAvailableIndexToCheck) + "] : [" + str(compSocketVal) + "]")
					foundTile = true
					break

				# print("[" + str(socketIndex) + "] : " + str(tileMap[tileToCheckIndex1D].tilesAvailable[tilesAvailableIndexToCheck]) + "_" + str(adjSocketVal) + " | ")
				# socketIndex += 1

			#This causes a bit more problem, as in, if there are more than 1 value in the adjacency list, then the values assigned by a 
			#previous match loop in the list, are removed by the very next match loop. And so everything turns to -1
			if (!foundTile):
				totalAvailableTiles -= 1
				tileMap[tileToCheckIndex1D].tilesAvailable[i] = -1
				"""
				print("Removing Tile | Socket [" + str(tilesAvailableIndexToCheck) + "] : [" + str(i) + "] | tileValueRemoved : "
						+ str(tileMap[tileToCheckIndex1D].tilesAvailable[tilesAvailableIndexToCheck]));
				# """

		#Cell fully collapsed
		if (totalAvailableTiles == 1):
			tileMap[tileToCheckIndex1D].collapsed = true
			tileMap[tileToCheckIndex1D].currentTileIndex = currentAdjTileVal
			UpdateTileData_sig.emit(tileToCheckIndex1D)
			return 1
	else:
		# This tile will not be collapsed by the following operations as the tile from which it is being called is not collapsed
		# As the "Selected Tile" is not collapsed, there can be no way of only 1 possible solution existing for the "Tile Being Checked".
		# If the Solution exists, then there are duplicates in the "TilesAvailable" list

		# Disable Everything in the "Available Tiles" list of the "Tile To Check"
		for i in availableTilesSize:
			tileMap[tileToCheckIndex1D].tilesAvailable[i] = -1

		# Get the socket direction for the tile which is to be compared
		var compSocketDir
		match tileToCheck.socketDir:
			UniversalConstants.SocketDirection.POSITIVEX:
				compSocketDir = UniversalConstants.SocketDirection.NEGATIVEX
			UniversalConstants.SocketDirection.NEGATIVEX:
				compSocketDir = UniversalConstants.SocketDirection.POSITIVEX
			UniversalConstants.SocketDirection.POSITIVEY:
				compSocketDir = UniversalConstants.SocketDirection.NEGATIVEY
			UniversalConstants.SocketDirection.NEGATIVEY:
				compSocketDir = UniversalConstants.SocketDirection.POSITIVEY

		var selectedTileAdjListSize = 0
		# Get the "Available Tiles" list of the "Tile To Check"
		for i in availableTilesSize:

			# Skip if the tile at this index as it is not available
			if (tileMap[selectedTileIndex].tilesAvailable[i] < 0):
				# print("i is 0 | Reducing Total Count | availableTilesSize[" + str(availableTilesSize) + "]\n\n")
				continue

			"""
			print("=====================> Checking | i : " + str(i)
					+ " | TilesAvailable Val : " + str(tileMap[tileToCheckIndex1D].tilesAvailable[i])
					+ " | adjSocketVal : " + str(compSocketDir) + " <=====================\n\n")
			# """

			# var socketIndex = 0 # THis is for debugging only
				
			# Get the comaptible socket values in the respective "Adjacency List" of the "Current Selected Tile" 
			# which is in the direction of the "Tile To Compare"
			selectedTileAdjListSize = tilesJsonData.tile_info[i].adjacency_list.size()
			for j in selectedTileAdjListSize:

				# Check from the "Available Tiles", which tile's socket value in the desired direction
				# is equal to the adjacency socket value
				for k in availableTilesSize:
					if (tilesJsonData.tile_info[i].adjacency_list[tileToCheck.socketDir][j]
						== tilesJsonData.tile_info[k].socket_values[compSocketDir]):
						print("Found Socket | Socket [" + str(k) + "] : [" + str(compSocketDir) + "]")
						tileMap[tileToCheckIndex1D].tilesAvailable[i] = i
						break
					# print("Adjacency Socket Val : " + str(tilesJsonData.tile_info[i].adjacency_list[j]))


			#This causes a bit more problem, as in, if there are more than 1 value in the adjacency list, then the values assigned by a 
			#previous match loop in the list, are removed by the very next match loop. And so everything turns to -1
			# if (!foundTile):
			# 	tileMap[tileToCheckIndex1D].tilesAvailable[i] = -1
			"""
			print("Removing Tile | Socket [" + str(tilesAvailableIndexToCheck) + "] : [" + str(i) + "] | tileValueRemoved : "
					+ str(tileMap[tileToCheckIndex1D].tilesAvailable[tilesAvailableIndexToCheck]));
			# """

		UpdateTileData_sig.emit(tileToCheckIndex1D)

	# UpdateTileData_sig.emit()
	return 0
