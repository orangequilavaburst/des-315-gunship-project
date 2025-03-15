extends Node

@export_range(0.0, 5.0) var deltaTimeMultiplier = 1.0
@export var playerShips : Array[PlayerShipSettings]
@export var player : ShipController

var playerShipIndex : int = 0:
	set(value):
		playerShipIndex = fposmod(value, playerShips.size()) 
		player.shipSettings = playerShips[playerShipIndex]
		print_rich("[i]GameManager:[i] Player ship changed to " + str(playerShips[playerShipIndex].playerName))

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(playerShips.size() > 0)
	
	player.shipSettings = playerShips[playerShipIndex]
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed:
			match(event.keycode):
				KEY_COMMA:
					playerShipIndex -= 1
					pass
				KEY_PERIOD:
					playerShipIndex += 1
					pass
