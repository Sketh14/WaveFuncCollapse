extends Node

@export var tilePrefabsList : Array[Node2D]
@export var gridDimension : Vector2i
@export var tileHolder : Node

var tileMap : Array[SuperTileCell]

#This will hold the adjacent list of the neighbous tile whose adjacency is to be checked
var tempAdjList : Array[SuperTileCell]

#Instead of containing the whole Tile Data, as we only need the socket data, we need to only access the scoket data
var tilesCache : Array[Node]

class SuperTileCell:
	var tilesAvailable : Array[int]

# Called when the node enters the scene tree for the first time.
func _ready():
	LoadTilesData_2()
	InitializeTileMap()
	# CheckForNeighbours(0, 0, -1)

	#Testing purpose only
	GetNeighboursAdjaceny(0,0)
	PrintAdjListOfIndex(1)
	# GenerateTileMap()

func InitializeTileMap():
	for valX in gridDimension.x:
		var tileCell = SuperTileCell.new()
		tileMap.append(tileCell)
		#Really don't want to do this here
		for valY in gridDimension.y:
			tileCell.tilesAvailable.append(valY)
	
	#For all the 4 sockets
	for valX in 4:
		var tempTileCell = SuperTileCell.new()
		tempAdjList.append(tempTileCell)
	# TestingTiles()
	
#================================>	Testing  <================================
#This wont work now
func TestingTiles():
	var createdTile = CreateTile(0)
	tileMap[0].tilesAvailable.append(createdTile)
	var createdTile2 = CreateTile(1)
	tileMap[0].tilesAvailable.append(createdTile2)
	
	var coOrdX = 0
	var coOrdY = 1
	var debugPrint = "tilesAvailable size : " + str(tileMap[coOrdX].tilesAvailable.size())
	if (tileMap[coOrdX].tilesAvailable[coOrdY] != null):
		print(debugPrint)
		debugPrint = "Initial Test | TileMap[" + str(coOrdX) + "," + str(coOrdY) +"] : Not null"
		print(debugPrint)
		#Check wrap around condition
		debugPrint = "tilesAvailable[0] : " + str(tileMap[coOrdX].tilesAvailable[0]) + "tilesAvailable[1] : " + str(tileMap[coOrdX].tilesAvailable[1])  + "tilesAvailable[-1] : " + str(tileMap[coOrdX].tilesAvailable[-1])
		print(debugPrint)

# This is for testing purpose only.
func GenerateTileMap():
	# print("Generating Tiles");
	var tileCountX = -gridDimension.x/2
	for xVal in gridDimension.x:
		var tileCountY = -gridDimension.y/2
		# print("xVal : %d" %xVal)
		# print("Arr Count: %d" %tileMap.size())
		for yVal in gridDimension.y:
			var createdTile = CreateTile(0)
			tileMap[xVal].tilesAvailable.append(createdTile) 
			createdTile.position = Vector2(32.0 * tileCountX, 32.0 * tileCountY)			# Tiles size is 64 x 64
			tileCountY += 1
			if (tileCountY == 0):
				tileCountY *= -1
		tileCountX += 1
		if (tileCountX == 0):
			tileCountX *= -1
#================================>	Testing  <================================


#================================> Testing Area 1 <================================

#Not this function
func CheckForNeighbours_Og(coOrdX, coOrdY, socketVal):
	# var debugPrint = "Checing For Neighbours in tile["+ str(coOrdX) + "," + str(coOrdY) +"]"
	# print(debugPrint);

	if (tileMap.size() > coOrdX && tileMap[coOrdX] != null):
		# debugPrint = "tileMap[" + str(coOrdX) + "] : Not null"
		# print(debugPrint);

		if (tileMap[coOrdX].tilesAvailable.size() > coOrdY && tileMap[coOrdX].tilesAvailable[coOrdY] != null):
			# debugPrint = "tileMap[" + str(coOrdX) + "," + str(coOrdY) +"] : Not null"
			# print(debugPrint);

			if (socketVal == -1):
				CheckForNeighbours_Og(coOrdX-1, coOrdY, 0)
				CheckForNeighbours_Og(coOrdX+1, coOrdY, 0)
				CheckForNeighbours_Og(coOrdX, coOrdY-1, 0)
				CheckForNeighbours_Og(coOrdX, coOrdY+1, 0)
			else :
				# Array indexes in negative can wrap around, so beware!!
				if (coOrdX < 0 ||coOrdX >= gridDimension.x || coOrdY < 0 ||coOrdY >= gridDimension.y ):
					return			#Early return if out of range
				
				# var socVal = tileMap[coOrdX].tilesAvailable[coOrdY].socketContainer.posX
				# print("Got Socket : ", socVal)

