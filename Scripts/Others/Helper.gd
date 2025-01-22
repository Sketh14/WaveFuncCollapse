# extends Node
class_name Helper

class SuperTileCell:
	var collapsed: bool
	var currentTileIndex: int
	var tilesCount: int
	var tilesAvailable: Array[int]

class TransposedTileData:
	var tileCoOrdX: int
	var tileCoOrdY: int
	var socketDir: UniversalConstants.SocketDirection
	var parentTileID: int
