extends Node2D

# Object References

@export var playerShip : ShipController
@export var swarmManager : SwarmManager
@export var gameManager : GameManager

# Telemetry Variables

const playerVariablesToRecord : Array[String] = \
["angle", "linearVelocity", "angularVelocity", "linearAcceleration", "angularAcceleration", "extraVelocity", "linearAccelerationTimer", "angularAccelerationTimer"]
var playerVariableData : Array[Array] = []
var playerNameData : Array[String] = []
var playerHealthData : Array[float]
var waveTimes : Array[float]
var currentWaveTime : float

# File Variables

## Variable to check physics
var physicsTimer : Timer 
const physicsUpdateTime : float = 1.0
## Variable to keep track of filename
var filename : String = ""
## Variable to keep track of output file
var file: FileAccess

# Called when the node enters the scene tree for the first time.
func _ready():
	assert(playerShip != null and swarmManager != null and gameManager != null)
	
	gameManager.game_reset.connect(_on_restart)
	tree_exited.connect(on_quit)
	swarmManager.all_swarms_finished.connect(close_file)
	swarmManager.swarm_completed.connect(handle_new_wave)
	
	_on_restart()
	
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if swarmManager.swarmIndex < swarmManager.swarms.size():
		currentWaveTime += delta
	
	pass

func _on_restart() -> void:
	
	# file stuff
	
	create_new_file()
	
	# Timer stuff
	
	if physicsTimer == null:
		physicsTimer = Timer.new()
		physicsTimer.timeout.connect(append_variable_data)
		add_child(physicsTimer)
	physicsTimer.stop()
	physicsTimer.autostart = true
	physicsTimer.wait_time = physicsUpdateTime
	physicsTimer.one_shot = false
	physicsTimer.start()
	
	# array stuff
	playerVariableData.clear()
	for variable in playerVariablesToRecord:
		playerVariableData.push_back([])
	waveTimes.clear()
	currentWaveTime = 0.0

# Called when a new telemetry file is being created.
func create_new_file() -> void:
	
	# close file if it already exists
	close_file()
	
	# determine file name
	var datetime = Time.get_datetime_dict_from_system()
	var month = datetime.month
	var day = datetime.day
	var year = datetime.year % 100
	filename = "quasarquest_telemetry_" + "%02d"%month + "%02d"%day + "%02d"%year + "%02d"%datetime.hour + "%02d"%datetime.minute + "%02d"%datetime.second
	
	# create file
	var full_filename = "user://" + filename + ".csv"
	file = FileAccess.open(full_filename, FileAccess.WRITE)
	
	pass

# Called when a telemetry file is closed.
func close_file() -> void:
	
	# close file if it exists
	if (file != null):
		
		# write the NAMES of the variables here
		var strArray: Array[String] = [] # use for everything
		strArray.push_back("Player Name")
		for variable in playerVariablesToRecord:
			strArray.push_back(variable)
		strArray.push_back("Player Health %")
		strArray.push_back("Wave Times")
		file.store_csv_line(strArray) # store headers
		
		# store variables
		for index : int in range(playerVariableData[0].size()):
			strArray.clear()
			if index < playerNameData.size():
				strArray.push_back("%s" % [playerNameData[index]])
			for arrayIndex in range(playerVariableData.size()):
				if index < playerVariableData[arrayIndex].size():
					strArray.push_back(str(playerVariableData[arrayIndex][index]))
			if index < playerHealthData.size():
				strArray.push_back(("%.3f" % [playerHealthData[index]]))
				
			if index < waveTimes.size():
				strArray.push_back("%s: %.4f" % [swarmManager.swarms[index].name, waveTimes[index]])
			elif index == waveTimes.size():
				strArray.push_back("Total time: %.4f" % waveTimes.reduce(func(accum, number): return accum + number, 0))
			file.store_csv_line(strArray) # store data
		
		# actually close it
		file.close()
		
	# reset variables
	if physicsTimer != null:
		physicsTimer.stop()
	
	pass

# Called when the application quits
func on_quit() -> void:
	close_file()

func append_variable_data() -> void:
	playerNameData.push_back(playerShip.shipSettings.playerName)
	var index : int = 0
	for variable in playerVariablesToRecord:
		playerVariableData[index].push_back(playerShip.get(variable))
		index += 1
	playerHealthData.push_back(max(0.0, playerShip.health.currentHealth)/playerShip.health.maxHealth)

func handle_new_wave() -> void:
	waveTimes.push_back(currentWaveTime)
	currentWaveTime = 0.0
