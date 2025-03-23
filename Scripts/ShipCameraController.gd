extends Camera2D

@export var focus : ShipController
@export var cameraOffset : Vector2
@export var maxVelocityOffset : float
@export var offsetSpeed : float

var currentOffset : Vector2 = Vector2.ZERO

# Called when the node enters the scene tree for the first time.
func _ready():
	assert(focus != null)
	currentOffset = get_target_offset()
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	var targetOffset = get_target_offset()
	currentOffset = Vector2(move_toward(currentOffset.x, targetOffset.x, delta * offsetSpeed), move_toward(currentOffset.y, targetOffset.y, delta * offsetSpeed))
	
	global_position = focus.global_position + currentOffset
	
	pass

func get_target_offset() -> Vector2:
	var velOff = maxVelocityOffset*min(focus.velocity.length(), focus.maximumLinearVelocity)/focus.maximumLinearVelocity
	return cameraOffset + focus.velocity.normalized()*velOff
