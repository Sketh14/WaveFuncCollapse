extends Node
class_name WaveFunctionCollapse2

@export var debugLabel: Label
# @export var gridDimension: Vector2i
@export var gridDimension: int
@export var tileAtlasTextures: Array[AtlasTexture]

# """
# FoR Testing
@export var testAdjForUnCollapsedBt: Button
# """

# https://www.reddit.com/r/godot/comments/11g91c8/how_to_create_events/
signal UpdateTileData_sig(tileID: int)
signal JsonLoaded_sig()

# To store the tiles data from Json upon loading
var tilesJsonData

# We will access this map as a 1D array only with multiple rows and columns, each index depicting a tile 
# containing superposition tiles. 
# We will go (Dimension * Row + Column)
var tileMap: Array[Helper.SuperTileCell]

#Stack that will contain all the tiles that ar to be checked in adjacency
var tilesToCheckStack: Array[int]

# List to store all the "Adjacency List" of the available tiles in the selected tile's list
var superAdjList: Array[int]

# Called when the node enters the scene tree for the first time.
func _ready():

	# """
	# TESTING
	# var superTileToUse = Helper.SuperTileCell.new()
	testAdjForUnCollapsedBt.connect("pressed", TestSetTileAdjacencyForUnCollapsedTile)
	# """

	LoadAdjacencyJson()
	InitializeData()
	# Test1()

func Test1():
	var test1 = 10.0
	match (typeof(test1)):
		TYPE_INT:
			print("Integer : " + str(typeof(test1)))
		TYPE_FLOAT:
			print("Float : " + str(typeof(test1)))


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

	await get_tree().create_timer(1.0).timeout # Waiting for other systems to load | TODO:  Should be a better solution than this
	JsonLoaded_sig.emit()
	# print("Json Read | Name : " + str(tilesJsonData.tile_info[5].tile_name) + " | Socket Pos X : " + str(tilesJsonData.tile_info[5].socket_values[UniversalConstants.SocketDirection.POSITIVEX]))

