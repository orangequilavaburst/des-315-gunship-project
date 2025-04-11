class_name PlayerShipSettings
extends ShipSettings

@export_group("Player Information")
@export var playerName : String
@export var playerShipSprite : Texture2D
@export var playerIconSprite : Texture2D

@export_group("Regeneration Info")
@export_range(0.0, 1.0) var regenThreshold : float = 0.25
@export_range(0.0, 10.0) var regenTime : float = 0.25
@export_range(0.0, 10000.0) var regenPotency : float = 5.0

@export_group("Bullet Time Modifiers")
@export_range(0.00, 1.0) var bulletTimeThreshold : float = 0.25
@export_range(0.01, 1.0) var bulletTimeMaxMultiplier : float = 0.5

@export_group("Weapon Settings")
@export var mainWeaponSettings : EmitterSettings
@export var subWeaponSettings : EmitterSettings
