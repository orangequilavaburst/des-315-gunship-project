extends Camera2D

@onready var gameManager : GameManager = get_tree().root.get_children()[0].get_children().filter(func(element): return (element is GameManager))[0]

@export var focus : ShipController
@export var cameraOffset : Vector2
@export var maxVelocityOffset : float
@export var offsetSpeed : float

@export var uiControl : CanvasLayer

@export var zoomRange : Vector2 = Vector2(0.5, 1.5)
@export var zoomSpeed : float = 0.5
@export var zoomInc : float = 0.05
var zoomAmount : float = 1.0
var zoomAmountCurrent : float

@export var screenArea : Area2D
@export var enemyLineColor : Color
var offscreenEnemies : Array[Node2D]

var enemyAveragePosition : Vector2 = Vector2.ZERO
var enemyPosOffset : Vector2 = Vector2.ZERO
@export var enemyOffsetSpeed : float = 20.0
@export var enemyOffsetAmount : float = 0.5

var currentPosition : Vector2 = Vector2.ZERO
var currentOffset : Vector2 = Vector2.ZERO

var cameraShakeIntensity : float
var cameraShakeTimer : float
var cameraShakeTime : float

# Called when the node enters the scene tree for the first time.
func _ready():
	if focus == null:
		return
	else:
		handle_new_focus()
		
	zoomAmount = 1.0
	zoomAmountCurrent = zoomAmount
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	zoomAmount = clamp(zoomAmount, zoomRange.x, zoomRange.y)
	zoomAmountCurrent = move_toward(zoomAmountCurrent, zoomAmount, zoomSpeed * delta)
	
	zoom = Vector2.ONE * zoomAmountCurrent
	
	var shakeVector = Vector2.from_angle(deg_to_rad(randf()*360.0))
	if cameraShakeTimer > 0.0:
		cameraShakeTimer -= delta
		if cameraShakeTimer < 0.0:
			cameraShakeTimer = 0.0
	
	if focus != null:
		
		currentPosition = focus.global_position
		
		var targetOffset = get_target_offset()
		currentOffset = Vector2(move_toward(currentOffset.x, targetOffset.x, delta * offsetSpeed * gameManager.deltaTimeMultiplier), move_toward(currentOffset.y, targetOffset.y, delta * offsetSpeed * gameManager.deltaTimeMultiplier))
		
		if (enemyAveragePosition + global_position) != Vector2.ZERO:
			enemyPosOffset = Vector2(move_toward(enemyPosOffset.x, enemyAveragePosition.x, delta * enemyOffsetSpeed * gameManager.deltaTimeMultiplier), move_toward(enemyPosOffset.y, enemyAveragePosition.y, delta * offsetSpeed * gameManager.deltaTimeMultiplier))
		else:
			enemyPosOffset = Vector2(move_toward(enemyPosOffset.x, 0.0, delta * enemyOffsetSpeed * gameManager.deltaTimeMultiplier), move_toward(enemyPosOffset.y, 0.0, delta * offsetSpeed * gameManager.deltaTimeMultiplier))
	
	global_position = currentPosition + currentOffset/zoom + shakeVector*get_shake_intensity()
	if (enemyAveragePosition + global_position) != Vector2.ZERO:
		global_position += enemyPosOffset * enemyOffsetAmount
	
	if uiControl != null:
		uiControl.follow_viewport_scale = 1.0 / zoomAmountCurrent
		#print(str(uiControl.scale) + ", " + str(uiControl.offset))
	
	pass
	
func _physics_process(delta: float) -> void:
	#if screenArea != null:
		#screenArea.angular_damp = screenArea.angular_damp
	enemyAveragePosition = enemy_screen_average() - global_position
	#update_nonoverlapping_bodies()
	#print(enemyAveragePosition)
	queue_redraw()
	
func _draw() -> void:
	#draw_circle(enemyAveragePosition, 4.0, Color.RED)
	'''
	for child in offscreenEnemies:
		var pos = child.global_position - global_position
		draw_circle(pos, 4.0, Color.RED)
	'''
	for enemy in gameManager.swarmManager.get_children():
		if enemy is ShipController and enemy.health.currentHealth > 0:
			draw_line(focus.global_position - global_position, enemy.global_position - global_position, enemyLineColor)
	pass
	
func _unhandled_input(event):
	var zoomButton : float = float(event.is_action_pressed("camera_scroll_up")) - float(event.is_action_pressed("camera_scroll_down"))
	zoomAmount += zoomButton*zoomInc

func handle_new_focus() -> void:
	currentPosition = focus.global_position
	currentOffset = get_target_offset()
	
	var hp : Health = focus.get_children().filter(func(element): return element is Health)[0]
	if hp != null:
		hp.health_hurt_noargs.connect(create_camera_shake.bind(2.0, 0.25))

func get_target_offset() -> Vector2:
	var velOff : float = maxVelocityOffset*min(focus.velocity.length(), focus.maximumLinearVelocity)/focus.maximumLinearVelocity
	var velangle : Vector2 = Vector2.from_angle(deg_to_rad(focus.angle)) if focus.shipSettings is PlayerShipSettings else focus.velocity
	return cameraOffset + velangle.normalized()*velOff

func create_camera_shake(intensity : float, time : float) -> bool:
	if intensity < get_shake_intensity() or time <= 0.0:
		return false
	
	cameraShakeIntensity = intensity
	cameraShakeTime = time
	cameraShakeTimer = cameraShakeTime
		
	return true

func get_shake_intensity() -> float:
	if cameraShakeTime <= 0.0:
		return 0.0
	return cameraShakeIntensity*(cameraShakeTimer/cameraShakeTime)
	
func update_nonoverlapping_bodies() -> void:
	offscreenEnemies.clear()
	for child in gameManager.swarmManager.get_children():
		if child is ShipController:
			if not (child.shipSettings is PlayerShipSettings) and child.health.maxHealth > 1.0:
				offscreenEnemies.push_back(child)
	offscreenEnemies.filter(func(x): return screenArea.get_overlapping_bodies().find(x) < 0)
	
func enemy_screen_average() -> Vector2:
	var retval : Vector2 = Vector2.ZERO
	var body_count : int = 0
	'''
	for body in screenArea.get_overlapping_bodies():
		if body is ShipController:
			#if not body.shipSettings is PlayerShipSettings:
			retval += body.global_position
			body_count += 1
	'''
	for child in gameManager.swarmManager.get_children():
		if child is ShipController:
			if not (child.shipSettings is PlayerShipSettings) and child.health.maxHealth > 1.0:
				retval += child.global_position
				body_count += 1
	retval *= 1.0/max(1.0, float(body_count))
	return retval
