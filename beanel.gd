extends CharacterBody2D

@export var speed: float = 100.0 
@export var movement_radius: float = 200.0
@export var min_wait_time: float = 1.0 
@export var max_wait_time: float = 4.0 


var target_position: Vector2 = Vector2()
var is_moving: bool = false  
var wait_timer: float = 0.0 

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pick_random_point()


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if is_moving:
		move_towards_target(delta)
	else:
		wait_timer -= delta
		if wait_timer <= 0:
			pick_random_point()


func pick_random_point():
	var random_offset = Vector2(randf_range(-movement_radius, movement_radius), randf_range(-movement_radius, movement_radius))
	target_position = position + random_offset
	is_moving = true

func move_towards_target(delta):
	var dir = (target_position - position).normalized()

	var velocity = dir * speed * delta
	
	move_and_collide(velocity)
	
	if position.distance_to(target_position) < 10:
		is_moving = false
		wait_timer = randf_range(min_wait_time, max_wait_time)
		velocity = Vector2()
	
