extends Node

enum SocketDirection {POSITIVEX, NEGATIVEX, POSITIVEY, NEGATIVEY}

@export var tilePrefabsList : Array[Node2D]
@export var gridDimension : Vector2i
@export var tileHolder : Node

#We will access this map as a 1D array only with multiple rows and columns, each index depicting a tile containing superposition tiles
var tileMap : Array[SuperTileCell]

#This will hold the adjacent list of the neighbous tile whose adjacency is to be checked
# var tempAdjList : Array[SuperTileCell]

#Instead of containing the whole Tile Data, as we only need the socket data, we need to only access the scoket data
var tilesCache : Array[Node]

#Stack that will contain all the tiles that ar to be checked in adjacency
var transposedIndexStack : Array[TransposedIndexData]

class SuperTileCell:
	var collapsed : bool
	var currentTileIndex : int
	var tilesAvailable : Array[int]

class TransposedIndexData:
	var tileCoOrdX : int
	var tileCoOrdY : int
	var socketDir : SocketDirection

# Called when the node enters the scene tree for the first time.
func _ready():
	FillTilesCache()
	InitializeData()
	# CheckForNeighbours(0, 0, -1)

	#Testing purpose only
	tileMap[0].currentTileIndex = 0				#Fill [0,0] with 0
	SetNeighboursAdjacenyForCoOrd(0, 0)
	# PrintAdjListOfIndex(1)
	# PrintListOfTileWithIndex(4)
	# GenerateTileMap()

func InitializeData():
	var totalSize = gridDimension.x * gridDimension.y
	for valX in totalSize:
		var tileCell = SuperTileCell.new()
		tileMap.append(tileCell)
		#Really don't want to do this here
		for valY in tilePrefabsList.size():
			tileCell.tilesAvailable.append(valY)

#Test Function
func PrintListOfTileWithIndex(index):
	var debugPrint = ""
	var i = 0
	for listVal in tileMap[index].tilesAvailable:
		debugPrint = "Index [" + str(index) + "] | i[" + str(i) + "] : " + str(listVal)
		print(debugPrint)

		# if (listVal > -1):
		# 	var socCont = tilePrefabsList[listVal].socketContainer
		# 	debugPrint = "Removed | Index [" + str(i) + "] | PosX : " + str(socCont.posX) + " | PosY : " + str(socCont.posY) + "| NegX : " + str(socCont.negX) + "| NegY : " + str(socCont.negY)
		# 	print(debugPrint)
		i += 1

func CreateTile(tileIndex) -> Node2D:
	# print("Generating Tile in YDir")
	# var tileToPlace = load(tilePrefabsList[0])
	var tileToPlace = tilePrefabsList[tileIndex].duplicate()
	tileToPlace.visible = true
	tileHolder.add_child(tileToPlace)
	return tileToPlace

func FillTilesCache():
	var sizeX = tilePrefabsList.size()
	for xVal in sizeX:
		tilesCache.append(tilePrefabsList[xVal].socketContainer.socketOnly)

func SetTile(coOrdX, coOrdY, valToSet):
	var transposedIndex = coOrdX + (coOrdY * gridDimension.y)
	if (tileMap.size() <= transposedIndex || transposedIndex < 0):
		return

	tileMap[transposedIndex].currentTileIndex = valToSet
	tileMap[transposedIndex].collapsed = true
	
	# var tempIndexData = TransposedIndexData.new()
	# tempIndexData.tileCoOrdX = coOrdX + 1
	# tempIndexData.tileCoOrdY = coOrdY
	# tempIndexData.socketDir = SocketDirection.POSITIVEX
	# transposedIndexStack.push_back(tempIndexData)

	# tempIndexData.tileCoOrdX = coOrdX - 1
	# tempIndexData.tileCoOrdY = coOrdY
	# tempIndexData.socketDir = SocketDirection.NEGATIVEX
	# transposedIndexStack.push_back(tempIndexData)

	# tempIndexData.tileCoOrdX = coOrdX
	# tempIndexData.tileCoOrdY = coOrdY + 1
	# tempIndexData.socketDir = SocketDirection.POSITIVEY
	# transposedIndexStack.push_back(tempIndexData)

	# tempIndexData.tileCoOrdX = coOrdX
	# tempIndexData.tileCoOrdY = coOrdY - 1
	# tempIndexData.socketDir = SocketDirection.NEGATIVEY
	# transposedIndexStack.push_back(tempIndexData)

	SetTransposedStackData(coOrdX, coOrdY)

	# Set while loop here and keep repeating unless all the adjoining cells are collapsed
	while (transposedIndexStack.size() > 0):
		var tileToCheck = transposedIndexStack.pop_back()
		SetTileAdjacency(transposedIndex, tileToCheck)

		var tempTransposedIndex = tileToCheck.coOrdX + (tileToCheck.coOrdY * gridDimension.y)
		if(!tileMap[tempTransposedIndex].collapsed):
			SetTransposedStackData(tileToCheck.tileCoOrdX, tileToCheck.tileCoOrdY)

