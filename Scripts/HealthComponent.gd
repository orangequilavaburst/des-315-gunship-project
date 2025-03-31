class_name Health
extends Node2D

@onready var gameManager : GameManager = get_tree().root.get_children()[0].get_children().filter(func(element): return (element is GameManager))[0]

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

@export var healthState : HealthState = HealthState.ALIVE
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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	assert(get_parent() != null) # needs to be attached to something!
	currentIFrames = 0.0
	
	regenTimer = 0.0
	
	# shader stuff
	get_parent().set_material(colorShader)
	get_parent().material.set_shader_parameter("swapColorEnabled", false)
	hurtColorIndex = 0
	hurtColorTimer = 0.0
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	hurtColorTimer = fposmod(hurtColorTimer + delta, hurtColorChangeTime)
	
	match(healthState):
		HealthState.ALIVE:
			# update i-frames and play animation
			if currentIFrames > 0.0:
				
				if (fposmod(hurtColorTimer + hurtColorChangeTime - delta, hurtColorChangeTime) > fposmod(hurtColorTimer + hurtColorChangeTime, hurtColorChangeTime)):
					hurtColorIndex = posmod(hurtColorIndex + 1, hurtColors.size())
				
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
	
	pass

func hurt(damage : float, ignoreIFrames : bool = false) -> float:
	if (damage <= 0) or (not ignoreIFrames and currentIFrames > 0.0):
		return currentHealth
		
	currentHealth -= damage
	if healthState == HealthState.ALIVE:
		if currentHealth <= 0.0:
			death()
		else:
			currentIFrames = maxIFrames
	
	health_hurt.emit(damage, currentHealth)
	health_hurt_noargs.emit()
			
	return currentHealth
	
func heal(amount : float) -> float:
	if (amount <= 0):
		return currentHealth
		
	currentHealth += amount
	health_recovered.emit(amount, currentHealth)
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
	health_death.emit()
	get_parent().queue_free()

# debug
'''
func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		if event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
			hurt(5.0)
'''
