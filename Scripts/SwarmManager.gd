class_name SwarmManager
extends Node2D

signal swarm_started()
signal swarm_completed()

@export var swarms : Array[SwarmGroupResource]

var swarmIndex : int = 0
var swarmTimer : Timer

@export var doubleCheckTime : float = 2.0
var doubleCheckTimer : Timer
var doubleChecked : bool = false

# Called when the node enters the scene tree for the first time.
func _ready():
	
	var print_text : String = "[i]" + name + "[/i]'s list of swarms: "
	var swarm_names : Array[String]
	var i : int = 0
	for swarm in swarms:
		print_text += "%s" + (", " if i < swarms.size() - 1 else " ")
		swarm_names.push_back(swarm.name)
		i += 1
	print_rich(print_text % swarm_names)
	
	# make sure this is always at 0 since it's going to parent all the objects to keep track of them
	global_position = Vector2.ZERO
	
	# initial values
	swarmIndex = 0
	
	doubleChecked = false
	doubleCheckTimer = Timer.new()
	add_child(doubleCheckTimer)
	doubleCheckTimer.autostart = false
	doubleCheckTimer.wait_time = doubleCheckTime
	doubleCheckTimer.one_shot = true
	doubleCheckTimer.timeout.connect(check_clear)
	
	swarmTimer = Timer.new()
	add_child(swarmTimer)
	swarmTimer.autostart = false
	swarmTimer.one_shot = true
	swarmTimer.timeout.connect(spawn_swarm)
	swarmTimer.start(swarms[swarmIndex].delay)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func get_viewport_center() -> Vector2:
	var transform : Transform2D = get_viewport_transform()
	var scale : Vector2 = transform.get_scale()
	return -transform.origin / scale + get_viewport_rect().size / scale / 2.0

func spawn_swarm() -> void:
	spawn_swarm_at_index(swarmIndex)
	
func spawn_swarm_at_index(index : int) -> void:
	print_rich("[b]Wave %d[/b] ([i]%s[/i]) begin!" % [index + 1, swarms[index].name])
	
	var center : Vector2 = get_viewport_center() + get_viewport_rect().size/2.0
	for enemy in swarms[index].enemies:
		var new_angle : float = randf() * 360.0
		var new_offset : Vector2 = Vector2.from_angle(deg_to_rad(new_angle + 180.0)) * get_viewport_rect().size.x
		var new_enemy = enemy.instantiate()
		if new_enemy is ShipController:
			new_enemy.global_position = center + new_offset
			new_enemy.global_rotation_degrees = new_angle
			new_enemy.angle = new_angle
			new_enemy.health.health_death.connect(check_clear.bind(true))
			call_deferred("add_child", new_enemy)
	
	swarm_started.emit()

func check_clear(override_double_check : bool = false) -> bool:
	#print("check_clear called with override_double_check as " + ("true" if override_double_check else "false"))
	if override_double_check:
		doubleChecked = false
	
	if get_child_count() <= 2: # because of the timers
		complete_wave()
		return true
	if not doubleChecked:
		doubleChecked = true
		doubleCheckTimer.start(doubleCheckTime)
	return false

func complete_wave() -> void:
	doubleChecked = false
	print_rich("[b]Wave %d[/b] complete!" % [swarmIndex + 1])
	swarmIndex += 1
	swarm_completed.emit()
	
	if swarmIndex < swarms.size():
		swarmTimer.start(swarms[swarmIndex].delay)
