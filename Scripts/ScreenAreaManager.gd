extends Area2D

const FLAG_NONE = 1 << 0
const FLAG_PLAYER = 1 << 1
const FLAG_ENEMY = 1 << 2
const FLAG_PLAYER_PROJECTILE = 1 << 3
const FLAG_ENEMY_PROJECTILE = 1 << 4

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	monitoring = true
	body_exited.connect(_on_body_exited)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _on_body_exited(other : Node2D) -> void:
	if other.get_parent() is ShipController:
		if flag_is_enabled(other.collision_layer, FLAG_PLAYER_PROJECTILE) or flag_is_enabled(other.collision_layer, FLAG_ENEMY_PROJECTILE):
			print_rich("[b]" + name + "[/b] cleaned up [i]" + other.get_parent().name + "[/i]")
			other.get_parent().call_deferred("queue_free")
	pass

static func flag_is_enabled(b, flag):
		return b & flag != 0

static func set_flag(b, flag):
		b = b|flag
		return b

static func unset_flag(b, flag):
		b = b & ~flag
		return b
