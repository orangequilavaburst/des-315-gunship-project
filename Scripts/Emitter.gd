class_name Emitter
extends Node2D

@onready var gameManager : GameManager = get_tree().root.get_children()[0].get_children().filter(func(element): return (element is GameManager))[0]

signal burst_started()
signal emitter_shot()
signal settings_changed(new_settings)

@export var emitterSettings : EmitterSettings

# basic stuff

var objectToSpawn : PackedScene
var parentToRoot : bool
var inheritParentVelocity : bool
var alwaysFire : bool

var recoilSpeed : float

# angle shooting stuff

var angleJitter : float # 0-360
var objectCount : int # >0
var objectAngleSpread : float # 0-360
var objectAngleSpreadJitter : float # 0-(objectAngleSpread/objectCount)
var burstCount : int # >0
var burstAngleOffset : Vector2 # -180 - 180, basically goes from one angle to another
var burstAngleOffsetCurve : Curve
var burstShootTime : float # >=0.0

# position shooting stuff

var positionOffset : Vector2
var positionOffsetJitter : Vector2
var positionOffsetRotated : bool
var positionOffsetFromCenter : bool

# timers

var shootTime : float # time between shots
var shootTimer : float # used to begin shooting
var burstTimer : float # used for the burst
var burstsLeft : int # used for the burst
var shootReady : bool # used for firing

# Called when the node enters the scene tree for the first time.
func _ready():
	
	assert(emitterSettings != null)
	
	apply_settings(emitterSettings)
	
	shootTimer = 0
	burstTimer = 0
	burstsLeft = 0
	
	if alwaysFire:
		shootTimer = shootTime
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	delta *= gameManager.deltaTimeMultiplier
	
	if shootTimer > 0.0: # time between bursts
		shootTimer -= delta
		if shootTimer <= 0.0:
			shootTimer = 0.0
	else:
		if burstsLeft > 0: # shooting bursts
			burstTimer -= delta
			if burstTimer <= 0.0:
				if burstsLeft - 1 <= 0:
					burstsLeft = 0
					burstTimer = 0.0
					shootTimer = shootTime
					#print("Burst ended!")
				else:
					burstsLeft -= 1
					burstTimer = burstShootTime
					shoot()
					#print("Burst has " + str(burstsLeft) + " bursts left!")
					
		else: # doing nothing
			burstTimer = 0.0
			if shootReady:
				begin_burst()
	
	pass
	
func begin_burst(ignoreCurrentlyShooting : bool = false) -> void:
	var canFire : bool = emitter_can_fire()
	if not (ignoreCurrentlyShooting or canFire):
		return
		
	shootTimer = 0
	burstTimer = burstShootTime
	burstsLeft = burstCount
	burst_started.emit()
	#print("Burst started!")
	
	shoot()
	
func shoot() -> void:
	
	var startAngle : float = global_rotation_degrees + randf()*angleJitter
	var burstNumNormalized : float = float(burstsLeft - 1)/float(max(1, burstCount - 1))
	var burstAngle : float = lerp(burstAngleOffset.x, burstAngleOffset.y, burstAngleOffsetCurve.sample(burstNumNormalized))
	
	#if burstCount > 1:
		#print("%d/%d: %f" % [burstsLeft, burstCount, burstNumNormalized])
	
	for i in range(objectCount):
		var spreadAngle : float = lerp(-objectAngleSpread/2.0, objectAngleSpread/2.0, float(i)/max(objectCount - 1, 1)) + randf_range(-objectAngleSpreadJitter/2.0, objectAngleSpreadJitter/2.0)
		var shootAngle = startAngle + burstAngle + spreadAngle
		var shootOffset = positionOffset + Vector2(randf_range(-positionOffsetJitter.x/2.0, positionOffsetJitter.x/2.0), randf_range(-positionOffsetJitter.y/2.0, positionOffsetJitter.y/2.0))
		if positionOffsetRotated:
			shootOffset = shootOffset.rotated(deg_to_rad(shootAngle)) if positionOffsetFromCenter else shootOffset.rotated(global_rotation)
		
		var projectile = objectToSpawn.instantiate()
		if projectile is ShipController and get_parent() is ShipController:
			projectile.angle = shootAngle
			projectile.velocity = get_parent().velocity
			projectile.extraVelocity = get_parent().velocity
			get_parent().extraVelocity -= Vector2.from_angle(deg_to_rad(get_parent().angle)) * recoilSpeed
		if parentToRoot:
			#get_tree().root.get_children()[0].add_child(projectile)
			projectile.global_position = global_position + shootOffset
			projectile.global_rotation_degrees = shootAngle
			projectile.z_index += z_index
			get_tree().root.get_children()[0].call_deferred("add_child", projectile)
		else:
			#add_child(projectile)
			projectile.position = shootOffset
			projectile.rotation_degrees = shootAngle - startAngle
			get_parent().call_deferred("add_child", projectile)
			
	emitter_shot.emit()
	
	pass

func apply_settings(settings : EmitterSettings = emitterSettings) -> void:
	
	if settings == null:
		return
	elif settings != emitterSettings:
		settings_changed.emit(settings)
	
	# actually change settings 
	
	emitterSettings = settings
	
	objectToSpawn = settings.objectToSpawn
	parentToRoot = settings.parentToRoot
	inheritParentVelocity = settings.inheritParentVelocity
	alwaysFire = settings.alwaysFire

	angleJitter = settings.angleJitter
	objectCount = settings.objectCount
	objectAngleSpread = settings.objectAngleSpread
	objectAngleSpreadJitter = settings.objectAngleSpreadJitter
	burstCount = settings.burstCount
	burstAngleOffset = settings.burstAngleOffset
	burstAngleOffsetCurve = settings.burstAngleOffsetCurve
	burstShootTime = settings.burstShootTime
	
	positionOffset = settings.positionOffset
	positionOffsetJitter = settings.positionOffsetJitter
	positionOffsetRotated = settings.positionOffsetRotated
	positionOffsetFromCenter = settings.positionOffsetFromCenter
	
	shootTime = settings.shootTime
	recoilSpeed = settings.recoilSpeed
	
	pass

func emitter_can_fire() -> bool:
	return shootTimer <= 0 and burstTimer <= 0
