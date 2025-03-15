class_name Health
extends Node

signal health_changed(old_health, new_health)
signal health_state_changed(old_state, new_state)
signal health_hurt(damage, new_health)
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

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	currentIFrames = 0.0
	
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	match(healthState):
		HealthState.ALIVE:
			# update i-frames
			if currentIFrames > 0.0:
				currentIFrames -= delta
				if currentIFrames < 0.0:
					currentIFrames = 0.0
			pass
	
	pass

func hurt(damage : float) -> float:
	if (damage <= 0):
		return currentHealth
		
	currentHealth -= damage
	health_hurt.emit(damage, currentHealth)
	if currentHealth <= 0.0 and healthState == HealthState.ALIVE:
		death()
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