func SetTransposedStackData(coOrdX, coOrdY):
	var tempIndexData = TransposedIndexData.new()
	tempIndexData.tileCoOrdX = coOrdX + 1
	tempIndexData.tileCoOrdY = coOrdY
	tempIndexData.socketDir = SocketDirection.POSITIVEX
	transposedIndexStack.push_back(tempIndexData)

	tempIndexData.tileCoOrdX = coOrdX - 1
	tempIndexData.tileCoOrdY = coOrdY
	tempIndexData.socketDir = SocketDirection.NEGATIVEX
	transposedIndexStack.push_back(tempIndexData)

	tempIndexData.tileCoOrdX = coOrdX
	tempIndexData.tileCoOrdY = coOrdY + 1
	tempIndexData.socketDir = SocketDirection.POSITIVEY
	transposedIndexStack.push_back(tempIndexData)

	tempIndexData.tileCoOrdX = coOrdX
	tempIndexData.tileCoOrdY = coOrdY - 1
	tempIndexData.socketDir = SocketDirection.NEGATIVEY
	transposedIndexStack.push_back(tempIndexData)
	

#TODO: Make this functionality
# func SetNeighboursAdjacenyForCoOrd(transposedIndex) -> int:

#This will not work
#This function will fill all the 4 sockets temproray adjacency list corresponding to the CoOrdinates sent to it
#TODO: refactor into smaller functions
func SetNeighboursAdjacenyForCoOrd(coOrdX, coOrdY) -> int:
# func SetNeighboursAdjacenyForCoOrd(transposedIndex) -> int:
	# Array indexes in negative can wrap around, so beware!!
	if (coOrdX < 0 || coOrdX >= gridDimension.x || coOrdY < 0 || coOrdY >= gridDimension.y ):
	# if (tileMap.size() <= transposedIndex || transposedIndex < 0):
		return 0		#Early return if out of range

	var debugPrint = "\n\nChecing For Neighbours in tile["+ str(coOrdX) + "," + str(coOrdY) +"]"
	# var debugPrint = "\n\nChecing For Neighbours in tile["+ str(transposedIndex) +"]"
	print(debugPrint);
			
	#This is a valid tile at this point
			
	#As all the tiles are in super position state. We will need to get the whole tile list 
	#and compare each tile's, every socket with the current tile's adjacency list, to get the
	#suitable tile to connect with the current tile's socket
			
	#Get each adjacency list of the current tile and store in cache for faster access
	#Transpose 1D array to 2D using gridDimensions
	# RowNo. + (ColumnNo. * Columns)
	var transposedIndex = coOrdX + (coOrdY * gridDimension.y)			# This is for directly accessing the tile from tilePrefabs
	var tileIndexToCheck = tileMap[transposedIndex].currentTileIndex		# We assume that the index will be set, as without index, this shouldnt be triggered
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
	var tileIndex = 0
	var foundTile = false

	#Compare socket PosX | "Pos X" can only be compared to "Neg X" without rotation
	#Search Right side of the tile
	transposedIndex = (coOrdX + 1) + (coOrdY * gridDimension.y)
	if (tileMap.size() > transposedIndex && transposedIndex >= 0):	
		# debugPrint = "Checking | Pos X | " + str(transposedIndex) + "\n\n"
		# print(debugPrint);

		tileIndex = 0
		for tileVal in tileMap[transposedIndex].tilesAvailable:
			var tempNegX = tilesCache[tileVal].NegX
			foundTile = false
			for valPosX in posXAdjList:			#This will give element, not index
				# debugPrint = "valPosX [" + str(valPosX) + "] | tileVal.PosX [" + str(tileVal.NegX) + "] | [" + str(tileIndex) + "]"
				# print(debugPrint);

				if (valPosX == tempNegX):
					#Found Compatible Socket
					# debugPrint = "Found NegX | Socket at [" + str(tileIndex) + "] : [" + str(tileVal) + "] | tileNegX [" + str(tilesCache[tileVal].NegX) + "]"
					# print(debugPrint)
					foundTile = true

					#Check if only 1 tile is left, if so, then the cell has collapsed | The cell only has 1 >= 0 holding element
					break

			if (!foundTile):
				# debugPrint = "NegX Removing Tile | Socket at [" + str(tileIndex) + "] : [" + str(tileVal) + "] | tileNegX [" + str(tileMap[transposedIndex].tilesAvailable[tileIndex]) + "]"
				# print(debugPrint);
				tileMap[transposedIndex].tilesAvailable[tileIndex] = -1		#Dont do remove_at as it will mess up the indexing
			tileIndex += 1
	else:
		debugPrint = "No Compatible Pos X socket Found!!\n\n"
		print(debugPrint);

	#Compare socket NegX | "Neg X" can only be compared to "Pos X" without rotation
	#Search left side of the tile
	transposedIndex = (coOrdX - 1) + (coOrdY * gridDimension.y)
	if (tileMap.size() > transposedIndex && transposedIndex >= 0):
		# debugPrint = "Checking | Neg X | " + str(transposedIndex) + "\n\n"
		# print(debugPrint);

		tileIndex = 0
		for tileVal in tileMap[transposedIndex].tilesAvailable:
			var tempNegX = tilesCache[tileVal].NegX
			foundTile = false
			for valNegX in negXAdjList:
				# debugPrint = "valNegX [" + str(valNegX) + "] | tileVal.PosX [" + str(tileVal.PosX) + "] | [" + str(tileIndex) + "]"
				# print(debugPrint);

				if (valNegX == tempNegX):
					#Found Compatible Socket
					# debugPrint = "Found PosX | Socket at [" + str(tileIndex) + "] : [" + str(tileVal) + "] | tileNegX [" + str(tilesCache[tileVal].PosX) + "]"
					# print(debugPrint)
					foundTile = true
					break

			if (!foundTile):
				# debugPrint = "PosX Removing Tile | Socket at [" + str(tileIndex) + "] : [" + str(tileVal) + "] | tilePosX [" + str(tileMap[transposedIndex].tilesAvailable[tileIndex]) + "]"
				# print(debugPrint);
				tileMap[transposedIndex].tilesAvailable[tileIndex] = -1
			tileIndex += 1
	else:
		debugPrint = "No Compatible Neg X socket Found!!\n\n"
		print(debugPrint);
					
	#Compare socket PosY | "Pos Y" can only be compared to "Neg Y" without rotation
	#Search down of the tile
	transposedIndex = coOrdX + ((coOrdY + 1) * gridDimension.y)
	if (tileMap.size() > transposedIndex && transposedIndex >= 0):	
		# debugPrint = "Checking | Pos Y | " + str(transposedIndex) + "\n\n"
		print(debugPrint);

		tileIndex = 0
		for tileVal in tileMap[transposedIndex].tilesAvailable:
			var tempCompSocketVal = tilesCache[tileVal].NegY
			foundTile = false

			# debugPrint = "=====================> Checking | tileVal : " + str(tileVal) + "  | tileNegY : " + str(tilesCache[tileVal].NegY) + " <=====================\n\n"
			# print(debugPrint);
			
			# var listIndex = 0				#THis is for debugging only
			for socketVal in posYAdjList:				
				if (socketVal == tempCompSocketVal):
					#Found Compatible Socket
					# debugPrint = "Found NegY | Socket [" + str(tileIndex) + "] : [" + str(tileVal) + "]"
					# print(debugPrint);
					foundTile = true;
					break

				# debugPrint = "socketVal [" + str(listIndex) + "] : " + str(socketVal) 
				# print(debugPrint);
				# listIndex += 1
				
			#This causes a bit more problem, as in, if there are more than 1 value in the adjacency list, then the values assigned by a 
			#previous match loop in the list, are removed by the very next match loop. And so everything turns to -1
			if (!foundTile):
				tileMap[transposedIndex].tilesAvailable[tileIndex] = -1
				# debugPrint = "PosY Removing Tile | Socket [" + str(tileIndex) + "] : [" + str(tileVal) + "] | tileValueRemoved : " + str(tileMap[transposedIndex].tilesAvailable[tileIndex])
				# print(debugPrint);
			tileIndex += 1
	else:
		debugPrint = "No Compatible Pos Y socket Found!!\n\n"
		print(debugPrint);

	#Compare socket NegY | "Neg Y" can only be compared to "Pos Y" without rotation
	#Search up of the tile
	transposedIndex = coOrdX + ((coOrdY - 1) * gridDimension.y)
	if (tileMap.size() > transposedIndex && transposedIndex >= 0):	
		# debugPrint = "Checking | Neg Y | " + str(transposedIndex) + "\n\n"
		# print(debugPrint);

		tileIndex = 0
		for tileVal in tileMap[transposedIndex].tilesAvailable:
			var tempPosY = tilesCache[tileVal].PosY
			foundTile = false
			for valNegY in negYAdjList:
				# debugPrint = "valNegY [" + str(valNegY) + "] | tileVal.PosY [" + str(tileVal.PosY) + "] | [" + str(tileIndex) + "]"
				# print(debugPrint);

				if (valNegY == tempPosY):
					#Found Compatible Socket
					# debugPrint = "Found PosY | Socket at [" + str(tileIndex) + "] : [" + str(tileVal) + "] | tilePosY [" + str(tilesCache[tileVal].PosY) + "]"
					# print(debugPrint);
					foundTile = true;
					break

			if (!foundTile):
				# debugPrint = "PosX Removing Tile | Socket at [" + str(tileIndex) + "] : [" + str(tileVal) + "] | tilePosX [" + str(tileMap[transposedIndex].tilesAvailable[tileIndex]) + "]"
				# print(debugPrint);
				tileMap[transposedIndex].tilesAvailable[tileIndex] = -1
			tileIndex += 1
	else:
		debugPrint = "No Compatible Neg Y socket Found!!\n\n"
		print(debugPrint);

		return 1				#Successful searching for adjacency

	return -1				#UnSuccessful searching for adjacency | Some error occured

