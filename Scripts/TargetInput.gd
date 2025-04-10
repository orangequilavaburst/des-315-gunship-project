extends ShipInput

@export var alwaysMoveForward : bool = true
@export var targetArea : Area2D

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
				
	if targetArea != null:
		targetArea.area_entered.connect(_on_area_entered)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	
	if canMove:
		input = Vector2(0.0, -1.0 if alwaysMoveForward else 0.0)
		
		if targets.size() > 0 or targetType == TargetType.MOUSE:
			var maxAngleDifference : float = min(90.0, (controller.maximumAngularVelocity*controller.maximumAngularVelocity / (2.0 * controller.angularFriction)) if controller.angularFriction > 0.0 else 1.0)
			var angleDifference = rad_to_deg(angle_difference(deg_to_rad(controller.angle), (targetPosition - get_parent().global_position).angle()))
			if abs(angleDifference) >= maxAngleDifference:
				input = Vector2(sign(angleDifference), -1.0 if alwaysMoveForward or abs(angleDifference) < 90.0 else \
						(1.0 if controller.velocity.length() >= ((controller.maximumLinearVelocity*controller.maximumLinearVelocity / (2.0 * controller.linearFriction)) if controller.angularFriction > 0.0 else 0.0) else 0.0))
	else:
		input = Vector2.ZERO

func _on_area_entered(other: Area2D) -> void:
	add_target(other)
