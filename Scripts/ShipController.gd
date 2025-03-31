class_name ShipController
extends CharacterBody2D

signal ship_settings_changed(new_settings)

@onready var gameManager : GameManager = get_tree().root.get_children()[0].get_children().filter(func(element): return (element is GameManager))[0]

#@export_group("Physics Variables")
#@export_subgroup("Velocity and Acceleration")
var angle : float = 0.0:
	set(value):
		angle = fposmod(value + 360.0, 360.0)
	get():
		return fposmod(angle + 360.0, 360.0)
var linearVelocity : float = 0.0:
	set(value):
		var mv : float = maximumLinearVelocity if (turningSlowdownRatio <= 0) else maximumLinearVelocity*(1.0 - turningSlowdownRatio*abs(angularVelocity/maximumAngularVelocity))
		linearVelocity = clamp(value, -mv, mv)
	get():
		var mv : float = maximumLinearVelocity if (turningSlowdownRatio <= 0) else maximumLinearVelocity*(1.0 - turningSlowdownRatio*abs(angularVelocity/maximumAngularVelocity))
		return clamp(linearVelocity, -mv, mv)
var angularVelocity : float = 0.0:
	set(value):
		angularVelocity = clamp(value, -maximumAngularVelocity, maximumAngularVelocity)
	get():
		return clamp(angularVelocity, -maximumAngularVelocity, maximumAngularVelocity)
var linearAcceleration : float = 0.0:
	set(value):
		linearAcceleration = clamp(value, -maximumLinearAcceleration, maximumLinearAcceleration)
	get():
		return clamp(linearAcceleration, -maximumLinearAcceleration, maximumLinearAcceleration)
var angularAcceleration : float = 0.0:
	set(value):
		angularAcceleration = clamp(value, -maximumAngularAcceleration, maximumAngularAcceleration)
	get():
		return clamp(angularAcceleration, -maximumAngularAcceleration, maximumAngularAcceleration)
var extraVelocity : Vector2 = Vector2.ZERO # used for pushing

#@export_range(0.0, 1000.0) 
var maximumLinearVelocity : float = 0.0
#@export_range(0.0, 1000.0) 
var maximumAngularVelocity : float = 0.0
#@export_range(0.0, 10000.0) 
var maximumLinearAcceleration : float = 0.0
#@export_range(0.0, 10000.0) 
var maximumAngularAcceleration : float = 0.0
#@export_range(0.0, 10000.0) 
var linearFriction : float = 0.0
#@export_range(0.0, 10000.0) 
var angularFriction : float = 0.0
#@export_range(0.0, 1.0) 
var turningSlowdownRatio : float = 0.0 # 0.0 = don't slow down at all, 1.0 = stop to turn

#@export_subgroup("Acceleration Curves")

var linearAccelerationTimer : float = 0.0:
	set(value):
		linearAccelerationTimer = clamp(value, -linearAccelerationTime, linearAccelerationTime)
	get():
		return clamp(linearAccelerationTimer, -linearAccelerationTime, linearAccelerationTime)
var angularAccelerationTimer : float = 0.0:
	set(value):
		angularAccelerationTimer = clamp(value, -angularAccelerationTime, angularAccelerationTime)
	get():
		return clamp(angularAccelerationTimer, -angularAccelerationTime, angularAccelerationTime)

#@export_range(0.0, 10.0) 
var linearAccelerationTime : float = 1.0
#@export 
var linearAccelerationCurve : Curve
#@export_range(0.0, 10.0) 
var angularAccelerationTime : float = 1.0
#@export 
var angularAccelerationCurve : Curve

var controlType : ShipSettings.ShipControlType

@export_group("Object References")
@export var shipInput : ShipInput
@export var shipSettings : ShipSettings:
	set(value):
		shipSettings = value
		if shipSettings != null:
			apply_settings(shipSettings)
		ship_settings_changed.emit(shipSettings)
@export var collisionShape : CollisionShape2D
@export var health : Health
@export var shipSprite : Sprite2D
@export var mainWeaponEmitter : Emitter
@export var subWeaponEmitter : Emitter

func _ready() -> void:
	
	apply_settings(shipSettings)
	
	pass
	
func _process(delta: float) -> void:
	delta *= gameManager.deltaTimeMultiplier
	

func _physics_process(delta: float) -> void:
	handle_ship_movement(delta, gameManager.deltaTimeMultiplier)
	
	move_and_slide()

