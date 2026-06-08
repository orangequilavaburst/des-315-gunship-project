class_name ShipInput
extends Node2D

var doDebugDraw : bool = false

enum TargetType {
	NONE,
	PLAYER, # target the player
	ENEMY, # target enemy types
	MOUSE # target the mouse
}
@export var targetType : TargetType = TargetType.NONE
@export var canMove : bool = true

var input : Vector2 = Vector2.ZERO
var targets : Array[Node2D] = []
var targetPosition : Vector2 = Vector2.ZERO

@onready var controller : ShipController = get_parent() as ShipController

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(controller != null, "There's no parent to this ship input!")
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	targetPosition = get_target_position()
	queue_redraw()
	pass
	
func clean_up_targets() -> void:
	var index : int = 0
	while index < targets.size():
		if targets[index] == null:
			targets.remove_at(index)
		else:
			index += 1
	
func _draw() -> void:
	if targetType != TargetType.NONE and doDebugDraw:
		draw_line(Vector2.ZERO, (targetPosition - controller.global_position).rotated(-controller.global_rotation), Color.RED)
		draw_line(Vector2.ZERO, Vector2.RIGHT*(targetPosition - controller.global_position).length(), Color.BLUE)
		draw_arc(Vector2.ZERO, (targetPosition - controller.global_position).length(), 0.0, angle_difference(controller.global_rotation, (targetPosition - controller.global_position).angle()), 10, Color.RED)

func add_target(new_target : Node2D) -> void:
	if targets.find(new_target) < 0:
		targets.push_back(new_target)
		
func remove_target(new_target : Node2D) -> void:
	var index : int = targets.find(new_target)
	if index >= 0:
		targets.remove_at(index)

func get_target() -> Node2D:
	if targets.size() <= 0:
		return null
	clean_up_targets()
	targets.filter(func(a): return a != null and not a.is_queued_for_deletion())
	if targets.size() > 1:
		clean_up_targets()
		targets.sort_custom(func(a : Node2D, b : Node2D): (a.global_position - controller.global_position).length() < (b.global_position - controller.global_position).length())
	if targets.size() >= 1:
		return targets[0]
	return null

func get_target_position() -> Vector2:
	if targetType == TargetType.MOUSE:
		return get_global_mouse_position()
	elif get_parent() == null or controller == null or controller.is_queued_for_deletion():
		return Vector2.ZERO
	elif (targets.size() <= 0 or targets[0] == null):
		return controller.global_position + controller.velocity
	elif get_target() == null or get_target().is_queued_for_deletion():
		return controller.global_position
	return get_target().global_position