func SetTileAdjacency(currTileIndex, tileToCheck) -> int:
	var debugPrint = ""

	#Compare Socket | "Positive Socket" can only be compared to "Negative Socket" without rotation
	#Search down of the tile
	if (tileMap.size() > tileToCheck.transposedIndex && tileToCheck.transposedIndex >= 0):	
		# debugPrint = "Checking | Index | " + str(transposedIndex) + "\n\n"
		# print(debugPrint);

		var tileIndex = 0
		var foundTile = false
		
		var tilePrefabIndex = tileMap[currTileIndex].currentTileIndex		# We assume that the index will be set, as without index, this shouldnt be triggered
		var adjList				#Cache List to compare with
		match tileToCheck.socketDir:
			SocketDirection.POSITIVEX:
				adjList = tilePrefabsList[tilePrefabIndex].socketContainer.adjPosX
			SocketDirection.NEGATIVEX:
				adjList = tilePrefabsList[tilePrefabIndex].socketContainer.adjNegX
			SocketDirection.POSITIVEY:
				adjList = tilePrefabsList[tilePrefabIndex].socketContainer.adjPosY
			SocketDirection.NEGATIVEY:
				adjList = tilePrefabsList[tilePrefabIndex].socketContainer.adjNegY

		var totalCount = tileMap[tileToCheck.transposedIndex].tilesAvailable
		for tileVal in tileMap[tileToCheck.transposedIndex].tilesAvailable:
			if (tileVal < 0):			#Tile previously has been set to 0
				totalCount -= 1
				continue

			var tempCompSocketVal			#cache value to compare with
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
					# debugPrint = "Found Socket | Socket [" + str(tileIndex) + "] : [" + str(tileVal) + "]"
					# print(debugPrint);
					foundTile = true;
					
					#Cell fully collapsed
					if (totalCount == 1):
						tileMap[tileToCheck.transposedIndex].collapsed = true
						return 1
					break

				# debugPrint = "socketVal [" + str(listIndex) + "] : " + str(socketVal) 
				# print(debugPrint);
				# listIndex += 1
				
			#This causes a bit more problem, as in, if there are more than 1 value in the adjacency list, then the values assigned by a 
			#previous match loop in the list, are removed by the very next match loop. And so everything turns to -1
			if (!foundTile):
				totalCount -= 1
				tileMap[tileToCheck.transposedIndex].tilesAvailable[tileIndex] = -1
				# debugPrint = "Removing Tile | Socket [" + str(tileIndex) + "] : [" + str(tileVal) + "] | tileValueRemoved : " + str(tileMap[transposedIndex].tilesAvailable[tileIndex])
				# print(debugPrint);
			tileIndex += 1
		return 0;
	else:
		debugPrint = "Invalid tileIndex to search!!\n\n"
		print(debugPrint);
		return -1