#This might not be required
func GetNeighbours(coOrdX, coOrdY) -> Array[Node2D]:
	var arrToReturn

	# Array indexes in negative can wrap around, so beware!!
	if (coOrdX < 0 ||coOrdX >= gridDimension.x || coOrdY < 0 ||coOrdY >= gridDimension.y ):
		return arrToReturn		#Early return if out of range

	# var debugPrint = "Checing For Neighbours in tile["+ str(coOrdX) + "," + str(coOrdY) +"]"
	# print(debugPrint);

	if (tileMap.size() > coOrdX && tileMap[coOrdX] != null):
		# debugPrint = "tileMap[" + str(coOrdX) + "] : Not null"
		# print(debugPrint);

		if (tileMap[coOrdX].tilesAvailable.size() > coOrdY && tileMap[coOrdX].tilesAvailable[coOrdY] != null):
			# debugPrint = "tileMap[" + str(coOrdX) + "," + str(coOrdY) +"] : Not null"
			# print(debugPrint);
			pass

	return arrToReturn

#Print out the temp adjacency arrays
func PrintAdjListOfIndex(index):
	var debugPrint = ""
	var i = 0
	for listVal in tempAdjList[index].tilesAvailable:
		debugPrint = "Index [" + str(i) + "] : " + str(listVal)
		i += 1
		print(debugPrint)

#================================> Testing Area 1 <================================

func CreateTile(tileIndex) -> Node2D:
	# print("Generating Tile in YDir")
	# var tileToPlace = load(tilePrefabsList[0])
	var tileToPlace = tilePrefabsList[tileIndex].duplicate()
	tileToPlace.visible = true
	tileHolder.add_child(tileToPlace)
	return tileToPlace

# We would have to first cache all the data to a local variable in the script for easy access
#Below is wrong as there are no tiles added to tileMap at the beginning, need to get from TilesPrefab
# func LoadTilesData():
# 	var sizeX = tileMap.size()
# 	for xVal in sizeX:
# 		var sizeY = tileMap[sizeX].tilesAvailable.size()
# 		for yVal in sizeY:
# 			tilesCache.append(tileMap[xVal].tilesAvailable[yVal].socketContainer)

func LoadTilesData_2():
	var sizeX = tilePrefabsList.size()
	for xVal in sizeX:
		tilesCache.append(tilePrefabsList[xVal].socketContainer.socketOnly)

