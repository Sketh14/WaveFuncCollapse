extends Control

@export var tileIndex : int
@export var tileLabel : Label

# Called when the node enters the scene tree for the first time.
func _ready():
	tileLabel.text = str(tileIndex)
