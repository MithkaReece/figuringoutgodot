extends CharacterBody2D


const SPEED = 100.0

var shells = 0

func _ready() -> void:
	_update_shell_ui()
	pass # Replace with function body.



func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down"))
	direction = direction.normalized()

	if direction:
		velocity = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.y = move_toward(velocity.y, 0, SPEED)

	var collision = move_and_collide(velocity * delta)
	
	if collision:
		var other = collision.get_collider()
		
		if other is StaticBody2D and other.is_in_group("pickups"):
			shells+=1
			other.queue_free()
			_update_shell_ui()
			
func _update_shell_ui():
	var shell_label = get_node("/root/Main/CanvasLayer/ScoreLabel")
	if shell_label:
		shell_label.text = "Score:" + str(shells)
