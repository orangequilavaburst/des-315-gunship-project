class_name ShipController
extends CharacterBody2D

@export_group("Physics Variables")
@export_subgroup("Velocity and Acceleration")
var linearVelocity : float = 0.0
var angularVelocity : float = 0.0
var linearAcceleration : float = 0.0
var angularAcceleration : float = 0.0

@export_range(0.0, 1000.0) var maximumLinearVelocity : float = 0.0
@export_range(0.0, 1000.0) var maximumAngularVelocity : float = 0.0
@export_range(0.0, 1000.0) var maximumLinearAcceleration : float = 0.0
@export_range(0.0, 1000.0) var maximumAngularAcceleration : float = 0.0
@export_range(0.0, 1.0) var turningSlowdownRatio : float = 0.0 # 0.0 = don't slow down at all, 1.0 = stop to turn

@export_subgroup("Jerk")

var linearJerk : float = 0.0 # set in code
var angularJerk : float = 0.0 # set in code

var jerkLinearAccelerateTimer : float = 0.0
var jerkLinearDeccelerateTimer : float = 0.0
var jerkAngularAccelerateTimer : float = 0.0
var jerkAngularDeccelerateTimer : float = 0.0

@export_range(0.0, 10.0) var jerkLinearAccelerateTime : float = 1.0
@export var jerkLinearAccelerateCurve : Curve
@export_range(0.0, 10.0) var jerkLinearDeccelerateTime : float = 1.0
@export var jerkLinearDeccelerateCurve : Curve
@export_range(0.0, 10.0) var jerkAngularAccelerateTime : float = 1.0
@export var jerkAngularAccelerateCurve : Curve
@export_range(0.0, 10.0) var jerkAngularDeccelerateTime : float = 1.0
@export var jerkAngularDeccelerateCurve : Curve

@export_group("Object References")


func _ready() -> void:
	pass

func _physics_process(delta: float) -> void:
	move_and_slide()
