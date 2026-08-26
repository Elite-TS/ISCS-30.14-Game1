extends CharacterBody2D

const tile_size: Vector2 = Vector2(16, 16) # Specific size of a tile in pixels
var sprite_node_pos_tween: Tween
var last_direction: Vector2 = Vector2.UP
var current_direction: Vector2 = Vector2.UP

# Note for future coders: 
# The RayCast2D children of Character are used for impassible objects
# Once they collide with something in a certain direction, the player
# shouldn't move in that direction (I think).

func _physics_process(_delta: float) -> void:
	# Code for the tile movement
	
	# Ignore input while tweening between tiles
	if sprite_node_pos_tween and sprite_node_pos_tween.is_running():
		return

	# If standing on ice, automatically force a step in last_dir
	if _is_on_ice() and last_direction != Vector2.ZERO:
		_on_ice_movement()
		return
	
	if _is_on_conveyor():
		_on_conveyor_movement(current_direction)
		return
	
	# Each if-else does the movement + the animation
	if !sprite_node_pos_tween or !sprite_node_pos_tween.is_running():
		if Input.is_action_pressed("ui_up"):
			$AnimatedSprite2D.play("idle_up")
			if _can_move(Vector2.UP):
				$AnimatedSprite2D.play("walk_up")
				last_direction = Vector2.UP
				_move(Vector2(0,-1))
		elif Input.is_action_pressed("ui_down"):
			$AnimatedSprite2D.play("idle_down")
			if _can_move(Vector2.DOWN):
				$AnimatedSprite2D.play("walk_down")
				last_direction = Vector2.DOWN
				_move(Vector2(0,1))
		elif Input.is_action_pressed("ui_left"):
			$AnimatedSprite2D.play("idle_left")
			if _can_move(Vector2.LEFT):
				$AnimatedSprite2D.play("walk_left")
				last_direction = Vector2.LEFT
				_move(Vector2(-1,0))
		elif Input.is_action_pressed("ui_right"):
			$AnimatedSprite2D.play("idle_right")
			if _can_move(Vector2.RIGHT):
				$AnimatedSprite2D.play("walk_right")
				last_direction = Vector2.RIGHT
				_move(Vector2(1,0))

# The function used in the physics process
func _move(dir: Vector2) -> void:
	# Moves the object
	global_position += dir * tile_size
	$AnimatedSprite2D.global_position -= dir * tile_size
	
	# Makes the movement animation smooth
	if sprite_node_pos_tween:
		sprite_node_pos_tween.kill()
	sprite_node_pos_tween = create_tween()
	sprite_node_pos_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	sprite_node_pos_tween.tween_property($AnimatedSprite2D, "global_position", global_position, 0.185).set_trans(Tween.TRANS_SINE)

func _is_on_ice():
	#gets and checks for the tile map
	var tile_map = get_node_or_null("../Level/Ground") as TileMapLayer
	if not tile_map:
		return false
		
	#converts global position to tile map local space
	var tile_map_position = tile_map.to_local(global_position)
	#converts pixel position to grid/tile structure
	var tile_coordinates = tile_map.local_to_map(tile_map_position)
	#gets tile data and checks if there is actually a tile
	var tile_data = tile_map.get_cell_tile_data(tile_coordinates)
	
	if tile_data:
		#check if tile is an ice tile
		return tile_data.get_custom_data("is_ice") == true
		
	return false

#forces the characters to move towards the its last direction upon entering ice tile
func _on_ice_movement() -> void:
	if _can_move(last_direction):
		_move(last_direction)
	else:
		$AnimatedSprite2D.play("idle_down")
		last_direction = Vector2.ZERO

func _is_on_conveyor():
	var tile_map = get_node_or_null("../Level/Map Objects") as TileMapLayer
	if not tile_map:
		print("Not conveyer")
		return false
		
	#converts global position to tile map local space
	var tile_map_position = tile_map.to_local(global_position)
	#converts pixel position to grid/tile structure
	var tile_coordinates = tile_map.local_to_map(tile_map_position)
	#gets tile data and checks if there is actually a tile
	var tile_data = tile_map.get_cell_tile_data(tile_coordinates)
	
	if tile_data:
		#check if tile is an ice tile
		if tile_data.get_custom_data("is_up"):
			current_direction = Vector2.UP
		if tile_data.get_custom_data("is_down"):
			current_direction = Vector2.DOWN
		if tile_data.get_custom_data("is_left"):
			current_direction = Vector2.LEFT
		if tile_data.get_custom_data("is_right"):
			current_direction = Vector2.RIGHT
		return tile_data.get_custom_data("is_conveyor") == true
		
	return false

func _on_conveyor_movement(dir: Vector2) -> void:
	if dir == Vector2.UP:
		$AnimatedSprite2D.play("walk_up")
		last_direction = Vector2.UP
	elif dir == Vector2.DOWN:
		$AnimatedSprite2D.play("walk_down")
		last_direction = Vector2.DOWN
	elif dir == Vector2.LEFT:
		$AnimatedSprite2D.play("walk_left")
		last_direction = Vector2.LEFT
	elif dir == Vector2.RIGHT:
		$AnimatedSprite2D.play("walk_right")
		last_direction = Vector2.RIGHT
	
	if _can_move(dir):
		_move(dir)

#checks if character can move
func _can_move(dir: Vector2) -> bool:
	match dir:
		Vector2.UP: 
			print(not $Up.is_colliding())
			return not $Up.is_colliding()
		Vector2.DOWN: 
			print(not $Down.is_colliding())
			return not $Down.is_colliding()
		Vector2.LEFT: 
			print(not $Left.is_colliding())
			return not $Left.is_colliding()
		Vector2.RIGHT: 
			print(not $Right.is_colliding())
			return not $Right.is_colliding()
	return false
