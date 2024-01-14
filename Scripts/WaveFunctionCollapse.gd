extends Node

@export var tilePrefabs : Array[Node2D]
@export var gridDimension : Vector2i
@export var tileHolder : Node

var tileMap : Array[SuperTileCell]

class SuperTileCell:
	var tilesAvailable : Array[Node2D]

# Called when the node enters the scene tree for the first time.
func _ready():
	InitializeTileMap()
	GenerateTileMap()

func InitializeTileMap():
	for index in gridDimension.x:
		var tileCell = SuperTileCell.new()
		tileMap.append(tileCell)

func GenerateTileMap():
	# print("Generating Tiles");
	var tileCountX = -gridDimension.x/2
	for xVal in gridDimension.x:
		var tileCountY = -gridDimension.y/2
		# print("xVal : %d" %xVal)
		# print("Arr Count: %d" %tileMap.size())
		for yVal in gridDimension.y:
			var createdTile = CreateTile()
			tileMap[xVal].tilesAvailable.append(createdTile) 
			createdTile.position = Vector2(32.0 * tileCountX, 32.0 * tileCountY)			# Tiles size is 64 x 64
			tileCountY += 1
			if (tileCountY == 0):
				tileCountY *= -1
		tileCountX += 1
		if (tileCountX == 0):
			tileCountX *= -1

func CreateTile() -> Node2D:
	# print("Generating Tile in YDir")
	# var tileToPlace = load(tilePrefabs[0])
	var tileToPlace = tilePrefabs[0].duplicate()
	tileToPlace.visible = true
	tileHolder.add_child(tileToPlace)
	return tileToPlace