func handle_ship_movement(delta : float, time_scale : float = 1.0) -> void:
	
	if time_scale <= 0.0:
		return
	
	velocity = velocity / time_scale
	delta *= time_scale
	
	## handle angle stuff
	
	var turnInput : float = shipInput.input.x if (health == null or health != null and health.healthState == Health.HealthState.ALIVE) else 0.0
	
	# find curve amount
		
	if abs(turnInput) > 0:
		if (sign(angularAcceleration) == 0 or sign(turnInput) == sign(angularAcceleration)):
			angularAccelerationTimer += delta * turnInput
		else:
			angularAccelerationTimer = 0
	
	var aaccelCurveValue = angularAccelerationCurve.sample(abs(angularAccelerationTimer)/angularAccelerationTime)*sign(angularAccelerationTimer)
	
	# turn stuff
	
	if abs(turnInput) > 0:
		if angularVelocity == 0 or sign(angularVelocity) == sign(angularAcceleration):
			angularAcceleration = maximumAngularAcceleration * aaccelCurveValue
		else:
			angularAcceleration = (maximumAngularAcceleration + angularFriction) * aaccelCurveValue
		angularVelocity += angularAcceleration * delta
	else:
		angularAccelerationTimer = 0
		angularAcceleration = angularFriction * -sign(angularVelocity)
		if (sign(angularVelocity) != sign(angularVelocity + angularAcceleration * delta) or angularVelocity == 0.0):
			angularVelocity = 0.0
			angularAcceleration = 0.0
		else:
			angularVelocity += angularAcceleration * delta
	
	## handle linear velocity
	
	var thrustInput : float = -shipInput.input.y if (health == null or health != null and health.healthState == Health.HealthState.ALIVE) else 0.0
	
	# find curve amount
	
	if abs(thrustInput) > 0:
		if (sign(linearAcceleration) == 0 or sign(thrustInput) == sign(linearAcceleration)):
			linearAccelerationTimer += delta * thrustInput
		else:
			linearAccelerationTimer = 0
		
	
	var laccelCurveValue = linearAccelerationCurve.sample(abs(linearAccelerationTimer)/linearAccelerationTime)*sign(linearAccelerationTimer)
	
	# thrust stuff
	
	if abs(thrustInput) > 0:
		if linearVelocity == 0 or sign(linearVelocity) == sign(linearAcceleration):
			linearAcceleration = maximumLinearAcceleration * laccelCurveValue
		else:
			linearAcceleration = (maximumLinearAcceleration + linearFriction) * laccelCurveValue
		linearVelocity += linearAcceleration * delta
	else:
		linearAccelerationTimer = 0
		linearAcceleration = linearFriction * -sign(linearVelocity)
		if (sign(linearVelocity) != sign(linearVelocity + linearAcceleration * delta) or linearVelocity == 0.0):
			linearVelocity = 0.0
			linearAcceleration = 0.0
		else:
			linearVelocity += linearAcceleration * delta
	
	#print("linear accel: %.02f, linear velocity: %.02f" % [linearAcceleration, linearVelocity])
	
	## actually move
	
	# define extra velocity
	if extraVelocity.length() > 0:
		var newExVel : Vector2 = extraVelocity.move_toward(Vector2.ZERO, delta*linearFriction)
		if newExVel.length() > delta:
			extraVelocity = newExVel
		else:
			extraVelocity = Vector2.ZERO
	
	angle += angularVelocity * delta
	rotation_degrees = angle
	#velocity = Vector2.from_angle(deg_to_rad(angle)) * linearVelocity
	
	if controlType != shipSettings.controlType:
		controlType = shipSettings.controlType
	match(controlType):
		ShipSettings.ShipControlType.TANK:
			velocity = Vector2.from_angle(deg_to_rad(angle)) * linearVelocity + extraVelocity
		ShipSettings.ShipControlType.ASTEROIDS:
			if abs(thrustInput) > 0:
				velocity += Vector2.from_angle(deg_to_rad(angle)) * linearAcceleration
				if velocity.length() > maximumLinearVelocity:
					velocity = velocity.normalized() * maximumLinearVelocity
			else:
				if (velocity.length() - linearFriction*delta) > 0.0:
					velocity = velocity.normalized() * max(0.0, velocity.length() - linearFriction*delta)
				velocity += extraVelocity
				
	velocity *= time_scale

func apply_settings(settings : ShipSettings) -> void:
	#assert(shipInput != null and settings != null and collisionShape != null)
	
	maximumLinearVelocity = settings.maximumLinearVelocity
	maximumAngularVelocity = settings.maximumAngularVelocity
	maximumLinearAcceleration = settings.maximumLinearAcceleration
	maximumAngularAcceleration = settings.maximumAngularAcceleration
	linearFriction = settings.linearFriction
	angularFriction = settings.angularFriction
	turningSlowdownRatio = settings.turningSlowdownRatio
	linearAccelerationTime = settings.linearAccelerationTime
	linearAccelerationCurve = settings.linearAccelerationCurve
	angularAccelerationTime = settings.linearAccelerationTime
	angularAccelerationCurve = shipSettings.angularAccelerationCurve
	controlType = shipSettings.controlType
	
	if collisionShape != null:
		collisionShape.shape = settings.collisionShape
	if health != null:
		health.set_max_health(settings.maxHealth, true)
		health.currentHealth = health.maxHealth
	if shipSprite != null and settings is PlayerShipSettings:
		shipSprite.texture = settings.playerShipSprite
	
