extends Node2D

@export var labelRef : Label
@export var timerRef : Timer

@export var textString : String
@export var popupTime : float

@export var initVelocityXRange : Vector2
@export var initVelocityYRange : Vector2
@export var initGravity : Vector2

var velocity : Vector2
var gravity : Vector2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	assert(labelRef != null and timerRef != null)
	
	labelRef.text = textString
	timerRef.wait_time = popupTime
	timerRef.start(popupTime)
	
	timerRef.timeout.connect(queue_free)
	
	velocity = Vector2(randf_range(initVelocityXRange.x, initVelocityXRange.y), randf_range(initVelocityYRange.x, initVelocityYRange.y))
	gravity = initGravity
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	velocity += gravity*delta
	position += velocity*delta
	
	pass
