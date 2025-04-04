class_name ContactDamage
extends Area2D

@export_range(0.01, 10000.0) var damageAmount : float = 1.0
@export_range(0.0, 10000.0) var selfDamage : float = 1.0
@export var health : Health

# Called when the node enters the scene tree for the first time.
func _ready():
	assert(health != null, "You need a health object to work with components!")
	monitoring = true # needs to be true so it can check anything that comes inside
	
	area_entered.connect(_area_entered)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# Called when another area enters
func _area_entered(other : Area2D) -> void:
	pass
