extends Node

class NeighbourContainer:
	var neighbours : Array[int]

var compatibilityList : Array[NeighbourContainer]

# Called when the node enters the scene tree for the first time.
func _ready():
	for i in 5:
		compatibilityList[i] = NeighbourContainer.new()
	compatibilityList[0].neighbours = [3,1]
	compatibilityList[1].neighbours = [2,4,0]
	compatibilityList[2].neighbours = [3,1,4]
	compatibilityList[3].neighbours = [2,0]
	compatibilityList[4].neighbours = [2,1]

