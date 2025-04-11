class_name Health
extends Node2D

@onready var gameManager : GameManager = get_tree().root.get_children()[0].get_children().filter(func(element): return (element is GameManager))[0]
@onready var textPopup : PackedScene = load("res://Scenes/VFX/text_popup.tscn")

signal health_changed(old_health, new_health)
signal health_state_changed(old_state, new_state)
signal health_hurt(damage, new_health)
signal health_hurt_noargs()
signal health_recovered(amount, new_health)
signal health_death()

enum HealthState{
	ALIVE,
	DYING,
	DEAD
}

enum DyingTypes {
	INSTANT,
	QUICK,
	CINEMATIC,
	PLAYER
}

@export var healthState : HealthState = HealthState.ALIVE
@export var dyingType : DyingTypes = DyingTypes.INSTANT
@export_range(1.0, 10000.0) var maxHealth : float = 10.0
@export_range(1.0, 10000.0) var currentHealth : float = maxHealth:
	set(value):
		health_changed.emit(currentHealth, min(maxHealth, value))
		currentHealth = clamp(value, 0.0, maxHealth)

@export_range(0.0, 10.0) var maxIFrames : float = 0.25
var currentIFrames : float = 0.0

# regeneration stuff
@export_range(0.0, 1.0) var regenThreshold : float = 0.0
@export_range(0.0, 10.0) var regenTime : float = 0.0
@export_range(0.0, 10000.0) var regenPotency : float = 0.0
var regenTimer : float = 0.0

# for color stuff
const colorShader : ShaderMaterial = preload("res://Shaders/SolidColorShaderMaterial.tres")
@export var hurtColors : Array[Color] = [Color.BLACK, Color(216.0/255.0, 40.0/255.0, 0.0), Color(240.0/255.0, 183.0/255.0, 56.0/255.0), Color.WHITE ]
@export var hurtColorChangeTime : float = 0.05
var hurtColorIndex : int = 0
var hurtColorTimer : float = 0.0
var useHurtColor : bool = true

@export var createPopups : bool = true

# emitters
@export var hurtEmitters : Array[Emitter] = []
@export var healEmitters : Array[Emitter] = []
@export var deathEmitters : Array[Emitter] = []

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(get_parent() != null) # needs to be attached to something!
	currentIFrames = 0.0
	
	regenTimer = 0.0
	
	# shader stuff
	get_parent().set_material(colorShader.duplicate(true))
	get_parent().material.set_shader_parameter("swapColorEnabled", false)
	hurtColorIndex = 0
	hurtColorTimer = 0.0
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if get_parent().is_queued_for_deletion():
		print("I should be dead!")
		return
	
	hurtColorTimer = fposmod(hurtColorTimer + delta, hurtColorChangeTime)
	
	match(healthState):
		HealthState.ALIVE:
			# update i-frames and play animation
			if currentIFrames > 0.0:
				
				if useHurtColor:
					if (fposmod(hurtColorTimer + hurtColorChangeTime - delta, hurtColorChangeTime) > fposmod(hurtColorTimer + hurtColorChangeTime, hurtColorChangeTime)):
						hurtColorIndex = posmod(hurtColorIndex + 1, hurtColors.size())
				else:
					hurtColorIndex = 0
				
				if not get_parent().material.get_shader_parameter("swapColorEnabled"):
					get_parent().material.set_shader_parameter("swapColorEnabled", true)
				get_parent().material.set_shader_parameter("swapColorMain", hurtColors[hurtColorIndex])
				get_parent().material.set_shader_parameter("swapColorAlt", hurtColors[posmod(hurtColorIndex + 1, hurtColors.size())])
				
				currentIFrames -= delta*gameManager.deltaTimeMultiplier
				if currentIFrames < 0.0:
					currentIFrames = 0.0
					hurtColorIndex = 0
					get_parent().material.set_shader_parameter("swapColorEnabled", false)
			
			if currentHealth <= maxHealth*regenThreshold:
				regenTimer += delta
				if regenTimer >= regenTime:
					heal(regenPotency)
					regenTimer = 0.0
			else:
				regenTimer = 0.0
			pass
		
		HealthState.DYING:
			match(dyingType):
				_:
					healthState = HealthState.DEAD
					pass
			pass
		HealthState.DEAD:
			if dyingType != DyingTypes.PLAYER:
				#get_parent().queue_free()
				get_parent().call_deferred("queue_free")
			pass
	
	pass


func hurt(damage : float, ignoreIFrames : bool = false, useShader : bool = true) -> float:
	if (damage <= 0) or (not ignoreIFrames and currentIFrames > 0.0):
		return currentHealth
		
	currentHealth -= damage	
	if createPopups:
		#print_rich("[b]" + get_parent().name + "[/b]'s health is now " + str(currentHealth) + "!")
		pass
		
	health_hurt.emit(damage, currentHealth)
	health_hurt_noargs.emit()
	
	if healthState == HealthState.ALIVE:
		if currentHealth <= 0.0:
			death()
			useHurtColor = true
			if createPopups:
				create_popup("DEFEAT!")
		else:
			currentIFrames = maxIFrames
			useHurtColor = useShader
			
			for emitter in hurtEmitters:
				emitter.begin_burst()
				#print_rich("[b]" + get_parent().name + "[/b]'s [i]" + emitter.name + "[/i] fired on hurt!")
	
	if createPopups:
		create_popup("%.1d" % [-damage])
			
	return currentHealth
	
func create_popup(text : String) -> void:
	var popup : Node2D = textPopup.instantiate()
	popup.textString = text
	popup.global_position = get_parent().global_position
	get_tree().root.get_children()[0].add_child(popup)

func heal(amount : float) -> float:
	if (amount <= 0):
		return currentHealth
		
	currentHealth += amount
	health_recovered.emit(amount, currentHealth)
	for emitter in healEmitters:
		emitter.begin_burst()
	return currentHealth
		
func instakill() -> void:
	hurt(currentHealth)
	
func instaheal() -> void:
	heal(maxHealth - currentHealth)
	
func set_max_health(new_max : float, do_instaheal : bool = true):
	maxHealth = new_max
	if do_instaheal:
		instaheal()

func death() -> void:
	for emitter in deathEmitters:
		emitter.begin_burst()
		#print_rich("[b]" + get_parent().name + "[/b]'s [i]" + emitter.name + "[/i] fired on death!")
	
	if get_parent() is ShipController:
		gameManager.camera.create_camera_shake(get_parent().explosionMagnitude, get_parent().explosionTime)
	
	health_death.emit()
	healthState = HealthState.DYING
	
	for ship in get_tree().root.get_children()[0].get_children():
		if ship is ShipController:
			if self in ship.shipInput.targets:
				ship.shipInput.remove_target(self)

# debug
'''
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			hurt(5.0)
'''
