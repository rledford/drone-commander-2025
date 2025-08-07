#### Phase 1: Project Setup and Core Structure

1. **Create New Godot Project**

   - Create new Godot 4.4+ project named "DroneCommander"
   - Set project settings: 2D renderer, window size 1280x960, pixel art import settings

2. **Create Main Scene Structure**

   - Create Main.tscn with Node2D as root
   - Add child nodes according to the established hierarchy:
	 - GameManager (Node)
	 - World (Node2D)
	 - UI (CanvasLayer)
   - Under World, add container nodes: Player, Drones, Enemies, ControlPoints, Scrap, Base
   - Save as Main.tscn and set as main scene

3. **Create Core Script Files**
   - Create GameManager.gd script attached to GameManager node
   - Create enums.gd autoload script for shared enums (DroneType, DroneState, Team, etc.)
   - Create event_bus.gd autoload script for global signals
   - Set up autoloads in project settings

#### Phase 2: Player System

4. **Create Player Character**

   - Create Player.tscn with CharacterBody2D root
   - Add CollisionShape2D with circular collision (radius 16)
   - Add ColorRect as visual (32x32 blue square)
   - Create player.gd script with WASD movement (100 pixels/second)
   - Implement mouse-look rotation
   - Add health system (100 HP) with damage/death handling

5. **Implement Player Combat**

   - Create Bullet.tscn with Area2D root, collision, and visual (small yellow circle)
   - Create bullet.gd script with movement, collision detection, and damage dealing
   - Add shooting mechanics to player.gd (mouse click, 2 shots/second, 25 damage)
   - Implement bullet pooling system in GameManager

6. **Player-World Interaction**
   - Add interaction system (E key detection)
   - Create base interaction zones for workbenches
   - Implement scrap collection on contact (Area2D detection)

#### Phase 3: Resource System

7. **Create Scrap System**

   - Create Scrap.tscn with Area2D root, collision, and visual (small yellow diamond)
   - Create scrap.gd script with collection behavior and lifetime management
   - Implement scrap spawning on enemy death (2-3 scrap per kill)
   - Add scrap pooling system to GameManager

8. **Resource Management**
   - Add scrap counter to GameManager with signals for updates
   - Implement scrap spending system for drone deployment (10 scrap per drone)
   - Create resource validation for drone creation

#### Phase 4: Base and Workbench System

9. **Create Player Base**

   - Create Base.tscn with StaticBody2D root and large visual representation
   - Position at center-bottom of map (640, 800)
   - Add scrap drop-off area (Area2D) for gather drones
   - Implement base health system if needed for future enemy attacks

10. **Implement Workbench System**
	- Create Workbench.tscn with Area2D root for interaction detection
	- Create workbench.gd script with drone type assignment and interaction handling
	- Place 3 workbenches around base (positions: left, center, right)
	- Connect workbench interactions to drone deployment system
	- Add visual indicators for workbench types (different colored rectangles)

#### Phase 5: Drone System Foundation

11. **Create Base Drone Class**

	- Create BaseDrone.tscn with CharacterBody2D root, collision, and basic visual
	- Create base_drone.gd script with common drone functionality:
	  - Health system, movement, team identification
	  - State machine (FOLLOWING_PLAYER, DEFENDING_POINT, GATHERING_SCRAP, RETURNING_HOME, ENGAGING_ENEMY)
	  - Target acquisition and basic AI behaviors

12. **Implement Drone Slot Management**
	- Add drone slot tracking to GameManager (arrays for each drone type)
	- Implement slot assignment/removal logic
	- Create overflow handling (excess drones patrol base)
	- Add control point buff system for extra slots

#### Phase 6: Specific Drone Types

13. **Create Damage Drone**

	- Create Damage Drone.tscn inheriting from BaseDrone
	- Set visual (blue triangle), stats (80 speed, 75 HP), and collision
	- Create damage_drone.gd script extending base_drone.gd
	- Implement combat behavior (1.5 shots/second, 20 damage, target enemies)
	- Add patrol and follow behaviors

14. **Create Gather Drone**

	- Create GatherDrone.tscn inheriting from BaseDrone
	- Set visual (blue circle), stats (150 speed, 200 HP), and collision
	- Create gather_drone.gd script with scrap-seeking behavior
	- Implement scrap capacity system (3 scrap max)
	- Add vacuum collection area (Area2D with larger radius)
	- Implement pathfinding to drop-off points (player, base, controlled points)

15. **Create Support Drone**
	- Create SupportDrone.tscn inheriting from BaseDrone
	- Set visual (blue cross/plus), stats (90 speed, 100 HP), and collision
	- Create support_drone.gd script with healing behavior
	- Implement area healing (15 HP every 3 seconds, 64-pixel radius)
	- Add follow and positioning logic

#### Phase 7: Enemy System

16. **Create Enemy AI**

	- Create Enemy.tscn with CharacterBody2D root, collision, and visual (red square)
	- Create enemy.gd script with basic AI (70 speed, 50 HP, 30 damage, 1 attack/second)
	- Implement target selection (nearest player/drone/control point)
	- Add melee attack behavior (32-pixel range)

17. **Enemy Spawning System**
	- Add enemy spawn points to GameManager (3 locations at map edges)
	- Implement wave spawning (45-60 second intervals, 3-5 enemies per wave)
	- Add enemy pooling system
	- Implement wave scaling over time

#### Phase 8: Control Point System

18. **Create Control Points**

	- Create ControlPoint.tscn with Area2D root for capture detection
	- Create control_point.gd script with capture mechanics
	- Add visual indicators (colored circles with progress bars)
	- Position 3 control points in triangular formation on map

19. **Control Point Mechanics**
	- Implement presence detection (player/drones vs enemies)
	- Add capture progress system (10 seconds uncontested)
	- Create ownership change handling with visual updates
	- Implement unique buffs per control point (+1 drone slots)

#### Phase 9: UI System

20. **Create Game UI**

	- Create GameUI.tscn with Control root under UI CanvasLayer
	- Add resource display (scrap counter)
	- Create drone count displays (current/max for each type)
	- Add control point status indicators
	- Implement enemy wave countdown timer

21. **UI Functionality**
	- Connect UI elements to GameManager signals
	- Implement real-time updates for all displayed values
	- Add interaction prompts (workbench availability, etc.)
	- Create simple health bar for player

#### Phase 10: Game Flow and Polish

22. **Implement Game States**

	- Add game state management (playing, paused, game over)
	- Create basic game over conditions (player death, base destruction)
	- Implement pause functionality

23. **Audio and Feedback**

	- Add basic sound effects for shooting, collection, deployment
	- Implement visual feedback for interactions and state changes
	- Add screen shake for impacts

24. **Testing and Balance**
	- Test all drone behaviors and interactions
	- Verify resource flow and scrap economy
	- Test control point capture mechanics
	- Adjust balance values based on gameplay feel

#### Phase 11: Final Integration

25. **System Integration Testing**

	- Test complete gameplay loop from start to sustained play
	- Verify all systems work together (drones, resources, combat, control points)
	- Test edge cases (all drones destroyed, no scrap available, etc.)

26. **Performance Optimization**

	- Implement object pooling for all frequently spawned objects
	- Optimize update loops and collision detection
	- Test with maximum expected entity counts

27. **Final Polish**
	- Add basic particle effects for combat and collection
	- Implement camera follow system for player
	- Add visual polish to UI elements
	- Create simple instruction screen or tutorial prompts
