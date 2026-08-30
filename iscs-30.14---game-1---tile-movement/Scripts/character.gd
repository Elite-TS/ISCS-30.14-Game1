extends CharacterBody2D

const tile_size: Vector2 = Vector2(16, 16) # Specific size of a tile in pixels
var sprite_node_pos_tween: Tween
var last_direction: Vector2 = Vector2.UP
var current_direction: Vector2 = Vector2.UP
var lever_locations: Array[Vector2] = [
	Vector2(1559,24),Vector2(1287,-8),Vector2(1559,-40),Vector2(1303,-136)
	]

#REMOVE ONCE DONE TESTING
func _ready() -> void:
	global_position=Vector2(1207,88)
	
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
	
	if _is_on_warp():
		_on_warp()
		return
	
	if _is_on_chasm():
		_on_chasm()
		return
	
	if _is_on_lever()>0:
		get_node("AnimatedSprite2D/Camera2D/Label").visible = true
	else:
		get_node("AnimatedSprite2D/Camera2D/Label").visible = false
	
	print(str(global_position))
	
	# Each if-else does the movement + the animation
	if !sprite_node_pos_tween or !sprite_node_pos_tween.is_running():
		if Input.is_action_pressed("input_up"):
			last_direction = Vector2.UP
			if _can_move(Vector2.UP):
				$AnimatedSprite2D.play("walk_up")
				_move(Vector2(0,-1))
		elif Input.is_action_pressed("input_down"):
			last_direction = Vector2.DOWN
			if _can_move(Vector2.DOWN):
				$AnimatedSprite2D.play("walk_down")
				_move(Vector2(0,1))
		elif Input.is_action_pressed("input_left"):
			last_direction = Vector2.LEFT
			if _can_move(Vector2.LEFT):
				$AnimatedSprite2D.play("walk_left")
				_move(Vector2(-1,0))
		elif Input.is_action_pressed("input_right"):
			last_direction = Vector2.RIGHT
			if _can_move(Vector2.RIGHT):
				$AnimatedSprite2D.play("walk_right")
				_move(Vector2(1,0))
		elif Input.is_action_pressed("interact"):
			if _is_on_lever()>0:
				var lever = get_node_or_null("../Level/Lever"+str(_is_on_lever())) as TileMapLayer
				await Fade.fade(1,0.5).finished
				lever.enabled = false
				await Fade.fade(0,0.7).finished
		else:
			_play_idle()

# Calculates which idle animation to play
func _play_idle() -> void:
	if last_direction == Vector2.UP:
		$AnimatedSprite2D.play("idle_up")
	elif last_direction == Vector2.DOWN:
		$AnimatedSprite2D.play("idle_down")
	elif last_direction == Vector2.LEFT:
		$AnimatedSprite2D.play("idle_left")
	elif last_direction == Vector2.RIGHT:
		$AnimatedSprite2D.play("idle_right")

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
		
	var tile_data = get_tile_data(tile_map)
	
	if tile_data:
		#check if tile is an ice tile
		return tile_data.get_custom_data("is_ice") == true
		
	return false

#forces the characters to move towards the its last direction upon entering ice tile
func _on_ice_movement() -> void:
	if _can_move(last_direction):
		_move(last_direction)
	else:
		_play_idle()
		last_direction = Vector2.ZERO

func _is_on_conveyor():
	var tile_map = get_node_or_null("../Level/Ground") as TileMapLayer
	if not tile_map:
		print("Not conveyer")
		return false
		
	var tile_data = get_tile_data(tile_map)
	
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
			return not $Up.is_colliding()
		Vector2.DOWN:
			return not $Down.is_colliding()
		Vector2.LEFT:
			return not $Left.is_colliding()
		Vector2.RIGHT:
			return not $Right.is_colliding()
	return false

func _is_on_warp():
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
		#check if tile is a warp tile
		return tile_data.get_custom_data("is_warp") == true
		
	return false

# Warps to the next level
func _on_warp() -> void:
	var warp_distance = 16*28
	var right_vector = Vector2.RIGHT
	await Fade.fade(1,0.5).finished
	global_position=Vector2(1207,88)
	await Fade.fade(0,0.7).finished

func _is_on_chasm():
	#gets and checks for the tile map
	var ground = get_node_or_null("../Level/Ground") as TileMapLayer
	var lever1 = get_node_or_null("../Level/Lever1") as TileMapLayer
	var lever2 = get_node_or_null("../Level/Lever2") as TileMapLayer
	var lever3 = get_node_or_null("../Level/Lever3") as TileMapLayer
	var lever4 = get_node_or_null("../Level/Lever4") as TileMapLayer
	var tile_map
	var tile_data
	if lever1.enabled and get_tile_data(lever1)!=null:
		tile_data = get_tile_data(lever1)
	elif lever2.enabled and get_tile_data(lever2)!=null:
		tile_data = get_tile_data(lever2)
	elif lever3.enabled and get_tile_data(lever3)!=null:
		tile_data = get_tile_data(lever3)
	elif lever4.enabled and get_tile_data(lever4)!=null:
		tile_data = get_tile_data(lever4)
	elif get_tile_data(ground)!=null:
		tile_data = get_tile_data(ground)
	else:
		return false
		
	if tile_data:
		#check if tile is a chasm tile
		return tile_data.get_custom_data("is_chasm") == true
	print("NOT ON CHASM 2")
	return false

func _on_chasm():
	print("IS ON CHASM")
	await Fade.fade(1,0.5).finished
	global_position=Vector2(1207,88)
	var lever1 = get_node_or_null("../Level/Lever1") as TileMapLayer
	var lever2 = get_node_or_null("../Level/Lever2") as TileMapLayer
	var lever3 = get_node_or_null("../Level/Lever3") as TileMapLayer
	var lever4 = get_node_or_null("../Level/Lever4") as TileMapLayer
	lever1.enabled=true
	lever2.enabled=true
	lever3.enabled=true
	lever4.enabled=true
	#reset other tiles
	await Fade.fade(0,0.7).finished

func _is_on_lever():
	var loc_counter = 0
	for coordinate in lever_locations:
		loc_counter+=1
		if global_position.is_equal_approx(coordinate):
			print(loc_counter)
			return loc_counter
	print(0)
	return 0

func get_tile_data(tile_map):
	#converts global position to tile map local space
	var tile_map_position = tile_map.to_local(global_position)
	#converts pixel position to grid/tile structure
	var tile_coordinates = tile_map.local_to_map(tile_map_position)
	#gets tile data and checks if there is actually a tile
	return tile_map.get_cell_tile_data(tile_coordinates)
