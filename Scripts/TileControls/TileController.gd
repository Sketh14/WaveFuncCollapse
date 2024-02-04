extends Node2D

@export var sprite2D : Sprite2D

@export var socketContainer : Node

# Called when the node enters the scene tree for the first time.
func _ready():
	# socket = get_node("Socket").get_script()   #This does not work
	# print("Name = %s" % socket.get_name())	#Does not work

	# print("posX = %d"% socketContainer.posX)		#This works
	pass
	
func SetTextureToTile(tex):
	sprite2D.texture = tex



# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta):
# 	pass
