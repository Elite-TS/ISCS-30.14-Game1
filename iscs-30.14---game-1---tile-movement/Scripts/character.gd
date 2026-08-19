extends CharacterBody2D

const tile_size: Vector2 = Vector2(16, 16) # Specific size of a tile in pixels
var sprite_node_pos_tween: Tween

# Note for future coders: 
# The RayCast2D children of Character are used for impassible objects
# Once they collide with something in a certain direction, the player
# shouldn't move in that direction (I think).

func _physics_process(_delta: float) -> void:
	# Code for the tile movement
	# Each if-else does the movement + the animation
	if !sprite_node_pos_tween or !sprite_node_pos_tween.is_running():
		if Input.is_action_pressed("ui_up") and !$Up.is_colliding():
			$AnimatedSprite2D.play("walk_up")
			_move(Vector2(0,-1))
		elif Input.is_action_pressed("ui_down") and !$Down.is_colliding():
			$AnimatedSprite2D.play("walk_down")
			_move(Vector2(0,1))
		elif Input.is_action_pressed("ui_left") and !$Left.is_colliding():
			$AnimatedSprite2D.play("walk_left")
			_move(Vector2(-1,0))
		elif Input.is_action_pressed("ui_right") and !$Right.is_colliding():
			$AnimatedSprite2D.play("walk_right")
			_move(Vector2(1,0))
		else:
			$AnimatedSprite2D.play("idle")

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
	