# Initialize tiles as well as fill the tilesAvailable list at the start so that the tiles are in a super-position state 
func InitializeData():
	# var totalSize = gridDimension.x * gridDimension.y
	var totalSize = gridDimension * gridDimension
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
	
	#Set the first 4 adjacent tiles in the immediate vicinity of the current set tile
	# SetTilesToCheckData2(tileMapIndex, tileMapIndex)
	tilesToCheckStack.push_back(tileMapIndex) # Add Current tile to the top

	# """
	var poppedTileIndex = -1
	var coOrdX = -1
	var coOrdY = -1

	var coOrdXMult = 0
	var coOrdYMult = 1
	# var tempTileCoOrdX = -1
	# var tempTileCoOrdY = -1

	var tileToCheckData = Helper.TransposedTileData.new()

	# Set while loop here and keep repeating unless all the adjoining cells are collapsed 
	var stackPoppdCount = 0 # For Debugging
	while (tilesToCheckStack.size() > 0):
	# if (true):
		poppedTileIndex = tilesToCheckStack.pop_back()
		coOrdX = (poppedTileIndex / gridDimension)
		coOrdY = poppedTileIndex % gridDimension
		# print("\n\nGot Tile to check| index : X[" + str(coOrdX) + "], Y[" + str(coOrdY) + "]")
		
		coOrdXMult = 0
		coOrdYMult = 1

		# Create SuperTiles along with Adjacecny Tile check in each possible direction
		for tileCountX in 2:
			for tileCountY in 2:
				# print("Instantiating at Position : ", position)
				tileToCheckData.tileCoOrdX = coOrdX + (1 * coOrdXMult)
				tileToCheckData.tileCoOrdY = coOrdY + (1 * coOrdYMult)
				# print("Tile CoOrd : [" + str(tileToCheckData.tileCoOrdX) + "," + str(tileToCheckData.tileCoOrdY) + "]")

				# Check if within bounds
				if (tileToCheckData.tileCoOrdX < 0 || tileToCheckData.tileCoOrdX >= gridDimension
					|| tileToCheckData.tileCoOrdY < 0 || tileToCheckData.tileCoOrdY >= gridDimension
					|| tileMap[(gridDimension * tileToCheckData.tileCoOrdX) + tileToCheckData.tileCoOrdY].collapsed):
						continue # Continue if outside bounds

				if (tileCountX == 0):
					# Correcting according to Godot
					tileToCheckData.socketDir = 3 - tileCountY # Up is Negative for Godot
				else:
					tileToCheckData.socketDir = tileCountY
					
				"""
				print("Checking Tile | tileCountX : " + str(tileCountX) + " | tileCountY : " + str(tileCountY)
						+ " | [" + str(tileToCheckData.tileCoOrdX) + "," + str(tileToCheckData.tileCoOrdY) + "]"
						+ " | socketDir : " + str(tileToCheckData.socketDir)
						+ " | tileMapVal : " + str((gridDimension * tileToCheckData.tileCoOrdX) + tileToCheckData.tileCoOrdY))
				# """

				if (SetTileAdjacency(poppedTileIndex, tileToCheckData)):
					"""
					print("=========> Pushing Tile Data | refTileMapIndex : " + str((gridDimension * tileToCheckData.tileCoOrdX) + tileToCheckData.tileCoOrdY)
						+ " | X[" + str(tileToCheckData.tileCoOrdX) + "], Y[" + str(tileToCheckData.tileCoOrdY) + "] <=======")
					# """
					tilesToCheckStack.push_back((gridDimension * tileToCheckData.tileCoOrdX) + tileToCheckData.tileCoOrdY) # Add Current tile to the top

				# Again Set the first 4 adjacent tiles in the immediate vicinity of the popped tile
				# SetTilesToCheckData2(refTileMapIndex, (gridDimension * poppedTileIndex.tileCoOrdX) + poppedTileIndex.tileCoOrdY)


				#tileMapIndex error | not being set for the neighbours when it is neighbours turn
				# var tempTransposedIndex = tileToCheck.tileCoOrdX + (tileToCheck.tileCoOrdY * gridDimension.y)
				# if(!tileMap[tempTransposedIndex].collapsed):
				# 	SetTilesToCheckData(tileToCheck.tileCoOrdX, tileToCheck.tileCoOrdY)	
				
				coOrdYMult = coOrdYMult * -1
				coOrdXMult = coOrdXMult * -1
			coOrdYMult = 0
			coOrdXMult = 1

		# For Debugging
		# stackPoppdCount += 1
		# if (stackPoppdCount > 1): break
	# """
	print("Stack Count : " + str(tilesToCheckStack.size()))


## Helper function to set the Stack which checks the neighbouring tiles of the current selected tile.
## It adds the right/left/bottom/top tiles to the Stack
func SetTilesToCheckData2(parentTileID: int, refTileMapIndex: int):
	# var currentIndex1D = (gridDimension.x * coOrdX) + coOrdY
	var coOrdX = (refTileMapIndex / gridDimension)
	var coOrdY = refTileMapIndex - (coOrdX * gridDimension)
	print("=========> Setting Tile Data | refTileMapIndex : " + str(refTileMapIndex) + " | X[" + str(coOrdX) + "], Y[" + str(coOrdY) + "] <=======\n")
	
	var tempTileData

	# Create SuperTiles along with Adjacecny Tile check in each possible direction
	var tilePosXMult = 0
	var tilePosYMult = 1
	var tempTileCoOrdX = -1
	var tempTileCoOrdY = -1
	for tileCountX in 2:
		for tileCountY in 2:
			# print("Instantiating at Position : ", position)
			tempTileCoOrdX = coOrdX + (1 * tilePosXMult)
			tempTileCoOrdY = coOrdY + (1 * tilePosYMult)

			if (tempTileCoOrdX >= 0 && tempTileCoOrdX < gridDimension # Check if within bounds
				&& tempTileCoOrdY >= 0 && tempTileCoOrdY < gridDimension
				&& !tileMap[(gridDimension * tempTileCoOrdX) + tempTileCoOrdY].collapsed # Check if the tile is collapsed or not
				&& ((gridDimension * tempTileCoOrdX) + tempTileCoOrdY) != parentTileID): # Check if we are not adding the Calling Tile
				
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

				tempTileData.parentTileID = refTileMapIndex

				tilesToCheckStack.push_back(tempTileData)
				# """
				print("Tile Pushed | tileCountX : " + str(tileCountX) + " | tileCountY : " + str(tileCountY)
						+ " | [" + str(tempTileCoOrdX) + "," + str(tempTileCoOrdY) + "]"
						+ " | socketDir : " + str(tempTileData.socketDir)
						+ " | tileMapVal : " + str((gridDimension * tempTileCoOrdX) + tempTileCoOrdY))
				# """

			tilePosYMult = tilePosYMult * -1
			tilePosXMult = tilePosXMult * -1
		tilePosYMult = 0
		tilePosXMult = 1
	print("=========> Setting Tile Data <=======\n")
	

