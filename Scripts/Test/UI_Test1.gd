# Test Script for testing UI


class_name UI_Test1 extends Node

# Setting Texture Test
# @export var tileImg: TextureRect

# Setting Unique to all Textures
@export var tileTexRect_Og: TextureRect
@export var atlasTex_Og: AtlasTexture
@export var tileTexturesContainer: GridContainer
@export var tileTexArr: Array[TextureRect]

func _ready():
	# tileImg.texture.region = Rect2(0, 420, UniversalConstants.rectRegionScaleXY, UniversalConstants.rectRegionScaleXY)
	var tileArrSize = tileTexArr.size() - 1
	var tempTexPosX = 32
	for i in tileArrSize:
		tileTexArr[i] = tileTexRect_Og.duplicate()
		tileTexturesContainer.add_child(tileTexArr[i])

		tileTexArr[i].texture = atlasTex_Og.duplicate()
		tileTexArr[i].texture.region = Rect2(tempTexPosX, 32, UniversalConstants.rectRegionScaleXY, UniversalConstants.rectRegionScaleXY)
		tempTexPosX += 32
		# print("Atlas Texture Region : " + str(tileTexArr[i].texture.region))
	
	SetDirections_Test2()

func SetDirections_Test():
	var ogCoOrdX = 4
	var ogCoOrdY = 3

	var coOrdXMult = -1
	var coOrdYMult = 0

	var tempCoOrdX = 0
	var tempCoOrdY = 0

	# Set while loop here and keep repeating unless all the adjoining cells are collapsed 
	print("\n\nGot Tile to check| index : X[" + str(ogCoOrdX) + "], Y[" + str(ogCoOrdY) + "]")

	# Create SuperTiles along with Adjacecny Tile check in each possible direction
	for i in 4:
		# print("Instantiating at Position : ", position)
		# print("Tile CoOrd : [" + str(tileToCheckData.tileCoOrdX) + "," + str(tileToCheckData.tileCoOrdY) + "]")
		
		# [-1] is necessary for flipping y values as we will start y-values with 0
		# We will go -> (1, 0) | (0, -1) | (-1, 0) | (0 , -1)
		tempCoOrdX = ogCoOrdX + ((coOrdXMult % 2) * -1)
		tempCoOrdY = ogCoOrdY + ((coOrdYMult % 2) * -1)

		print("Checking Tile | i : " + str(i) + " | [" + str(ogCoOrdX) + "," + str(ogCoOrdY) + "]"
				+ " | Mult : [" + str(coOrdXMult) + "] [" + str(coOrdYMult) + "]"
				+ " | Dir : [" + str(tempCoOrdX) + "] [" + str(tempCoOrdY) + "]")

		coOrdXMult += -1
		coOrdYMult += -1


func SetDirections_Test2():
	var ogCoOrdX = 4
	var ogCoOrdY = 3

	var tempRotation = 180

	var tempCoOrdX = 0
	var tempCoOrdY = 0

	# Set while loop here and keep repeating unless all the adjoining cells are collapsed 
	print("\n\nGot Tile to check| index : X[" + str(ogCoOrdX) + "], Y[" + str(ogCoOrdY) + "]")

	# Create SuperTiles along with Adjacecny Tile check in each possible direction
	for i in 4:
		# print("Instantiating at Position : ", position)
		# print("Tile CoOrd : [" + str(tileToCheckData.tileCoOrdX) + "," + str(tileToCheckData.tileCoOrdY) + "]")
		
		# [-1] is necessary for flipping y values as we will start y-values with 0
		# We will go -> (1, 0) | (0, -1) | (-1, 0) | (0 , -1)
		tempCoOrdX = ogCoOrdX + cos(deg_to_rad(tempRotation))
		tempCoOrdY = ogCoOrdY + sin(deg_to_rad(tempRotation))

		print("Checking Tile | i : " + str(i) + " | [" + str(ogCoOrdX) + "," + str(ogCoOrdY) + "]"
				+ " | Rotation : " + str(tempRotation)
				+ " | Dir : [" + str(tempCoOrdX) + "] [" + str(tempCoOrdY) + "]")

		tempRotation -= 90