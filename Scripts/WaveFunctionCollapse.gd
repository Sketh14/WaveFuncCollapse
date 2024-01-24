extends Node

@export var tilePrefabs : Array[Node2D]
@export var gridDimension : Vector2i
@export var tileHolder : Node

var tileMap : Array[SuperTileCell]
var tilesCache : Array[Node2D]

class SuperTileCell:
	var tilesAvailable : Array[Node2D]

# Called when the node enters the scene tree for the first time.
func _ready():
	InitializeTileMap()
	CheckForNeighbours(0, 0, -1)
	# GenerateTileMap()

#================================>	Testing  <================================
func InitializeTileMap():
	for index in gridDimension.x:
		var tileCell = SuperTileCell.new()
		tileMap.append(tileCell)
	# TestingTiles()

func TestingTiles():
	var createdTile = CreateTile(0)
	tileMap[0].tilesAvailable.append(createdTile)
	var createdTile2 = CreateTile(14)
	tileMap[0].tilesAvailable.append(createdTile2)
	
	var coOrdX = 0
	var coOrdY = 1
	var debugPrint = "tilesAvailable size : " + str(tileMap[coOrdX].tilesAvailable.size())
	if (tileMap[coOrdX].tilesAvailable[coOrdY] != null):
		print(debugPrint)
		debugPrint = "Initial Test | TileMap[" + str(coOrdX) + "," + str(coOrdY) +"] : Not null"
		print(debugPrint)
		debugPrint = "tilesAvailable[0] : " + str(tileMap[coOrdX].tilesAvailable[0].socketContainer.posX) + "tilesAvailable[1] : " + str(tileMap[coOrdX].tilesAvailable[1].socketContainer.posX)  + "tilesAvailable[-1] : " + str(tileMap[coOrdX].tilesAvailable[-1].socketContainer.posX)
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
func CheckForNeighbours(coOrdX, coOrdY, socketVal):
	# var debugPrint = "Checing For Neighbours in tile["+ str(coOrdX) + "," + str(coOrdY) +"]"
	# print(debugPrint);

	if (tileMap.size() > coOrdX && tileMap[coOrdX] != null):
		# debugPrint = "tileMap[" + str(coOrdX) + "] : Not null"
		# print(debugPrint);

		if (tileMap[coOrdX].tilesAvailable.size() > coOrdY && tileMap[coOrdX].tilesAvailable[coOrdY] != null):
			# debugPrint = "tileMap[" + str(coOrdX) + "," + str(coOrdY) +"] : Not null"
			# print(debugPrint);

			if (socketVal == -1):
				CheckForNeighbours(coOrdX-1, coOrdY, 0)
				CheckForNeighbours(coOrdX+1, coOrdY, 0)
				CheckForNeighbours(coOrdX, coOrdY-1, 0)
				CheckForNeighbours(coOrdX, coOrdY+1, 0)
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

#================================> Testing Area 1 <================================

func CreateTile(tileIndex) -> Node2D:
	# print("Generating Tile in YDir")
	# var tileToPlace = load(tilePrefabs[0])
	var tileToPlace = tilePrefabs[tileIndex].duplicate()
	tileToPlace.visible = true
	tileHolder.add_child(tileToPlace)
	return tileToPlace

# We would have to first cache all the data to a local variable in the script for easy access
func LoadTilesData():
	var sizeX = tileMap.size()
	for xVal in sizeX:
		var sizeY = tileMap[sizeX].tilesAvailable.size()
		for yVal in sizeY:
			tilesCache.append(tileMap[xVal].tilesAvailable[yVal].socketContainer)

func CheckNeighboursAdjaceny(coOrdX, coOrdY) -> int:

	# Array indexes in negative can wrap around, so beware!!
	if (coOrdX < 0 ||coOrdX >= gridDimension.x || coOrdY < 0 ||coOrdY >= gridDimension.y ):
		return false		#Early return if out of range

	# var debugPrint = "Checing For Neighbours in tile["+ str(coOrdX) + "," + str(coOrdY) +"]"
	# print(debugPrint);

	if (tileMap.size() > coOrdX && tileMap[coOrdX] != null):
		# debugPrint = "tileMap[" + str(coOrdX) + "] : Not null"
		# print(debugPrint);

		if (tileMap[coOrdX].tilesAvailable.size() > coOrdY && tileMap[coOrdX].tilesAvailable[coOrdY] != null):
			# debugPrint = "tileMap[" + str(coOrdX) + "," + str(coOrdY) +"] : Not null"
			# print(debugPrint);
			
			#This is a valid tile at this point
			
			#As all the tiles are in super position state. We will need to get the whole tile list 
			#and compare each tile's, every socket with the current tile's adjacency list, to get the
			#suitable tile to connect with the current tile's socket

			#This is wrong
			#Get all sockets of the neighbour
			# var socPosX = tileMap[coOrdX+1].tilesAvailable[coOrdY].socketContainer.posX			
			# var socNegX = tileMap[coOrdX-1].tilesAvailable[coOrdY].socketContainer.negX			
			# var socPosY = tileMap[coOrdX].tilesAvailable[coOrdY+1].socketContainer.posY			
			# var socNegY = tileMap[coOrdX].tilesAvailable[coOrdY-1].socketContainer.negY
			
			#Get each adjacency list of the current tile and store in cache for faster access
			var compAdjPosX = tileMap[coOrdX].tilesAvailable[coOrdY].socketContainer.adjPosX
			var compAdjNegX = tileMap[coOrdX].tilesAvailable[coOrdY].socketContainer.adjNegX
			var compAdjPosY = tileMap[coOrdX].tilesAvailable[coOrdY].socketContainer.adjPosY
			var compAdjNegY = tileMap[coOrdX].tilesAvailable[coOrdY].socketContainer.adjNegY

			#Compare each socket with adjacency list of the current tile
			#PosY -> NegY | NegY -> PosY | PosX -> NegX | NegX -> PosX

#==========================================> Suggestion <==========================================
			#Run a sorting algorithm to sort the adjacency list in ascending/descending order
			#After the list is sorted, we can run binary search to check if the given socket value
			#is greater, less or equal to the socket got from the tilesCache
#==========================================> Suggestion <==========================================

			#For now, we are just iterating through the whole adjacency array and comparing with the
			#tilesCache array

			#Compare socket PosX
			# var socCache = 0
			var tileIndex = 0
			for valX in compAdjPosX:
				for tileVal in tilesCache:
					if (compAdjPosX[valX] == tileVal.posX):
						#Found Compatible Socket
						print("Found Compatible Socket :", tileVal.posX)
						return tileIndex
					tileIndex += 1

			#Compare socket NegX
			tileIndex = 0
			for valNegX in compAdjNegX:
				for tileVal in tilesCache:
					if (compAdjNegX[valNegX] == tileVal.negX):
						#Found Compatible Socket
						print("Found Compatible Socket :", tileVal.negX)
						return tileIndex
					tileIndex += 1
					
			#Compare socket PosY
			tileIndex = 0
			for valPosY in compAdjPosY:
				for tileVal in tilesCache:
					if (compAdjPosX[valPosY] == tileVal.posY):
						#Found Compatible Socket
						print("Found Compatible Socket :", tileVal.posY)
						return tileIndex
					tileIndex += 1

			#Compare socket NegY
			tileIndex = 0
			for valNegY in compAdjNegY:
				for tileVal in tilesCache:
					if (compAdjPosX[valNegY] == tileVal.negY):
						#Found Compatible Socket
						print("Found Compatible Socket :", tileVal.negY)
						return tileIndex
					tileIndex += 1

	return -1
