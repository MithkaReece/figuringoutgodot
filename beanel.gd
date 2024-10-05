extends CharacterBody2D
signal creature_died

const maxHealth = 100
var health: float = maxHealth

var friendlyHealthBarTexture: Texture2D = preload("res://ProgressBarFullFriendly.png")
@onready var health_bar: Control = $HealthBar

var player: CharacterBody2D
var spawner: Node2D

var speed: float = 10.0 
var movement_radius: float = 50.0
var min_wait_time: float = 0.1
var max_wait_time: float = 2.0 

var is_attacking_player = false
var player_attack_radius = 30.0
var player_forget_radius = 50.0

var player_creature = false
var too_far_from_player = false
var targeting_gameobject = null
var player_too_far_radius = 80
var move_to_player_radius = 20

var boredLength = 5
var boredTimer = boredLength
var target_position: Vector2 = Vector2()
var is_moving: bool = false  
var wait_timer: float = 0.0 
@onready var collisionShape: CollisionShape2D = $CollisionShape2D
@onready var sprite2D: Sprite2D = $Sprite2D

var beanelSprite = preload("res://Creatures/Beanel.png")
var beanelShape = Vector3(2.5, 16, 0)

var maloSprite = preload("res://Creatures/Malo.png")
var maloShape = Vector3(5,14,4)

var shallSprite = preload("res://Creatures/Shall.png")
var shallShape = Vector3(8,16, 1)

var frogSprite = preload("res://Creatures/Frog.png")
var frogShape = Vector3(8,20,2)

var mouseSprite = preload("res://Creatures/Mouse.png")
var mouseShape = Vector3(6,16,4)

func SetType(type):
	match type:
		"Beanel":
			sprite2D.texture = beanelSprite
			collisionShape.shape.radius = beanelShape.x
			collisionShape.shape.height = beanelShape.y
			collisionShape.position.y = beanelShape.z
			health_bar.position = Vector2(-7,3)
		"Malo":
			sprite2D.texture = maloSprite
			collisionShape.shape.radius = maloShape.x
			collisionShape.shape.height = maloShape.y
			collisionShape.position.y = maloShape.z
			health_bar.position = Vector2(-7,7)
		"Shall":
			sprite2D.texture = shallSprite
			collisionShape.shape.radius = shallShape.x
			collisionShape.shape.height = shallShape.y
			collisionShape.position.y = shallShape.z
			health_bar.position = Vector2(-7,9)
		"Frog":
			sprite2D.texture = frogSprite
			collisionShape.shape.radius = frogShape.x
			collisionShape.shape.height = frogShape.y
			collisionShape.position.y = frogShape.z
			health_bar.position = Vector2(-7,9)
		"Mouse":			
			sprite2D.texture = mouseSprite
			collisionShape.shape.radius = mouseShape.x
			collisionShape.shape.height = mouseShape.y
			collisionShape.position.y = mouseShape.z
			health_bar.position = Vector2(-7,9)

func _set_friendly():
	player_creature = true
	health_bar.get_node("TextureProgressBar").texture_progress = friendlyHealthBarTexture
	set_collision_layer(1 << 4)
	set_collision_mask(1 << 1)
	self.remove_from_group("Creature")
	self.add_to_group("FriendlyCreature")
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	move_to_player_radius = randf_range(20, player_too_far_radius-20)
	self.add_to_group("Creature")
	pick_random_point()

func _process(delta: float) -> void:
	health_bar.get_node("TextureProgressBar").value = (health/maxHealth) * health_bar.get_node("TextureProgressBar").max_value
	
	if player && is_instance_valid(player) && spawner && is_instance_valid(spawner) && !player_creature:
		if position.distance_to(player.position) > spawner.despawningRadius:
			Die()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	if !player || !is_instance_valid(player):
		return
	if player_creature:
		players_creature_ai(delta)	
	else:
		wild_ai(delta)

func players_creature_ai(delta):
	if too_far_from_player:
		var dir = (player.position - position).normalized()
		var velocity = dir * 100 * delta
		move_and_collide(velocity)
		if player.position.distance_to(position) < move_to_player_radius:
			too_far_from_player = false
	else:
		if player.position.distance_to(position) > player_too_far_radius:
			too_far_from_player = true
			
		# Target nearby creature
		targeting_gameobject = null
		var creatureGroup = get_tree().get_nodes_in_group("Creature")
		for creature in creatureGroup:
			# Check if the body is within the specified radius
			if creature.position.distance_to(position) <= player_attack_radius:
				targeting_gameobject = creature
				break
		attack_alive_target(delta)
		#if targeting_gameobject == null:
			

func wild_ai(delta):
	if player.position.distance_to(position) < player_attack_radius:
		is_attacking_player = true
		targeting_gameobject = player
	if player.position.distance_to(position) > player_forget_radius:
		is_attacking_player = false
		targeting_gameobject = null
	
	if is_moving:
		if is_attacking_player:
			attack_alive_target(delta)
		else:
			move_towards_target(delta)
	else:
		wait_timer -= delta
		if wait_timer <= 0:
			pick_random_point()

func pick_random_point():
	var random_offset = Vector2(randf_range(-movement_radius, movement_radius), randf_range(-movement_radius, movement_radius))
	target_position = position + random_offset
	is_moving = true
	boredTimer = boredLength

func move_towards_target(delta):
	boredTimer -= delta
	if boredTimer < 0:
		pick_random_point()	
	
	var dir = (target_position - position).normalized()

	var velocity = dir * speed * delta
	HandleFlip(velocity)
	move_and_collide(velocity)
	
	if position.distance_to(target_position) < 10:
		is_moving = false
		wait_timer = randf_range(min_wait_time, max_wait_time)
		velocity = Vector2()
	
func attack_alive_target(delta):
	if !targeting_gameobject:
		return
		
	var dir = (targeting_gameobject.position-position).normalized()
	var velocity = dir * speed * delta
	HandleFlip(velocity)
	var collision = move_and_collide(velocity)
	
	if collision:
		var other = collision.get_collider()
		if player_creature:
			if other.is_in_group("Creature"):
				other.Damage(1)
		else:
			if other.is_in_group("Player"):
				other.Damage(1)

func Damage(amount):
	health -= amount
	if health <= 0.0:
		Die()

func Die():
	emit_signal("creature_died", self)
	queue_free()
	
func HandleFlip(velocity):
	if velocity.x > 0:
		sprite2D.flip_h = false  
	elif velocity.x < 0:
		sprite2D.flip_h = true 
