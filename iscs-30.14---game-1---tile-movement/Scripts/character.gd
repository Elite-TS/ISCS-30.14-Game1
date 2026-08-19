extends CharacterBody2D

const tile_size: Vector2 = Vector2(16, 16)
var sprite_node_pos_tween: Tween

func _physics_process(delta: float) -> void:
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


func _move(dir: Vector2):
	global_position += dir * tile_size
	$AnimatedSprite2D.global_position -= dir * tile_size
	
	if sprite_node_pos_tween:
		sprite_node_pos_tween.kill()
	sprite_node_pos_tween = create_tween()
	sprite_node_pos_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	sprite_node_pos_tween.tween_property($AnimatedSprite2D, "global_position", global_position, 0.185).set_trans(Tween.TRANS_SINE)
	
