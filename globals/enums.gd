extends Node

const DRONE_STATE_IDLE: StringName = &"idle"
const DRONE_STATE_PATROL: StringName = &"parol"

enum DroneType {
	NONE,
	DAMAGE,
	GATHER,
	SUPPORT,
}


enum Team {
	PLAYER,
	ENEMY,
}
