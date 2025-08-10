extends Node

signal player_dead
signal bullet_fired(team_id: String, position: Vector2, direction: Vector2, speed: float, damage: int)
signal bullet_expired(bullet: Node)
signal item_collected(by: Node, item_id: String, amount: int)
