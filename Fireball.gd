extends CharacterBody2D
@onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var range = 1.0
var speed = 10.0
var direction = Vector2(0,0)
var exploding = false
var lifetime = 100

func _ready():
	animated_sprite_2d.play("Default")
	
func SetRange(newRange: float):
	range = newRange
	lifetime = range / speed

func _physics_process(delta: float) -> void:
	lifetime -= delta
	
	if exploding:
		return
	velocity = direction * speed
	rotation = atan2(velocity.y, velocity.x) - PI*0.5
	var collision = move_and_collide(velocity * delta)
	
	if collision:
		var other = collision.get_collider()
		
		if other is CharacterBody2D and other.is_in_group("Creature"):
			cpu_particles_2d.emitting = false
			animated_sprite_2d.play("Explode")
			exploding = true
			other.Damage(15)
	elif lifetime <= 0:
			cpu_particles_2d.emitting = false
			animated_sprite_2d.play("Explode")
			exploding = true

func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()
