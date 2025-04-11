class_name EmitterSettings
extends Resource

# basic stuff

@export var objectToSpawn : PackedScene
@export var parentToRoot : bool = true
@export var inheritParentVelocity : bool = true
@export var alwaysFire : bool =  true

# angle shooting stuff

@export_range(0.0, 360.0) var angleJitter : float # 0-360
@export_range(1, 100) var objectCount : int = 1 # >0
@export_range(0.0, 360.0) var objectAngleSpread : float # 0-360
@export_range(0.0, 360.0) var objectAngleSpreadJitter : float: # 0-(objectAngleSpread/objectCount)
	set(value):
		objectAngleSpreadJitter = clamp(value, 0.0, objectAngleSpread/objectCount)
	get():
		return clamp(objectAngleSpreadJitter, 0.0, objectAngleSpread/objectCount)
@export_range(1, 100) var burstCount : int # >0
@export var burstAngleOffset : Vector2 # -180 - 180, basically goes from one angle to another
@export var burstAngleOffsetCurve : Curve
@export_range(0.0, 10.0) var burstShootTime : float # >=1/60

# position shooting stuff
@export var positionOffset : Vector2 = Vector2.ZERO
@export var positionOffsetJitter : Vector2 = Vector2.ZERO
@export var positionOffsetRotated : bool = true
@export var positionOffsetFromCenter : bool = false

# misc shooting stuff
@export_range(0.0, 10.0) var shootTime : float = 1.0
