class_name UIController
extends Control

@export var shipSettingsController : ShipController
var shipSettings : PlayerShipSettings
var health : Health
var healthDigits : int:
	set(value):
		healthDigits = max(value, 1)
	get():
		return max(1, healthDigits)

@export var playerIcon : Sprite2D
@export var playerLabel : Label
@export var healthLabel : Label
@export var healthBar : ProgressBar
#@export var controlLabel : Label

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(shipSettingsController != null)
	update_ship_settings(shipSettings)
	shipSettingsController.ship_settings_changed.connect(update_ship_settings)
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	global_position = get_viewport().get_camera_2d().global_position - get_viewport_rect().size/2.0
	
	pass

func update_ship_settings(settings : ShipSettings = shipSettings) -> void:
	if settings == null:
		return
	
	assert(settings is PlayerShipSettings)
	shipSettings = settings
	health = shipSettingsController.health
	healthDigits = (log(health.maxHealth) / log(10.0)) + 1 if (health != null) else 1
	
	if health != null:
		health.health_changed.connect(update_health_info)
	
	update_player_info()
	update_health_info()

func update_player_info() -> void:
	playerIcon.texture = shipSettings.playerIconSprite
	playerLabel.text = shipSettings.playerName.to_upper()
	#controlLabel.text = ShipSettings.ShipControlType.keys()[shipSettings.controlType]
	pass

func update_health_info(old_health : float = health.currentHealth, new_health : float = health.currentHealth) -> void:
	
	var hpText = "%0" + str(healthDigits) + "d"
	healthLabel.text = ("HEALTH " + hpText + "/" + hpText) % [health.currentHealth, health.maxHealth]
	healthBar.min_value = 0.0
	healthBar.max_value = health.maxHealth
	healthBar.value = health.currentHealth
	pass
