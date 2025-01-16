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
