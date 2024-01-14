extends Node

@export var posX : int
@export var negX : int
@export var posY : int
@export var negY : int

@export var adjPosX : Array[int]
@export var adjNegX : Array[int]
@export var adjPosY : Array[int]
@export var adjNegY : Array[int]

func _ready():
    process_mode = Node.PROCESS_MODE_DISABLED       # Dont need to enable this, this is only a container

# @export var shgsr: Array[adjacencyContainer]
# class adjacencyContainer extends Resource:
#     @export var posX : Array[int]
#     @export var negX : Array[int]
#     @export var posY : Array[int]
#     @export var negY : Array[int]