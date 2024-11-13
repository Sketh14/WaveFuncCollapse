extends Node

class SuperTileCell:
	var collapsed: bool
	var currentTileIndex: int
	var tilesAvailable: Array[int]

class TransposedTileData:
	var tileCoOrdX: int
	var tileCoOrdY: int
	var socketDir: SocketDirection

enum SocketDirection {POSITIVEX, NEGATIVEX, POSITIVEY, NEGATIVEY}

@export var superTilePrefab: Node
@export var tilePrefabsList: Array[Node2D]
@export var tilePrefabsLocationList: Array[String]
@export var gridDimension: Vector2i
@export var tileHolder: Node

# @export var TestTile: Node

# We will access this map as a 1D array only with multiple rows and columns, each index depicting a tile 
# containing superposition tiles. 
# We will go Column first
var tileMap: Array[SuperTileCell]

#This will hold the adjacent list of the neighbous tile whose adjacency is to be checked
# var tempAdjList : Array[SuperTileCell]

#Instead of containing the whole Tile Data, as we only need the socket data, we need to only access the scoket data
var tilesCache: Array[Node]

#Stack that will contain all the tiles that ar to be checked in adjacency
var tilesToCheckStack: Array[TransposedTileData]

var debugPrint = "DEBUG PRINT"


# Called when the node enters the scene tree for the first time.
func _ready():
	FillTilesCache()
	InitializeData()
	# CheckForNeighbours(0, 0, -1)

	#Testing purpose only
	# tileMap[0].currentTileIndex = 0				#Fill [0,0] with 0
	# SetNeighboursAdjacenyForCoOrd(0, 0)
	# PrintAdjListOfIndex(1)
	# PrintListOfTileWithIndex(4)
	# GenerateTileMap()
	# CreateTestTile()

	#Testing 2
	# SetTile(0, 0, 13)
	PrintListOfTileWithCoOrd(0, 0)

"""
# Works as intended
func CreateTestTile():
	var tileToPlace = TestTile.duplicate()
	tileToPlace.visible = true
	tileHolder.add_child(tileToPlace)
	tileToPlace.position = Vector2(10, 10)
"""

## Fill up the tiles cache so that all the tiles data can be accessed fast
## As all the tiles are held in the tilesPrefabList. It would be better to only have the socketData in a cache to access fast. 
func FillTilesCache():
	var sizeX = tilePrefabsList.size()
	for xVal in sizeX:
		tilesCache.append(tilePrefabsList[xVal].socketContainer.socketOnly)

## Initialize tiles as well as fill the tilesAvailable list at the start so that the tiles are in a super-position state 
func InitializeData():
	var totalSize = gridDimension.x * gridDimension.y
	for valX in totalSize:
		var tileCell = SuperTileCell.new()
		tileMap.append(tileCell)
		#Really don't want to do this here
		for valY in tilePrefabsList.size():
			tileCell.tilesAvailable.append(valY)
	
	"""
	# Testing if the data is filled out properly
	for valY in tilePrefabsList.size():
		var tilesAvailable = tileMap[2].tilesAvailable[valY]
		print("tileMap[2] | tiles Available[", valY, "] : ", tilesAvailable)
	"""

# We are going Column First
func PrintListOfTileWithCoOrd(coOrdX: int, coOrdY: int):
	var index1D = coOrdX + (coOrdY * gridDimension.y)
	print("Checking Tiles | X: [" + str(coOrdX) + "] ,Y: [" + str(coOrdY) + "] Index : " + str(index1D))
	PrintListOfTileWithIndex(index1D)

## Prints the tilesAvailable list in a specific Tile 
func PrintListOfTileWithIndex(index: int):
	var i = 0
	for listVal in tileMap[index].tilesAvailable:
		print("Available Tile Index [" + str(index) + "] | i[" + str(i) + "] : " + str(listVal))

		# if (listVal > -1):
		# 	var socCont = tilePrefabsList[listVal].socketContainer
		# 	debugPrint = "Removed | Index [" + str(i) + "] | PosX : " + str(socCont.posX) + " | PosY : " + str(socCont.posY) + "| NegX : " + str(socCont.negX) + "| NegY : " + str(socCont.negY)
		# 	print(debugPrint)
		i += 1

## Function to actually instantiate tile.
## This will not set the image of the tile.
func CreateTile(tileIndexX: int) -> Node2D:
	print("Generating Tile | Prefab Child Index : ", tileIndexX)
	var tileToPlace = load(tilePrefabsLocationList[0])
	# var fhgh = load("res://Prefab/Tile/Big_Rock/TilePrefab_12.tscn")

	# This does not duplicate the Node properly if children are present
	# Also, we are duplicating scene, not existing Node
	# var tileToPlace = tilePrefabsList[tileIndexX].duplicate()


	tileToPlace.visible = true
	tileHolder.add_child(tileToPlace)
	return tileToPlace

