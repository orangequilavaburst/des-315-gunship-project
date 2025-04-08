extends ShipInput

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	super(delta)
	input = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	
	if controller.mainWeaponEmitter != null:
		controller.mainWeaponEmitter.shootReady = Input.is_action_pressed("fire_main", false)
	if controller.subWeaponEmitter != null:	
		controller.subWeaponEmitter.shootReady = Input.is_action_pressed("fire_alt", false)
	
	pass
