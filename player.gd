extends CharacterBody2D
signal egg_pickup
@onready var spawner: Node2D = $"../Spawner"

var friendlyHealthBarTexture: Texture2D = preload("res://ProgressBarFullFriendly.png")
@onready var health_bar: Control = $HealthBar

var maxHealth = 100.0
var health = maxHealth

var eggSpriteScene = preload("res://EggSprite.tscn")
var egg_sprite: Sprite2D = null
var eggTexture = preload("res://Egg.png")
@onready var egg_shadow: Sprite2D = $EggShadowParent/EggShadow
var eggShadowTexture = preload("res://EggShadow.png")

var fireballScene = preload("res://Fireball.tscn")

var eggMenu = preload("res://EggUI.tscn")

var canMove = true

var speed = 70.0
var score = 0

const pathSize = 5
const pathGapDist = 20
var path = []

var carryingEggType = null
var carryingEggTimer = null

var potentialEggType = null
var potentialEggTimer = null


var creatureScene = preload("res://beanel.tscn")

var creatures = []

var fireballCoolDown = 0.15
var timeTillFireball = 0.0

func _ready() -> void:
	carryingEggType = null
	egg_sprite = null
	self.add_to_group("Player")
	egg_shadow.texture = null
	path.append(position)
	health_bar.get_node("TextureProgressBar").texture_progress = friendlyHealthBarTexture

func _process(delta: float) -> void:
	health_bar.get_node("TextureProgressBar").value = (health/maxHealth) * health_bar.get_node("TextureProgressBar").max_value
	
	if timeTillFireball >= 0.0:
		timeTillFireball -= delta
	handlePath()
	handleEgg(delta)

func _input(event):
	if event is InputEventMouseButton and event.pressed && timeTillFireball <= 0.0:
		timeTillFireball = fireballCoolDown
		var mousePos = get_global_mouse_position()
		var dir = (mousePos - position).normalized()
		var fireball = fireballScene.instantiate();
		fireball.position = position + 10*dir
		fireball.direction = dir
		fireball.speed = 70
		get_tree().root.add_child(fireball)
			

func _physics_process(delta: float) -> void:
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Vector2(Input.get_axis("move_left", "move_right"), Input.get_axis("move_up", "move_down"))
	direction = direction.normalized()
	if !canMove:
		direction = Vector2()

	if direction:
		velocity = direction * speed
	else:
		velocity.x = move_toward(velocity.x, 0, speed)
		velocity.y = move_toward(velocity.y, 0, speed)

	var collision = move_and_collide(velocity * delta)
	
	if collision:
		var other = collision.get_collider()
		
		if other is StaticBody2D and other.is_in_group("Egg"):
			var menuInstance = eggMenu.instantiate()
			menuInstance.position = other.position
			get_tree().current_scene.add_child(menuInstance)
			menuInstance.connect("egg_option_selected", _on_egg_selected)
			other.emit_signal("egg_pickup", self)
			other.queue_free()
			potentialEggType = other.type
			potentialEggTimer = other.timeLeftToIncubate
			canMove = false
			
func _on_egg_selected(option):
	canMove = true
	match option:
		"Incubate":
			carryingEggType = potentialEggType
			potentialEggType = null
			carryingEggTimer = potentialEggTimer
			potentialEggTimer = null
			if egg_sprite == null:
				egg_sprite = eggSpriteScene.instantiate();
				get_tree().root.add_child(egg_sprite)
		
			egg_sprite.texture = eggTexture
			egg_shadow.texture = eggShadowTexture
			egg_sprite.rotation = 0
		"Eat":
			print("Eat")
		
func handlePath():
	var lastPathPosition = path[0]
	if position.distance_to(lastPathPosition) < pathGapDist:
		path.insert(0, position)
		if path.size() > pathSize:
			path.pop_back();

func handleEgg(delta):
	if egg_sprite == null:
		return
	egg_sprite.position = position + Vector2(0, -20)
	egg_sprite.rotation += delta * PI * 0.2
	egg_shadow.rotation = egg_sprite.rotation;
	
	if carryingEggType != null:
		carryingEggTimer -= delta
		if carryingEggTimer <= 0:
			spawnFromEgg()
			
func spawnFromEgg():
	var creature = creatureScene.instantiate();
	var offset = 5
	creature.position = position + Vector2(0,-20)
	get_tree().root.add_child(creature)
	
	creatures.append(creature)
	creature._set_friendly()
	creature.player = self
	creature.spawner = self
	creature.SetType(carryingEggType)
	
	carryingEggType = null
	carryingEggTimer = null
	egg_sprite.texture = null
	egg_shadow.texture = null
	
func dropEgg():
	# Todo respawn egg on ground
	
	carryingEggType = null
	carryingEggTimer = null
	egg_sprite.texture = null
	egg_shadow.texture = null

func Damage(amount):
	health -= amount
	if health <= 0:
		if egg_sprite:
			egg_sprite.queue_free()
		for creature in creatures:
			creature.queue_free()
		spawner.Clear()
		get_tree().reload_current_scene()
