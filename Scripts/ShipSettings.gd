class_name ShipSettings
extends Resource

enum ShipControlType {
	TANK,
	ASTEROIDS
}

@export_group("Physics Variables")
@export_subgroup("Velocity and Acceleration")
@export_range(0.0, 1000.0) var maximumLinearVelocity : float = 0.0
@export_range(0.0, 1000.0) var maximumAngularVelocity : float = 0.0
@export_range(0.0, 10000.0) var maximumLinearAcceleration : float = 0.0
@export_range(0.0, 10000.0) var maximumAngularAcceleration : float = 0.0
@export_range(0.0, 10000.0) var linearFriction : float = 0.0
@export_range(0.0, 10000.0) var angularFriction : float = 0.0
@export_range(0.0, 1.0) var turningSlowdownRatio : float = 0.0

@export_subgroup("Acceleration Curves")
@export_range(0.0, 10.0) var linearAccelerationTime : float = 1.0
@export var linearAccelerationCurve : Curve
@export_range(0.0, 10.0) var angularAccelerationTime : float = 1.0
@export var angularAccelerationCurve : Curve

@export_group("Miscellaneous")
@export var collisionShape : Shape2D
@export_range(1.0, 10000.0) var maxHealth : float
@export var controlType : ShipControlType
