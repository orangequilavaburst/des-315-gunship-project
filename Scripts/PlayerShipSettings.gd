class_name PlayerShipSettings
extends ShipSettings

@export_group("Player Information")
@export var playerName : String
@export var playerShipSprite : Texture2D
@export var playerIconSprite : Texture2D

@export_group("Bullet Time Modifiers")
@export_range(0.00, 1.0) var bulletTimeThreshold : float = 0.25
@export_range(0.01, 1.0) var bulletTimeMaxMultiplier : float = 0.5