"""
func CreateSuperTile(tileCoOrdX, tileCoOrdY):
	var superTile: Node
	superTile = superTilePrefab.duplicate()
	superTile.visible = true
	superTile.transform.position = Vector2(32.0 * (tileCoOrdX + tileIndexX), 32.0 * (coOrdY + tileIndexY))
"""


## Set a specific tile value and also check for the neighbouring tiles data
func SetTile(coOrdX: int, coOrdY: int, valToSet: int):
	var index1D = coOrdX + (coOrdY * gridDimension.y)
	if (tileMap.size() <= index1D || index1D < 0):
		return

	tileMap[index1D].currentTileIndex = valToSet
	tileMap[index1D].collapsed = true

	# Create SuperTiles in each possible direction
	"""
	var superTile
	var tilePosXMult = 0
	var tilePosYMult = 1
	for tileCountX in 2:
		for tileCountY in 2:
			superTile = superTilePrefab.duplicate()
			superTile.visible = true
			var position = Vector2(32.0 * (coOrdX + (1 * tilePosXMult)), 32.0 * (coOrdY + (1 * tilePosYMult)))
			superTile.position = position
			# print("Instantiating at Position : ", position)
			# tileHolder.add_child(superTile)
			tilePosYMult = tilePosYMult * -1
			tilePosXMult = tilePosXMult * -1
		tilePosYMult = 0
		tilePosXMult = 1
	"""

	var createdTile = CreateTile(valToSet)
	createdTile.position = Vector2(32.0 * coOrdX, 32.0 * coOrdY) # Tiles size is 64 x 64
	
	#Set the first 4 adjacent tiles in the immediate vicinity of the current set tile
	SetTilesToCheckData(coOrdX, coOrdY)

	# Set while loop here and keep repeating unless all the adjoining cells are collapsed
	# while (tilesToCheckStack.size() > 0):
	if (true):
		var tileToCheck = tilesToCheckStack.pop_back()
		# debugPrint = "Got Tile to check| index : X[" + str(tileToCheck.tileCoOrdX) + "], Y[" + str(tileToCheck.tileCoOrdY) + "]"
		# print(debugPrint)
		SetTileAdjacency(index1D, tileToCheck)
		
		#index1D error | not being set for the neighbours when it is neighbours turn
		# var tempTransposedIndex = tileToCheck.tileCoOrdX + (tileToCheck.tileCoOrdY * gridDimension.y)
		# if(!tileMap[tempTransposedIndex].collapsed):
		# 	SetTilesToCheckData(tileToCheck.tileCoOrdX, tileToCheck.tileCoOrdY)

## Helper function to set the Stack which checks the neighbouring tiles of the current selected tile.
## It adds the right/left/bottom/top tiles to the Stack
func SetTilesToCheckData(coOrdX: int, coOrdY: int):
	# debugPrint = "Setting Tile Data|  X[" + str(coOrdX) + "], Y[" + str(coOrdY) + "]"
	# print(debugPrint)
	
	var tempTileData = TransposedTileData.new()

	tempTileData = TransposedTileData.new()
	tempTileData.tileCoOrdX = coOrdX - 1
	tempTileData.tileCoOrdY = coOrdY
	tempTileData.socketDir = SocketDirection.NEGATIVEX
	tilesToCheckStack.push_back(tempTileData)

	tempTileData.tileCoOrdX = coOrdX + 1
	tempTileData.tileCoOrdY = coOrdY
	tempTileData.socketDir = SocketDirection.POSITIVEX
	tilesToCheckStack.push_back(tempTileData)

	tempTileData = TransposedTileData.new()
	tempTileData.tileCoOrdX = coOrdX
	tempTileData.tileCoOrdY = coOrdY - 1
	tempTileData.socketDir = SocketDirection.NEGATIVEY
	tilesToCheckStack.push_back(tempTileData)

	tempTileData = TransposedTileData.new()
	tempTileData.tileCoOrdX = coOrdX
	tempTileData.tileCoOrdY = coOrdY + 1
	tempTileData.socketDir = SocketDirection.POSITIVEY
	tilesToCheckStack.push_back(tempTileData)
	
