extends Node


# player
signal player_dead
signal bullet_collided(with: Node, velocity: Vector2, damage: int)
signal bullet_fired(position: Vector2, direction: Vector2, speed: float, damage: int)
signal bullet_expired(bullet: Node)

# aoe
signal unit_healed(by: Node, target: Node, amoutn: int)

# drone
signal drone_created(by: Node, drone: Node)
signal drone_destroyed(by: Node, drone: Node)

# scrap
signal scrap_dropped(position: Vector2)
signal scrap_gathered(by: Node, scrap: Node)
signal scrap_pickup_requested(by: Node, scrap: Node, amount: int)

# control point
signal control_point_entered(by: Node)
signal control_point_exited(by: Node)
signal control_point_captured(by: Enums.Team)
signal control_point_lost(by: Enums.Team)
signal control_point_owner_changed(owner: Enums.Team)
