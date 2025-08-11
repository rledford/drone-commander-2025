extends Node

# player
signal player_dead
signal bullet_hit(bullet: Node, collision: KinematicCollision2D)
signal bullet_fired(position: Vector2, direction: Vector2, speed: float, damage: int)
signal bullet_expired(bullet: Node)

# scrap
signal scrap_dropped(position: Vector2)
signal scrap_collected(by: Node, scrap: Node, amount: int)
signal total_scrap_changed(old_scrap: int, new_scrap: int)

# crafting
signal craft_drone_requested(by: Node, cost: int)
signal craft_drone_request_rejected(to: Node, reason: String)
signal craft_drone_request_accepted(to: Node)
signal craft_drone_completed(by: Node, cost: int)