func SetTileAdjacency(currTileIndex: int, tileToCheck: TransposedTileData) -> int:

	#Compare Socket | "Positive Socket" can only be compared to "Negative Socket" without rotation
	#Search down of the tile
	if (tileMap.size() > currTileIndex && currTileIndex >= 0):
		# debugPrint = "Checking | Index [" + str(currTileIndex) + "] | SocketDir [" + str(tileToCheck.socketDir) + "]\n\n"
		# print(debugPrint);

		var tileAvailableIndex = 0
		var foundTile = false
		
		var tilePrefabIndex = tileMap[currTileIndex].currentTileIndex # We assume that the index will be set, as without index, this shouldnt be triggered
		var adjList # Cache List to compare with
		match tileToCheck.socketDir:
			SocketDirection.POSITIVEX:
				adjList = tilePrefabsList[tilePrefabIndex].socketContainer.adjPosX
			SocketDirection.NEGATIVEX:
				adjList = tilePrefabsList[tilePrefabIndex].socketContainer.adjNegX
			SocketDirection.POSITIVEY:
				adjList = tilePrefabsList[tilePrefabIndex].socketContainer.adjPosY
			SocketDirection.NEGATIVEY:
				adjList = tilePrefabsList[tilePrefabIndex].socketContainer.adjNegY

		# tilesAvailable should be sorted (in ascending order)
		# Should be a better way than this to do the below | Can run a binary search to find the index faster
		var index1D = tileToCheck.tileCoOrdX + (tileToCheck.tileCoOrdY * gridDimension.y)
		var totalCount = tileMap[index1D].tilesAvailable.size()
		for tileVal in tileMap[index1D].tilesAvailable:
			if (tileVal < 0): # Tile previously has been set to 0
				totalCount -= 1

				# debugPrint = "tileVal is 0 | Reducing Total Count | totalCount[" + str(totalCount) + "]\n\n"
				# print(debugPrint);
				continue

			var tempCompSocketVal # cache value to compare with
			match tileToCheck.socketDir:
				SocketDirection.POSITIVEX:
					tempCompSocketVal = tilesCache[tileVal].NegX
				SocketDirection.NEGATIVEX:
					tempCompSocketVal = tilesCache[tileVal].PosX
				SocketDirection.POSITIVEY:
					tempCompSocketVal = tilesCache[tileVal].NegY
				SocketDirection.NEGATIVEY:
					tempCompSocketVal = tilesCache[tileVal].PosY
			foundTile = false

			# debugPrint = "=====================> Checking | tileVal : " + str(tileVal) + "  | socketVal : " + str(tempCompSocketVal) + " <=====================\n\n"
			# print(debugPrint);
			
			# var listIndex = 0				#THis is for debugging only
			for socketVal in adjList:
				if (socketVal == tempCompSocketVal):
					#Found Compatible Socket
					# debugPrint = "Found Socket | Socket [" + str(tileAvailableIndex) + "] : [" + str(tempCompSocketVal) + "]"
					# print(debugPrint);
					foundTile = true;
					
					#Cell fully collapsed
					if (totalCount == 1):
						tileMap[index1D].collapsed = true
						return 1
					break

				# debugPrint = "listIndex [" + str(listIndex) +"] | socketVal [" + str(tileAvailableIndex) + "] : " + str(socketVal) 
				# print(debugPrint);
				# listIndex += 1
				
			#This causes a bit more problem, as in, if there are more than 1 value in the adjacency list, then the values assigned by a 
			#previous match loop in the list, are removed by the very next match loop. And so everything turns to -1
			if (!foundTile):
				totalCount -= 1
				tileMap[index1D].tilesAvailable[tileAvailableIndex] = -1
				# debugPrint = "Removing Tile | Socket [" + str(tileIndexX) + "] : [" + str(tileVal) + "] | tileValueRemoved : " + str(tileMap[index1D].tilesAvailable[tileIndexX])
				# print(debugPrint);
			tileAvailableIndex += 1
		return 0
	else:
		debugPrint = "Invalid tileIndexX to search!!\n\n"
		print(debugPrint)
		return -1
		
#======================> 1st Iteration <===========================
##TODO: Make this functionality
# func SetNeighboursAdjacenyForCoOrd(index1D) -> int:

