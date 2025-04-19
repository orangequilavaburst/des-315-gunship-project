extends ShipInput

var autoplay : bool = true
const maxDistance : float = 100.0
const removeDistance : float = maxDistance * 2.0

@export var targetArea : Area2D
const checkTime : float = 5.0
var checkTimer = 0.0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	# kinda tired and don't want to do this with areas just yet
	# so just look for all player ships
	if targetType == TargetType.PLAYER:
		var ships : Array = get_tree().root.get_children()[0].get_children().filter(func(element): return (element is ShipController))
		for ship in ships:
			if ship.shipSettings is PlayerShipSettings:
				add_target(ship)
				break
	elif targetType == TargetType.ENEMY:
		for body in targetArea.get_overlapping_bodies():
			if body is ShipController:
				add_target(body)
				
	if targetArea != null:
		targetArea.area_entered.connect(_on_area_entered)
	checkTimer = 0.0
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	if not autoplay:
		input = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	else:
		
		checkTimer += delta
		if checkTimer >= checkTime and targets.size() > 0:
			clean_up_targets()
			checkTimer = 0.0
		
		var ip : Vector2 = Vector2.ZERO
		#turning
		if targets.size() > 0:
			var maxAngleDifference : float = min(30.0, (controller.maximumAngularVelocity*controller.maximumAngularVelocity / (2.0 * controller.angularFriction)) if controller.angularFriction > 0.0 else 1.0)
			var angleDifference = rad_to_deg(angle_difference(deg_to_rad(controller.angle), (targetPosition - get_parent().global_position).angle()))
			if abs(angleDifference) >= maxAngleDifference:
				ip.x = sign(angleDifference)
		#thrusting
			ip.y = 1 if targetPosition.distance_to(global_position) < maxDistance else -1
		#input
		input = ip
		pass

	if controller.health.healthState == Health.HealthState.ALIVE:
		if controller.mainWeaponEmitter != null:
			controller.mainWeaponEmitter.shootReady = Input.is_action_pressed("fire_main", false) if not autoplay else (true if targets.size() > 0 else false)
		if controller.subWeaponEmitter != null:	
			controller.subWeaponEmitter.shootReady = Input.is_action_pressed("fire_alt", false) if not autoplay else (true if targets.size() > 0 else false)
	
	pass

func _draw() -> void:
	draw_line(Vector2.ZERO, (targetPosition - controller.global_position).rotated(-controller.global_rotation), Color.RED)
	draw_line(Vector2.ZERO, Vector2.RIGHT*(targetPosition - controller.global_position).length(), Color.BLUE)
	draw_arc(Vector2.ZERO, (targetPosition - controller.global_position).length(), 0.0, angle_difference(controller.global_rotation, (targetPosition - controller.global_position).angle()), 10, Color.RED)


func _on_area_entered(other: Area2D) -> void:
	clean_up_targets()
	add_target(other)

func get_target_position() -> Vector2:
	if not (get_target() == null or get_target().is_queued_for_deletion()):
		var averagePosition : Vector2 = Vector2.ZERO
		var count : float = 0
		for target in targets:
			if not (target == null or target.is_queued_for_deletion()):
				if target.global_position.distance_to(global_position) <= maxDistance:
					averagePosition += target.global_position
					count += 1.0
		return averagePosition / count
	return super()
	
func clean_up_targets() -> void:
	super()
	var index : int = 0
	while index < targets.size():
		if targets[index].global_position.distance_to(global_position) >= removeDistance:
			targets.remove_at(index)
		else:
			index += 1
