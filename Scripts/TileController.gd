extends Node2D

enum Socket {SOCKET_A, SOCKET_B, SOCKET_C, SOCKET_D, SOCKET_E, }

@export var sprite2D : Sprite2D
@export var socketType : Socket

var socketChosen : TileSocket

# Called when the node enters the scene tree for the first time.
# func _ready():
	# sprite2D = get_node("TileSprite")

func AssignSocket():
	match (socketChosen):
		Socket.SOCKET_A:
			socketChosen = SocketA.new()
		Socket.SOCKET_B:
			socketChosen = SocketB.new()
		Socket.SOCKET_C:
			socketChosen = SocketC.new()
		Socket.SOCKET_D:
			socketChosen = SocketD.new()
		Socket.SOCKET_E:
			socketChosen = SocketE.new()
	
func SetTextureToTile(tex):
	sprite2D.texture = tex
		

# Called every frame. 'delta' is the elapsed time since the previous frame.
# func _process(delta):
# 	pass


class TileSocket extends Resource:
	@export var rot : int

class SocketA extends TileSocket:
	var posX = 1
	var negX = 0
	var posY = 2
	var negY = 3
	
class SocketB extends TileSocket:
	var posX = 1
	var negX = 2
	var posY = 2
	var negY = 3
	
class SocketC extends TileSocket:
	var posX = 1
	var negX = 3
	var posY = 0
	var negY = 4
	
class SocketD extends TileSocket:
	var posX = 4
	var negX = 0
	var posY = 2
	var negY = 3

class SocketE extends TileSocket:
	var posX = 2
	var negX = 3
	var posY = 2
	var negY = 0
