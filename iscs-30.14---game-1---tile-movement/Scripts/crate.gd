extends CharacterBody2D

const tile_size: Vector2 = Vector2(16, 16) # Specific size of a tile in pixels
var sprite_node_pos_tween: Tween
# These variables are the same as the one in character.gd

func _physics_process(_delta: float) -> void:
	# Code for the tile movement
	
	var player_collide_checker
	# This variable basically acts as a checker to see if the player is
	# next to the crate when inputs are pressed.
	

	# Basic gist of this is, if a movement input is pressed and the crate
	# isn't colliding with anything to the corresponding direction, it will
	# check to see if the player is present in the opposite side of the
	# input. If the player is there, the crate moves.
	if !sprite_node_pos_tween or !sprite_node_pos_tween.is_running():
		if Input.is_action_just_pressed("ui_up") and !$Up.is_colliding():
			player_collide_checker = $Down.get_collider()
			if player_collide_checker != null and player_collide_checker.is_in_group("char"):
				_move(Vector2(0,-1))
		elif Input.is_action_just_pressed("ui_down") and !$Down.is_colliding():
			player_collide_checker = $Up.get_collider()
			if player_collide_checker != null and player_collide_checker.is_in_group("char"):
				_move(Vector2(0,1))
		elif Input.is_action_just_pressed("ui_left") and !$Left.is_colliding():
			player_collide_checker = $Right.get_collider()
			if player_collide_checker != null and player_collide_checker.is_in_group("char"):
				_move(Vector2(-1,0))
		elif Input.is_action_just_pressed("ui_right") and !$Right.is_colliding():
			player_collide_checker = $Left.get_collider()
			if player_collide_checker != null and player_collide_checker.is_in_group("char"):
				_move(Vector2(1,0))
	

# This _move function is the same as the one in character.gd
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
