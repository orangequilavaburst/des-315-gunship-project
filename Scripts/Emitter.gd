class_name Emitter
extends Node2D

signal burst_started()
signal emitter_shot()
signal settings_changed(new_settings)

@export var emitterSettings : EmitterSettings

# basic stuff

var objectToSpawn : PackedScene
var parentToRoot : bool
var inheritParentVelocity : bool
var alwaysFire : bool

# angle shooting stuff

var angleJitter : float # 0-360
var objectCount : int # >0
var objectAngleSpread : float # 0-360
var objectAngleSpreadJitter : float # 0-(objectAngleSpread/objectCount)
var burstCount : int # >0
var burstAngleOffset : Vector2 # -180 - 180, basically goes from one angle to another
var burstAngleOffsetCurve : Curve
var burstShootTime : float # >=0.0

# timers

var shootTime : float # time between shots
var shootTimer : float # used to begin shooting
var burstTimer : float # used for the burst
var burstsLeft : int # used for the burst

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
	
	if shootTimer > 0.0:
		shootTimer -= delta
		if shootTimer <= 0.0:
			shootTimer = 0.0
			if alwaysFire:
				begin_burst()
	else:
		if burstTimer <= burstShootTime:
			burstTimer += delta
			if burstTimer >= burstShootTime:
				burstTimer = 0.0
				if burstsLeft >= 0:
					burstTimer = 0.0
					if burstsLeft == 0:
						if alwaysFire:
							shootTimer = shootTime
					else:
						burstsLeft -= 1
					shoot()
	
	pass
	
func begin_burst(ignoreCurrentlyShooting : bool = false) -> void:
	if not ignoreCurrentlyShooting and not (shootTimer == 0 and burstTimer == 0):
		return
		
	shootTimer = 0
	burstTimer = 0
	burstsLeft = burstCount
	burst_started.emit()
	
func shoot() -> void:
	
	var startAngle : float = global_rotation_degrees + randf()*angleJitter
	var burstNumNormalized : float = float(burstsLeft)/float(max(1.0, burstCount))
	var burstAngle : float = lerp(burstAngleOffset.x, burstAngleOffset.y, burstAngleOffsetCurve.sample(burstNumNormalized))
	
	for i in range(objectCount):
		var spreadAngle : float = lerp(-objectAngleSpread/2.0, objectAngleSpread/2.0, float(i)/max(objectCount - 1, 1)) + randf_range(-objectAngleSpreadJitter/2.0, objectAngleSpreadJitter/2.0)
		var shootAngle = startAngle + burstAngle + spreadAngle
		
		var projectile = objectToSpawn.instantiate()
		projectile.global_position = global_position
		projectile.angle = shootAngle
		if projectile is CharacterBody2D and get_parent() is CharacterBody2D:
			projectile.velocity = get_parent().velocity
			projectile.extraVelocity = get_parent().velocity
		if parentToRoot:
			get_tree().root.get_children()[0].add_child(projectile)
		else:
			add_child(projectile)
			
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
	
	shootTime = settings.shootTime
	
	pass
