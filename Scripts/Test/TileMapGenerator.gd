"""
Not been added to the Main scene yet
"""

extends Node

@export var texturesToUse: Array[Texture]
@export var gridDimension: Vector2
@export var tileHolder: Node

const tilePrefabPath = "res://Prefab/Tile/Grass/TilePrefab_2.tscn" # "res://Prefab/TilePrefab.tscn"
var tilePrefab: PackedScene

# Called when the node enters the scene tree for the first time.
func _ready():
	tilePrefab = preload(tilePrefabPath)
	# GenerateTileMap()


func GenerateTileMap():
	# print("Generating Tiles");
	for xVal in gridDimension.x:
		for yVal in gridDimension.y:
			var createdTile = CreateTile()
			createdTile.position = Vector2(0.0, -128.0) # Tiles size is 64 x 64

func CreateTile() -> Node2D:
	print("Generating Tile in YDir")
	var tileToPlace = tilePrefab.instantiate()
	tileToPlace.SetTextureToTile(texturesToUse[0])
	tileHolder.add_child(tileToPlace)
	return tileToPlace


# func AssignSprites(nodeToAssignTo):
# 	nodeToAssignTo.SetTextureToTile(texturesToUse[0])
	# var con = (TileController)get_node(nodeToAssignTo)

# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta):
# 	pass