#TODO: refactor into smaller functions
# func SetNeighboursAdjacenyForCoOrd(transposedIndex) -> int:
## This will not work | This function will fill all the 4 sockets temproray adjacency list corresponding to the CoOrdinates sent to it
func SetNeighboursAdjacenyForCoOrd(coOrdX: int, coOrdY: int) -> int:
	# Array indexes in negative can wrap around, so beware!!
	if (coOrdX < 0 || coOrdX >= gridDimension.x || coOrdY < 0 || coOrdY >= gridDimension.y):
	# if (tileMap.size() <= index1D || index1D < 0):
		return 0 # Early return if out of range

	debugPrint = "\n\nChecing For Neighbours in tile[" + str(coOrdX) + "," + str(coOrdY) + "]"
	print(debugPrint);
	# var debugPrint = "\n\nChecing For Neighbours in tile["+ str(index1D) +"]"
			
	#This is a valid tile at this point
			
	#As all the tiles are in super position state. We will need to get the whole tile list 
	#and compare each tile's, every socket with the current tile's adjacency list, to get the
	#suitable tile to connect with the current tile's socket
			
	#Get each adjacency list of the current tile and store in cache for faster access
	#Transpose 1D array to 2D using gridDimensions
	# RowNo. + (ColumnNo. * Columns)
	var index1D = coOrdX + (coOrdY * gridDimension.y) # This is for directly accessing the tile from tilePrefabs
	var tileIndexToCheck = tileMap[index1D].currentTileIndex # We assume that the index will be set, as without index, this shouldnt be triggered
	var posXAdjList = tilePrefabsList[tileIndexToCheck].socketContainer.adjPosX
	var negXAdjList = tilePrefabsList[tileIndexToCheck].socketContainer.adjNegX
	var posYAdjList = tilePrefabsList[tileIndexToCheck].socketContainer.adjPosY
	var negYAdjList = tilePrefabsList[tileIndexToCheck].socketContainer.adjNegY

	# debugPrint = "Checking Adjacency Lsit | First Pos X Element [ " + str(compAdjPosX[0]) + " ] "
	# print(debugPrint);			

	#Compare each socket with adjacency list of the current tile
	#PosY -> NegY | NegY -> PosY | PosX -> NegX | NegX -> PosX

	#==========================================> Suggestion <==========================================
	#Run a sorting algorithm to sort the adjacency list in ascending/descending order
	#After the list is sorted, we can run binary search to check if the given socket value
	#is greater, less or equal to the socket got from the tilesCache
	#==========================================> Suggestion <==========================================

	#For now, we are just iterating through the whole adjacency array and comparing with the
	#tilesCache array

	#Check each tiles list for compatible neighbours with the collapsed cell
	var tileIndexX = 0
	var foundTile = false

	#Compare socket PosX | "Pos X" can only be compared to "Neg X" without rotation
	#Search Right side of the tile
	index1D = (coOrdX + 1) + (coOrdY * gridDimension.y)
	if (tileMap.size() > index1D && index1D >= 0):
		# debugPrint = "Checking | Pos X | " + str(index1D) + "\n\n"
		# print(debugPrint);

		tileIndexX = 0
		for tileVal in tileMap[index1D].tilesAvailable:
			var tempNegX = tilesCache[tileVal].NegX
			foundTile = false
			for valPosX in posXAdjList: # This will give element, not index
				# debugPrint = "valPosX [" + str(valPosX) + "] | tileVal.PosX [" + str(tileVal.NegX) + "] | [" + str(tileIndexX) + "]"
				# print(debugPrint);

				if (valPosX == tempNegX):
					#Found Compatible Socket
					# debugPrint = "Found NegX | Socket at [" + str(tileIndexX) + "] : [" + str(tileVal) + "] | tileNegX [" + str(tilesCache[tileVal].NegX) + "]"
					# print(debugPrint)
					foundTile = true

					#Check if only 1 tile is left, if so, then the cell has collapsed | The cell only has 1 >= 0 holding element
					break

			if (!foundTile):
				# debugPrint = "NegX Removing Tile | Socket at [" + str(tileIndexX) + "] : [" + str(tileVal) + "] | tileNegX [" + str(tileMap[index1D].tilesAvailable[tileIndexX]) + "]"
				# print(debugPrint);
				tileMap[index1D].tilesAvailable[tileIndexX] = -1 # Dont do remove_at as it will mess up the indexing
			tileIndexX += 1
	else:
		debugPrint = "No Compatible Pos X socket Found!!\n\n"
		print(debugPrint);

	#Compare socket NegX | "Neg X" can only be compared to "Pos X" without rotation
	#Search left side of the tile
	index1D = (coOrdX - 1) + (coOrdY * gridDimension.y)
	if (tileMap.size() > index1D && index1D >= 0):
		# debugPrint = "Checking | Neg X | " + str(index1D) + "\n\n"
		# print(debugPrint);

		tileIndexX = 0
		for tileVal in tileMap[index1D].tilesAvailable:
			var tempNegX = tilesCache[tileVal].NegX
			foundTile = false
			for valNegX in negXAdjList:
				# debugPrint = "valNegX [" + str(valNegX) + "] | tileVal.PosX [" + str(tileVal.PosX) + "] | [" + str(tileIndexX) + "]"
				# print(debugPrint);

				if (valNegX == tempNegX):
					#Found Compatible Socket
					# debugPrint = "Found PosX | Socket at [" + str(tileIndexX) + "] : [" + str(tileVal) + "] | tileNegX [" + str(tilesCache[tileVal].PosX) + "]"
					# print(debugPrint)
					foundTile = true
					break

			if (!foundTile):
				# debugPrint = "PosX Removing Tile | Socket at [" + str(tileIndexX) + "] : [" + str(tileVal) + "] | tilePosX [" + str(tileMap[index1D].tilesAvailable[tileIndexX]) + "]"
				# print(debugPrint);
				tileMap[index1D].tilesAvailable[tileIndexX] = -1
			tileIndexX += 1
	else:
		debugPrint = "No Compatible Neg X socket Found!!\n\n"
		print(debugPrint);
					
	#Compare socket PosY | "Pos Y" can only be compared to "Neg Y" without rotation
	#Search down of the tile
	index1D = coOrdX + ((coOrdY + 1) * gridDimension.y)
	if (tileMap.size() > index1D && index1D >= 0):
		# debugPrint = "Checking | Pos Y | " + str(index1D) + "\n\n"
		print(debugPrint);

		tileIndexX = 0
		for tileVal in tileMap[index1D].tilesAvailable:
			var tempCompSocketVal = tilesCache[tileVal].NegY
			foundTile = false

			# debugPrint = "=====================> Checking | tileVal : " + str(tileVal) + "  | tileNegY : " + str(tilesCache[tileVal].NegY) + " <=====================\n\n"
			# print(debugPrint);
			
			# var listIndex = 0				#THis is for debugging only
			for socketVal in posYAdjList:
				if (socketVal == tempCompSocketVal):
					#Found Compatible Socket
					# debugPrint = "Found NegY | Socket [" + str(tileIndexX) + "] : [" + str(tileVal) + "]"
					# print(debugPrint);
					foundTile = true;
					break

				# debugPrint = "socketVal [" + str(listIndex) + "] : " + str(socketVal) 
				# print(debugPrint);
				# listIndex += 1
				
			#This causes a bit more problem, as in, if there are more than 1 value in the adjacency list, then the values assigned by a 
			#previous match loop in the list, are removed by the very next match loop. And so everything turns to -1
			if (!foundTile):
				tileMap[index1D].tilesAvailable[tileIndexX] = -1
				# debugPrint = "PosY Removing Tile | Socket [" + str(tileIndexX) + "] : [" + str(tileVal) + "] | tileValueRemoved : " + str(tileMap[index1D].tilesAvailable[tileIndexX])
				# print(debugPrint);
			tileIndexX += 1
	else:
		debugPrint = "No Compatible Pos Y socket Found!!\n\n"
		print(debugPrint);

	#Compare socket NegY | "Neg Y" can only be compared to "Pos Y" without rotation
	#Search up of the tile
	index1D = coOrdX + ((coOrdY - 1) * gridDimension.y)
	if (tileMap.size() > index1D && index1D >= 0):
		# debugPrint = "Checking | Neg Y | " + str(index1D) + "\n\n"
		# print(debugPrint);

		tileIndexX = 0
		for tileVal in tileMap[index1D].tilesAvailable:
			var tempPosY = tilesCache[tileVal].PosY
			foundTile = false
			for valNegY in negYAdjList:
				# debugPrint = "valNegY [" + str(valNegY) + "] | tileVal.PosY [" + str(tileVal.PosY) + "] | [" + str(tileIndexX) + "]"
				# print(debugPrint);

				if (valNegY == tempPosY):
					#Found Compatible Socket
					# debugPrint = "Found PosY | Socket at [" + str(tileIndexX) + "] : [" + str(tileVal) + "] | tilePosY [" + str(tilesCache[tileVal].PosY) + "]"
					# print(debugPrint);
					foundTile = true;
					break

			if (!foundTile):
				# debugPrint = "PosX Removing Tile | Socket at [" + str(tileIndexX) + "] : [" + str(tileVal) + "] | tilePosX [" + str(tileMap[index1D].tilesAvailable[tileIndexX]) + "]"
				# print(debugPrint);
				tileMap[index1D].tilesAvailable[tileIndexX] = -1
			tileIndexX += 1
	else:
		debugPrint = "No Compatible Neg Y socket Found!!\n\n"
		print(debugPrint);

		return 1 # Successful searching for adjacency

	return -1 # UnSuccessful searching for adjacency | Some error occured