#This function will fill all the 4 sockets temproray adjacency list corresponding to the CoOrdinates sent to it
func GetNeighboursAdjaceny(coOrdX, coOrdY) -> int:
	# Array indexes in negative can wrap around, so beware!!
	if (coOrdX < 0 || coOrdX >= gridDimension.x || coOrdY < 0 || coOrdY >= gridDimension.y ):
		return 0		#Early return if out of range

	var debugPrint = "\n\nChecing For Neighbours in tile["+ str(coOrdX) + "," + str(coOrdY) +"]"
	print(debugPrint);

	#Check X
	# No tile will be null as it will contain all the possible states of the tile
	if (tileMap.size() > coOrdX):
		debugPrint = "tileMap[" + str(coOrdX) + "] : Not null"
		print(debugPrint);

		#Check Y
		if (tileMap[coOrdX].tilesAvailable.size() > coOrdY):
			debugPrint = "tileMap[" + str(coOrdX) + "," + str(coOrdY) +"] : Not null\n\n"
			print(debugPrint);
			
			#This is a valid tile at this point
			
			#As all the tiles are in super position state. We will need to get the whole tile list 
			#and compare each tile's, every socket with the current tile's adjacency list, to get the
			#suitable tile to connect with the current tile's socket
			
			#Get each adjacency list of the current tile and store in cache for faster access
			#Transpose 1D array to 2D using gridDimensions
			# RowNo. + (ColumnNo. * Columns)
			var indexToCheck = coOrdX + (coOrdY * gridDimension.y)
			var posXAdjList = tilePrefabsList[indexToCheck].socketContainer.adjPosX
			var negXAdjList = tilePrefabsList[indexToCheck].socketContainer.adjNegX
			var posYAdjList = tilePrefabsList[indexToCheck].socketContainer.adjPosY
			var negYAdjList = tilePrefabsList[indexToCheck].socketContainer.adjNegY

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
			#Compare socket PosX | "Pos X" can only be compared to "Neg X" without rotation
			var tileIndex = 0
			for valPosX in posXAdjList:			#This will give element, not index
				tileIndex = 0
				for tileVal in tilesCache:
					# debugPrint = "valPosX [" + str(valPosX) + "] | tileVal.PosX [" + str(tileVal.NegX) + "] | [" + str(tileIndex) + "]"
					# print(debugPrint);

					if (valPosX == tileVal.NegX):
						#Found Compatible Socket
						debugPrint = "Found Compatible NegX Socket at [" + str(tileIndex) + "] : [" + str(tileVal.NegX) + "]"
						print(debugPrint);
						tempAdjList[0].tilesAvailable.append(tileIndex)
						break;
					tileIndex += 1
			# debugPrint = "No Compatible Pos X socket Found!!\n\n"
			# print(debugPrint);

			#Compare socket NegX | "Neg X" can only be compared to "Pos X" without rotation
			for valNegX in negXAdjList:
				tileIndex = 0
				for tileVal in tilesCache:
					# debugPrint = "valNegX [" + str(valNegX) + "] | tileVal.PosX [" + str(tileVal.PosX) + "]"
					# print(debugPrint);

					if (valNegX == tileVal.PosX):
						#Found Compatible Socket
						debugPrint = "Found Compatible PosX Socket at [" + str(tileIndex) + "] : [" + str(tileVal.PosX) + "]"
						print(debugPrint)
						tempAdjList[1].tilesAvailable.append(tileIndex)
						break
					tileIndex += 1
			# debugPrint = "No Compatible Neg X socket Found!!\n\n"
			# print(debugPrint);
					
			#Compare socket PosY | "Pos Y" can only be compared to "Neg Y" without rotation
			for valPosY in posYAdjList:
				tileIndex = 0
				for tileVal in tilesCache:
					# debugPrint = "valPosY [" + str(valPosY) + "] | tileVal.NegY [" + str(tileVal.NegY) + "]"
					# print(debugPrint);

					if (valPosY == tileVal.NegY):
						#Found Compatible Socket
						# debugPrint = "Found Compatible NegY Socket at [" + str(tileIndex) + "] : [" + str(tileVal.NegY) + "]"
						# print(debugPrint);
						tempAdjList[2].tilesAvailable.append(tileIndex)
						break
					tileIndex += 1
			# debugPrint = "No Compatible Pos Y socket Found!!\n\n"
			# print(debugPrint);

			#Compare socket NegY | "Neg Y" can only be compared to "Pos Y" without rotation
			for valNegY in negYAdjList:
				tileIndex = 0
				for tileVal in tilesCache:
					# debugPrint = "valNegY [" + str(valNegY) + "] | tileVal.PosY [" + str(tileVal.PosY) + "]"
					# print(debugPrint);

					if (valNegY == tileVal.PosY):
						#Found Compatible Socket
						# debugPrint = "Found Compatible PosY Socket at [" + str(tileIndex) + "] : [" + str(tileVal.PosY) + "]"
						# print(debugPrint);
						tempAdjList[3].tilesAvailable.append(tileIndex)
						break
					tileIndex += 1
			# debugPrint = "No Compatible Neg Y socket Found!!\n\n"
			# print(debugPrint);

			return 1				#Successful searching for adjacency

	return -1				#UnSuccessful searching for adjacency | Some error occured
