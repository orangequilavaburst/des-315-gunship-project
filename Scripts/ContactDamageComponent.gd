class_name ContactDamage
extends Area2D

@export_range(0.0, 10000.0) var damageAmount : float = 1.0
@export var ignoreIFrames : bool = false
@export_range(0.0, 1000.0) var screenShakeAmount : float = 1.0
@export_range(0.0, 1000.0) var screenShakeTime : float = 0.2

@export_range(0.0, 10000.0) var selfDamage : float = 1.0
@export var health : Health

#var startupDelay : float = 0.05

# Called when the node enters the scene tree for the first time.
func _ready():
	assert(health != null, "You need a health object to work with components!")
	assert(get_parent() != null, "You need a parent!")
	
	collision_layer = get_parent().collision_layer
	collision_mask = get_parent().collision_mask #^ get_parent().collision_layer
	
	area_entered.connect(_on_area_entered)
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	#if startupDelay > 0:
		#startupDelay -= delta
	pass

func _on_area_entered(other: Area2D) -> void:
	#print_rich("[b]" + other.get_parent().name + "[/b] entered [b]" + get_parent().name + "'s[/b] hitbox!")
	#if startupDelay > 0:
		#return
		
	var hps = other.get_parent().get_children().filter(func(x): return x is Health)
	if hps.size() > 0:
		var hp : Health = hps[0]
		if hp.hurt(damageAmount, ignoreIFrames) > 0.0:
			health.hurt(selfDamage, false, false)
			get_parent().gameManager.camera.create_camera_shake(screenShakeAmount, screenShakeTime)
	pass # Replace with function body.
