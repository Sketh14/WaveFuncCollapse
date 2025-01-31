# TODO: Refactor this to MainUIController
# 			[=] MainUiController to have an array of these so that each individual tile does not increase the load

class_name UITileController_1 extends Control

# @export var btControl: Control
@export var tileID: int
# @export var rectRegionPos: Vector2i			# Taking directly from jsonData

# var bt: Button
var tileTex: TextureRect
var tileChanged: bool
# @export var tileEnabled: bool # export for debug
# @export var tileID_Label: Label

var waveFunctionHandler: WaveFunctionCollapse2
var mainUIController: MainUiController_1

func _ready():
	"""
		# print(self.theme.has_stylebox("StyleBoxFlat", "StyleBoxFlat"))
		# print(self.theme.has_stylebox("Disabled_Stylebox_2", "StyleBoxFlat"))
		# print(self.theme.has_stylebox("BtPrefab_1", "Button"))
		# print(self.theme.has_stylebox("StyleBoxFlat", "Button"))
		# print(self.theme.has_stylebox("BtTheme_2", "Button"))

		# print(self.theme.has_stylebox("normal", "Button"))				# Somehow this is true, how????????
		pass
	"""

	waveFunctionHandler = get_tree().get_root().get_node(UniversalConstants.waveFunctionScriptPath) as WaveFunctionCollapse2
	waveFunctionHandler.UpdateTileData_sig.connect(UpdateButtonText)
	waveFunctionHandler.TileMapStatus_sig.connect(ResetTile)

	mainUIController = get_tree().get_root().get_node(UniversalConstants.mainUIControllerScriptPath) as MainUiController_1

	tileTex = get_child(1) # For Background
	# tileTex.texture = waveFunctionHandler.tileAtlasTextures[waveFunctionHandler.tilesJsonData.tile_info[i].atlas_texture_properties[0]].duplicate()
	tileTex.texture = waveFunctionHandler.tileAtlasTexture.duplicate()
	tileTex = get_child(2) # For Foreground
	tileTex.texture = waveFunctionHandler.tileAtlasTexture.duplicate()

	# self.text = "> This <" # This is Crazy

	# Testing # https://www.reddit.com/r/godot/comments/aad39n/how_to_change_texturerect_atlas_texture_region_in/
	# tileTex.texture.region = Rect2(rectRegionPos.x, rectRegionPos.y, UniversalConstants.rectRegionScaleXY, UniversalConstants.rectRegionScaleXY)
	# print("Atlas Texture Region : " + str(tileTex.texture.region))
	
	# await get_tree().create_timer(1.0).timeout
	# _on_tile_updated()

func _on_tile_bt_pressed():
	mainUIController.SetCurrentAndShowAvailableTiles(tileID)
	# var tileIdsToDebug = str(tileID)
	# tileID_Label.text = str(tileID)
	"""
	if global_position.distance_to(get_global_mouse_position()) < 5:
	if tileEnabled:
		print("Tile Enabled : " + str(tileID))
		self.theme.get_stylebox("normal", "Button").bg_color = UniversalConstants.pressedColor		# no need to change the color
		tileID_Label.text = str(tileID)
	"""

