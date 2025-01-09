class_name UITileController_1 extends Control

@export var btControl: Control
@export var tileID: int
@export var tileEnabled: bool


"""
# Called when the node enters the scene tree for the first time.
func _ready():
	
	# print(btControl.theme.has_stylebox("StyleBoxFlat", "StyleBoxFlat"))
	# print(btControl.theme.has_stylebox("Disabled_Stylebox_2", "StyleBoxFlat"))
	# print(btControl.theme.has_stylebox("BtPrefab_1", "Button"))
	# print(btControl.theme.has_stylebox("StyleBoxFlat", "Button"))
	# print(btControl.theme.has_stylebox("BtTheme_2", "Button"))

	# print(btControl.theme.has_stylebox("normal", "Button"))				# Somehow this is true, how????????
	pass
"""


# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta):
# 	pass


func _on_tile_bt_pressed():
	# if global_position.distance_to(get_global_mouse_position()) < 5:
	if tileEnabled:
		print("Tile Enabled : " + str(tileID))
		btControl.theme.get_stylebox("normal", "Button").bg_color = UniversalConstants.pressedColor

func _on_mouse_entered_tile():
	tileEnabled = true
	# print("Mouse Entered : " + str(tileID))


func _on_mouse_exited_tile():
	tileEnabled = false
	# print("Mouse Exited : " + str(tileID))
