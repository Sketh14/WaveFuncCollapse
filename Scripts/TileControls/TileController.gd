extends Node2D

@export var sprite2D: Sprite2D

#TODO: Refactor this
# @export var fgSpritePresent : bool
@export var fgSprite2D: Sprite2D

@export var socketContainer: Node

# Called when the node enters the scene tree for the first time.
func _ready():
	# socket = get_node("Socket").get_script()   #This does not work
	# print("Name = %s" % socket.get_name())	#Does not work
	# print("posX = %d"% socketContainer.posX)		#This works
	sprite2D.visible = false
	
func SetTextureToTile(tex):
	sprite2D.texture = tex

func set_texture_region(xVal: int, yVal: int):
	sprite2D.region_rect.position = Vector2(xVal, yVal)
	sprite2D.visible = true

	if (fgSprite2D != null):
		fgSprite2D.visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta):
# 	pass