func UpdateButtonText(tileMapTileID: int):
	if (tileMapTileID == tileID && waveFunctionHandler.tileMap[tileMapTileID].collapsed):
		tileChanged = true
		var tempTileIndex = waveFunctionHandler.tileMap[tileMapTileID].currentTileIndex
		self.text = "> " + str(tempTileIndex) + " <"

		# Setting new position
		var tempVec = self.size
		tempVec.x += UniversalConstants.tileSizeAdd
		tempVec.y += UniversalConstants.tileSizeAdd
		self.size = tempVec

		# Setting new position
		tempVec = self.position
		tempVec.x -= (UniversalConstants.tileSizeAdd / 2)
		tempVec.y -= (UniversalConstants.tileSizeAdd / 2)
		self.position = tempVec

		var randomBgIndex: int
		var tileTexIndex = waveFunctionHandler.tilesJsonData.tile_info[tempTileIndex].atlas_texture_properties[0]

		# Setting BG
		# If defined, then get Index of the BG
		if (tileTexIndex == 0):
			(get_child(1) as TextureRect).texture.region = Rect2(waveFunctionHandler.tilesJsonData.tile_info[tempTileIndex].atlas_texture_properties[1],
						waveFunctionHandler.tilesJsonData.tile_info[tempTileIndex].atlas_texture_properties[2],
						UniversalConstants.rectRegionScaleXY, UniversalConstants.rectRegionScaleXY)
		# If not, then get a random BG Index
		else:
			randomBgIndex = randi_range(4, 7)
			(get_child(1) as TextureRect).texture.region = Rect2(waveFunctionHandler.tilesJsonData.tile_info[randomBgIndex].atlas_texture_properties[1],
						waveFunctionHandler.tilesJsonData.tile_info[randomBgIndex].atlas_texture_properties[2],
						UniversalConstants.rectRegionScaleXY, UniversalConstants.rectRegionScaleXY)

		# Setting FG
		(get_child(2) as TextureRect).texture.region = Rect2(waveFunctionHandler.tilesJsonData.tile_info[tempTileIndex].atlas_texture_properties[1],
					waveFunctionHandler.tilesJsonData.tile_info[tempTileIndex].atlas_texture_properties[2],
					UniversalConstants.rectRegionScaleXY, UniversalConstants.rectRegionScaleXY)

	# self.text = str(tileID) + " | " + str(mainUIController.selectedTilesBts.size()) # Offset by 1

func ResetTile(tileMapStatus: int):
	if (tileMapStatus != (UniversalConstants.TileMapStatus.RESET as int) || !tileChanged): return
	tileChanged = false

	self.text = str(tileID)

	# Setting new position
	var tempVec = self.size
	tempVec.x -= UniversalConstants.tileSizeAdd
	tempVec.y -= UniversalConstants.tileSizeAdd
	self.size = tempVec

	# Setting new position
	tempVec = self.position
	tempVec.x += (UniversalConstants.tileSizeAdd / 2)
	tempVec.y += (UniversalConstants.tileSizeAdd / 2)
	self.position = tempVec

	(get_child(1) as TextureRect).texture.region = Rect2(UniversalConstants.defaultTileMapPos.x, UniversalConstants.defaultTileMapPos.y,
				UniversalConstants.rectRegionScaleXY, UniversalConstants.rectRegionScaleXY)

	# Setting FG
	(get_child(2) as TextureRect).texture.region = Rect2(UniversalConstants.defaultTileMapPos.x, UniversalConstants.defaultTileMapPos.y,
				UniversalConstants.rectRegionScaleXY, UniversalConstants.rectRegionScaleXY)


"""
func _on_mouse_entered_tile():
	tileEnabled = true
	# print("Mouse Entered : " + str(tileID))

func _on_mouse_exited_tile():
	tileEnabled = false
	# print("Mouse Exited : " + str(tileID))
"""

"""
https://www.reddit.com/r/godot/comments/1b2hmii/text_size_auto_increase_with_label_size/
func _on_tile_updated():
	tileID_Label.theme.set_font_size("font_size", "Label", 13)
	# print("Label Font Size : " + str(tileID_Label.theme.get_font_size("font_size", "Label")))

	var font = get_theme_font("font")
	var font_size = get_theme_font_size("font_size")

	var line = TextLine.new()
	line.direction = text_direction
	line.flags = justification_flags
	line.alignment = horizontal_alignment

	for i in 20:
		line.clear()
		var created = line.add_string(text, font, font_size)
		if created:
			var text_size = line.get_line_width()

			if text_size > floor(size.x):
				font_size -= 1
			elif font_size < max_font_size:
				font_size += 1
			else:
				break
		else:
			push_warning('Could not create a string')
			break

	add_theme_font_size_override("font_size", font_size)
"""

"""
# https://github.com/godotengine/godot-proposals/issues/7750
func _calculate_best_font_size() -> int:
	var available_width = size.x * font_size_width_percent
	var available_height = size.y

	var font = get_theme_font("font")
	var font_size = font_size_max

	while font_size > font_size_min:
		var text_size = font.get_string_size(text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size)
		if text_size.x <= available_width and text_size.y <= available_height:
			break
		
		font_size -= 1

	return int(max(font_size_min, min(font_size_max, font_size)))
"""
