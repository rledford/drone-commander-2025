extends Node


# player
signal player_dead
signal bullet_hit(bullet: Node, collision: KinematicCollision2D)
signal bullet_fired(position: Vector2, direction: Vector2, speed: float, damage: int)
signal bullet_expired(bullet: Node)

# scrap
signal scrap_dropped(position: Vector2)
signal scrap_collect_requested(by: Node, scrap: Node, amount: int)
signal scrap_collected(by: Node, scrap: Node, amount: int)
signal scrap_delivered(by: Node, to: Node, amount: int)
signal total_scrap_changed(old_scrap: int, new_scrap: int)

# crafting
signal drone_craft_requested(by: Node, cost: int)
signal drone_craft_request_rejected(to: Node, reason: String)
signal drone_craft_request_accepted(to: Node)
signal drone_craft_completed(by: Node, cost: int)

# control point
signal control_point_entered(by: Node)
signal control_point_exited(by: Node)
signal control_point_captured(by: Enums.Team)
signal control_point_lost(by: Enums.Team)
signal control_point_owner_changed(owner: Enums.Team)
