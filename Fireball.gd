extends CharacterBody2D
@onready var cpu_particles_2d: CPUParticles2D = $CPUParticles2D
@onready var animated_sprite_2d: AnimatedSprite2D = $AnimatedSprite2D

var speed = 10
var direction = Vector2(0,0)
var exploding = false

func _ready():
	animated_sprite_2d.play("Default")

func _physics_process(delta: float) -> void:
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

func _on_animated_sprite_2d_animation_finished() -> void:
	queue_free()
