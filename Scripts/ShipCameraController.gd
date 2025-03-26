extends Camera2D

@onready var gameManager : GameManager = get_tree().root.get_children()[0].get_children().filter(func(element): return (element is GameManager))[0]

@export var focus : ShipController
@export var cameraOffset : Vector2
@export var maxVelocityOffset : float
@export var offsetSpeed : float

var currentOffset : Vector2 = Vector2.ZERO

var cameraShakeIntensity : float
var cameraShakeTimer : float
var cameraShakeTime : float

# Called when the node enters the scene tree for the first time.
func _ready():
	assert(focus != null)
	currentOffset = get_target_offset()
	
	var hp : Health = focus.get_children().filter(func(element): return element is Health)[0]
	if hp != null:
		hp.health_hurt_noargs.connect(create_camera_shake.bind(2.0, 0.25))
		
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	var targetOffset = get_target_offset()
	currentOffset = Vector2(move_toward(currentOffset.x, targetOffset.x, delta * offsetSpeed * gameManager.deltaTimeMultiplier), move_toward(currentOffset.y, targetOffset.y, delta * offsetSpeed * gameManager.deltaTimeMultiplier))
	
	var shakeVector = Vector2.from_angle(deg_to_rad(randf()*360.0))
	if cameraShakeTimer > 0.0:
		cameraShakeTimer -= delta
		if cameraShakeTimer < 0.0:
			cameraShakeTimer = 0.0
	
	global_position = focus.global_position + currentOffset + shakeVector*get_shake_intensity()
	
	pass

func get_target_offset() -> Vector2:
	var velOff = maxVelocityOffset*min(focus.velocity.length(), focus.maximumLinearVelocity)/focus.maximumLinearVelocity
	return cameraOffset + focus.velocity.normalized()*velOff

func create_camera_shake(intensity : float, time : float) -> bool:
	if intensity < get_shake_intensity():
		return false
	
	cameraShakeIntensity = intensity
	cameraShakeTime = time
	cameraShakeTimer = cameraShakeTime
		
	return true

func get_shake_intensity() -> float:
	if cameraShakeTime <= 0.0:
		return 0.0
	return cameraShakeIntensity*(cameraShakeTimer/cameraShakeTime)
