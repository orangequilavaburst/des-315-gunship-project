class_name GameManager
extends Node

signal game_reset()

@export_range(0.0, 5.0) var deltaTimeMultiplier = 1.0
var bulletTimeMultiplier : float = 1.0 # for the lerp
@export var playerShips : Array[PlayerShipSettings]
@export var player : ShipController
@export var camera : Camera2D
@export var swarmManager : SwarmManager

@export var bulletTimeScaleMax = 0.1
@export var bulletTimeTimeMax = 2.0
var time_tween : Tween

var playerShipIndex : int = 0:
	set(value):
		playerShipIndex = posmod(value, playerShips.size()) 
		player.shipSettings = playerShips[playerShipIndex]
		player.health.healthState = Health.HealthState.ALIVE
		print_rich("[i]GameManager:[i] Player ship changed to " + str(playerShips[playerShipIndex].playerName))

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(playerShips.size() > 0 and swarmManager != null)
	
	player.shipSettings = playerShips[playerShipIndex]
	player.health.health_hurt.connect(player_hurt)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	var playerTimeMultiplier : float = 1.0
	if player != null:
		if player.shipSettings is PlayerShipSettings:
			if (player.shipSettings as PlayerShipSettings).bulletTimeThreshold > 0.0 and player.health.currentHealth <= (player.shipSettings as PlayerShipSettings).bulletTimeThreshold*player.health.maxHealth:
				playerTimeMultiplier = lerp((player.shipSettings as PlayerShipSettings).bulletTimeMaxMultiplier, 1.0, min(1.0, player.health.currentHealth/((player.shipSettings as PlayerShipSettings).bulletTimeThreshold*player.health.maxHealth)))
	deltaTimeMultiplier = bulletTimeMultiplier * playerTimeMultiplier
	pass
	
# Called when the main player gets hurt
func player_hurt(damage : float, new_health : float):
	if player.health.currentHealth > 0.0:
		var t : float = min(player.health.maxHealth, new_health)/player.health.maxHealth
		
		if time_tween:
			time_tween.kill()
		time_tween = create_tween()
		bulletTimeMultiplier = bulletTimeScaleMax * t
		time_tween.tween_property(self, "bulletTimeMultiplier", 1.0, (1.0-t) * bulletTimeTimeMax)

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.pressed:
			match(event.keycode):
				KEY_L:
					player.shipInput.doDebugDraw = not player.shipInput.doDebugDraw
					pass
				KEY_COMMA:
					playerShipIndex -= 1
					pass
				KEY_PERIOD:
					playerShipIndex += 1
					pass
				KEY_R:
					_game_reset()
					pass
				KEY_1:
					playerShipIndex = 0
					pass
				KEY_2:
					playerShipIndex = 1
					pass
				KEY_3:
					playerShipIndex = 2
					pass
				KEY_4:
					playerShipIndex = 3
					pass
				KEY_5:
					playerShipIndex = 4
					pass
				KEY_6:
					playerShipIndex = 5
					pass
				KEY_7:
					playerShipIndex = 6
					pass
				KEY_8:
					playerShipIndex = 7
					pass
				KEY_9:
					playerShipIndex = 8
					pass
				KEY_0:
					playerShipIndex = 9
					pass
					
func _game_reset() -> void:
	game_reset.emit()
	get_tree().reload_current_scene()