# Set the next tile according to the adjacency list of the current assigned tile and the direction w.r.t. current tile
# We set a loop and remove the tile indexes in the tilesAvailable list untill all non-compatible tiles are removed
func SetTileAdjacency(selectedTileIndex: int, tileToCheck: Helper.TransposedTileData) -> bool:
	if (tileMap.size() <= selectedTileIndex || selectedTileIndex < 0):
		print("Invalid tileIndexX to search!!\n\n")
		return false

	#Compare Socket | "Positive Socket" can only be compared to "Negative Socket" without rotation
	#Search down of the tile

	"""
	print("Checking | Index [" + str(selectedTileIndex) + "] | SocketDir [" + str(tileToCheck.socketDir) + "]"
		+ " | currentTileIndex: " + str(tileMap[selectedTileIndex].currentTileIndex)
		+ " | Dir : X[" + str(tileToCheck.tileCoOrdX) + "], Y[" + str(tileToCheck.tileCoOrdY) + "]")
	# """

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

	"""
	print("Adjacency List : " + str(tilesJsonData.tile_info[tileMap[selectedTileIndex].currentTileIndex].adjacency_list[tileToCheck.socketDir]));
	# """

	# =========================================>		Getting Adjacent List		<======================================


	# tilesAvailable should be sorted (in ascending order)
	# Below is to check which tile from the Prefab List can be added above the current tile
	# Should be a better way than this to do the below | Can run a binary search to find the index faster
	
	#TODO: IMPORTANT | Always check how 1D array index is calculated
	# var tileToCheckIndex1D = tileToCheck.tileCoOrdX + (tileToCheck.tileCoOrdY * gridDimension.y)		#TODO: WRONG
	var tileToCheckIndex1D = (gridDimension * tileToCheck.tileCoOrdX) + tileToCheck.tileCoOrdY
	"""
	print("Tile To Check | CoOrdX : " + str(tileToCheck.tileCoOrdX) + " | CoOrdY : " + str(tileToCheck.tileCoOrdY)
		+ " | tileToCheckIndex1D : " + str(tileToCheckIndex1D) + " | tileMap Size : " + str(tileMap.size())
		+ " | SocketDir " + str(tileToCheck.socketDir))
	# """

	var tileChanged = false
	var availableTilesSize = tileMap[tileToCheckIndex1D].tilesAvailable.size()

	if (tileMap[selectedTileIndex].collapsed):
		var foundTile = false
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
					tileChanged = true
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
			# return 1
	# TODO: FIXXXX THISSSS
	else:
		# This tile will not be collapsed by the following operations as the tile from which it is being called is not collapsed
		# As the "Selected Tile" is not collapsed, there can be no way of only 1 possible solution existing for the "Tile Being Checked".
		# If the Solution exists, then there are duplicates in the "TilesAvailable" list

		# Creating a Super List for adjacency
		superAdjList.clear()
		var selectedTileAdjListSize = 0
		var tempAdjVal = -1
		var sameAdjValFound = false
		for i in availableTilesSize:

			# Skip not available tiles
			if (tileMap[selectedTileIndex].tilesAvailable[i] < 0):
				continue

			sameAdjValFound = false
			# selectedTileAdjListSize = tilesJsonData.tile_info[tileMap[tileToCheckIndex1D].tilesAvailable[i]].adjacency_list[tileToCheck.socketDir].size()
			selectedTileAdjListSize = tilesJsonData.tile_info[i].adjacency_list[tileToCheck.socketDir].size()
			# print("i["+str(i)+"] | Adj List : " + str(tilesJsonData.tile_info[i].adjacency_list[tileToCheck.socketDir]))
			for j in selectedTileAdjListSize:
				tempAdjVal = tilesJsonData.tile_info[i].adjacency_list[tileToCheck.socketDir][j] as int

				#Check if the value is present in the Super List before adding to it
				for tempArrVal in superAdjList:
					if (tempArrVal == tempAdjVal):
						sameAdjValFound = true
						break
				if (!sameAdjValFound):
					# superAdjList.push_back(tilesJsonData.tile_info[tileMap[tileToCheckIndex1D].tilesAvailable[i]].adjacency_list[tileToCheck.socketDir][j])
					superAdjList.push_back(tempAdjVal)
					# print("j[" + str(j) + "] | Adj Val : " + str(tempAdjVal)
					# 	+ " | type : " + str(typeof(tempAdjVal)) + " | Count : " + str(superAdjList.size()))
					
		# print("Super Adj List | Count : " + str(superAdjList.size()) + " | Val :" + str(superAdjList))
		# return false						# FOR DEBUGGING

		# TODO: REMOVEEEEEEEEE
		# The below is wrong as we we are adding new tiles to the checking tile instead of removing as we have to reduce it,
		# and not increase it.
			# tileChanged = true
			# Disable Everything in the "Available Tiles" list of the "Tile To Check"
			# for i in availableTilesSize:
			# 	tileMap[tileToCheckIndex1D].tilesAvailable[i] = -1

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

		"""
		print("Available Tiles | Count : " + str(tileMap[tileToCheckIndex1D].tilesAvailable.size())
				+ " | Val : " + str(tileMap[tileToCheckIndex1D].tilesAvailable))
		# """

		# Get the "Available Tiles" list of the "Tile To Check"
		for i in availableTilesSize:

			# Skip if the tile at this index as it is not available
			if (tileMap[tileToCheckIndex1D].tilesAvailable[i] < 0):
				# print("i is 0 | Reducing Total Count | availableTilesSize[" + str(availableTilesSize) + "]\n\n")
				continue

			"""
			print("=====================> Checking | i : " + str(i)
					+ " | TilesAvailable Val : " + str(tileMap[tileToCheckIndex1D].tilesAvailable[i])
					+ " | adjSocketVal : " + str(compSocketDir) + " <=====================\n\n")
			# """

			# var socketIndex = 0 # THis is for debugging only
			
			sameAdjValFound = false
			# Get the comaptible socket values in the respective "Adjacency List" of the "Current Selected Tile" 
			# which is in the direction of the "Tile To Compare"
			selectedTileAdjListSize = superAdjList.size()
			for j in selectedTileAdjListSize:

				# Check from the "Available Tiles", which tile's socket value in the desired direction
				# is equal to the adjacency socket value
				if (superAdjList[j] == tilesJsonData.tile_info[i].socket_values[compSocketDir]):
					# print("Found Socket | Socket [" + str(i) + "] : [" + str(superAdjList[j]) + "] | [" + str(compSocketDir) + "]")
					sameAdjValFound = true
					break
				# print("Adjacency Socket Val : " + str(tilesJsonData.tile_info[i].adjacency_list[j]))

			#This causes a bit more problem, as in, if there are more than 1 value in the adjacency list, then the values assigned by a 
			#previous match loop in the list, are removed by the very next match loop. And so everything turns to -1
			if (!sameAdjValFound):
				tileMap[tileToCheckIndex1D].tilesAvailable[i] = -1
				tileChanged = true
			"""
				print("Removing Tile | i[" + str(i) + "] | tileValueRemoved : "
						+ str(tileMap[tileToCheckIndex1D].tilesAvailable[i]));
			# """

		UpdateTileData_sig.emit(tileToCheckIndex1D)

	# UpdateTileData_sig.emit()
	# return 0
	return tileChanged
