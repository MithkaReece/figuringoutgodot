extends CharacterBody2D
@onready var _1: Sprite2D = $"../CanvasLayer/Control/CreatureBar/1"
@onready var _2: Sprite2D = $"../CanvasLayer/Control/CreatureBar/2"
@onready var _3: Sprite2D = $"../CanvasLayer/Control/CreatureBar/3"
@onready var _4: Sprite2D = $"../CanvasLayer/Control/CreatureBar/4"
@onready var _5: Sprite2D = $"../CanvasLayer/Control/CreatureBar/5"
@onready var _6: Sprite2D = $"../CanvasLayer/Control/CreatureBar/6"
@onready var _7: Sprite2D = $"../CanvasLayer/Control/CreatureBar/7"
@onready var _8: Sprite2D = $"../CanvasLayer/Control/CreatureBar/8"
@onready var _9: Sprite2D = $"../CanvasLayer/Control/CreatureBar/9"
@onready var _10: Sprite2D = $"../CanvasLayer/Control/CreatureBar/10"

var beanelSprite = preload("res://Creatures/Beanel.png")
var maloSprite = preload("res://Creatures/Malo.png")
var shallSprite = preload("res://Creatures/Shall.png")
var frogSprite = preload("res://Creatures/Frog.png")
var mouseSprite = preload("res://Creatures/Mouse.png")

@onready var audioStream: AudioStreamPlayer2D = $WalkAudio
@onready var hurt_audio: AudioStreamPlayer2D = $HurtAudio
@onready var shoot_audio: AudioStreamPlayer2D = $ShootAudio

@onready var player_sprite: AnimatedSprite2D = $PlayerSprite

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
var fireballRange = 30

var eggMenu = preload("res://EggUI.tscn")



var canMove = true

var speed = 70.0
var score = 0

const pathSize = 5
const pathGapDist = 20
var path = []

var carryingEggType = null
var carryingEggTimer = null

var creatureScene = preload("res://beanel.tscn")

var creatures = []

var fireballCoolDown = 0.15
var timeTillFireball = 0.0

var regenCooldown = 0.5
var timeTillRegen = 0.0

var healthGainMult = 1.0

func _ready() -> void:
	canDie = true
	SignalManager.win_game.connect(stopDeath)
	SignalManager.restart_game.connect(CleanupScene)
	SignalManager.friendly_creature_died.connect(_on_friendly_death)
	player_sprite.play()
	carryingEggType = null
	egg_sprite = null
	self.add_to_group("Player")
	egg_shadow.texture = null
	path.append(position)
	health_bar.get_node("TextureProgressBar").texture_progress = friendlyHealthBarTexture

func _process(delta: float) -> void:
	shooting()
	
	var size = 0.5 + sqrt(score) * 0.02 * 2
	scale = Vector2(size,size)
	_update_creature_bar()
	health_bar.get_node("TextureProgressBar").value = (health/maxHealth) * health_bar.get_node("TextureProgressBar").max_value
	if timeTillRegen > 0:
		timeTillRegen -= delta
	else:
		health += delta
		if health > maxHealth:
			health = maxHealth
	
	if spawner.score != score:
		var diff = (spawner.score - score) * healthGainMult
		score = spawner.score
		for creature in creatures:
			creature.maxHealth += diff
			creature.health += diff
			
	
	if timeTillFireball >= 0.0:
		timeTillFireball -= delta
	handlePath()
	handleEgg(delta)

func creatureToTexture(creature):
	match creature.get_node("Sprite2D").animation:
		"Beanel":
			return beanelSprite
		"Frog":
			return frogSprite
		"Malo":
			return maloSprite
		"Mouse":
			return mouseSprite
		"Shall":
			return shallSprite

func _update_creature_bar():
	if 0 < creatures.size():
		_1.texture = creatureToTexture(creatures[0])
	else:
		_1.texture = null
	if 1 < creatures.size():
		_2.texture = creatureToTexture(creatures[1])
	else:
		_2.texture = null
	if 2 < creatures.size():
		_3.texture = creatureToTexture(creatures[2])
	else:
		_3.texture = null
	if 3 < creatures.size():
		_4.texture = creatureToTexture(creatures[3])
	else:
		_4.texture = null
	if 4 < creatures.size():
		_5.texture = creatureToTexture(creatures[4])
	else:
		_5.texture = null
	if 5 < creatures.size():
		_6.texture = creatureToTexture(creatures[5])
	else:
		_6.texture = null
	if 6 < creatures.size():
		_7.texture = creatureToTexture(creatures[6])
	else:
		_7.texture = null
	if 7 < creatures.size():
		_8.texture = creatureToTexture(creatures[7])
	else:
		_8.texture = null
	if 8 < creatures.size():
		_9.texture = creatureToTexture(creatures[8])
	else:
		_9.texture = null
	if 9 < creatures.size():
		_10.texture = creatureToTexture(creatures[9])
	else:
		_10.texture = null

func shooting():
	if Input.is_mouse_button_pressed(1) && timeTillFireball <= 0.0:
		shoot_audio.pitch_scale = randf_range(0.8,0.9)
		shoot_audio.play()
		timeTillFireball = fireballCoolDown
		var mousePos = get_global_mouse_position()
		var dir = (mousePos - position + velocity.normalized()).normalized()
		var fireball = fireballScene.instantiate();
		get_tree().root.add_child(fireball)
		fireball.position = position + 10*dir
		fireball.velocity = 70 * dir
		fireball.speed = 70
		fireball.SetRange(fireballRange + 0.1*score)

			

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
		velocity.x = move_toward(velocity.x, 0, speed*1.5*delta)
		velocity.y = move_toward(velocity.y, 0, speed*1.5*delta)
		
	audioStream.volume_db = (velocity.length()/speed)*20.0-25.0
		
	if velocity.length() > 0:
		if not audioStream.playing:
			audioStream.play()
	elif audioStream.playing:
		audioStream.stop()

	var collision = move_and_collide(velocity * delta)
	
	if collision:
		var other = collision.get_collider()
		
		if other is StaticBody2D and other.is_in_group("Egg"):
			SignalManager.egg_pickup.emit(other)
			if carryingEggType:
				spawner.AddScore(0.1*spawner.score)
			else:
				carryingEggType = other.type
				carryingEggTimer = other.timeLeftToIncubate
				if egg_sprite == null:
					egg_sprite = eggSpriteScene.instantiate();
					get_tree().root.add_child(egg_sprite)
			
				egg_sprite.texture = eggTexture
				egg_shadow.texture = eggShadowTexture
				egg_sprite.rotation = 0

		
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
	creature.spawner = spawner
	creature.SetType(carryingEggType)
	creature.maxHealth += score * healthGainMult
	creature.health = creature.maxHealth
	
	carryingEggType = null
	carryingEggTimer = null
	egg_sprite.texture = null
	egg_shadow.texture = null
	if creatures.size() >= 10:
		SignalManager.win_game.emit()
	
func dropEgg():
	# Todo respawn egg on ground
	
	carryingEggType = null
	carryingEggTimer = null
	egg_sprite.texture = null
	egg_shadow.texture = null

var canDie = true
func stopDeath():
	canDie = false

func Damage(amount):
	if !canDie:
		return
	hurt_audio.play()
	health -= amount
	timeTillRegen = regenCooldown
	if health <= 0:
		CleanupScene()
		
func CleanupScene():
	get_tree().paused = false
	if egg_sprite:
		egg_sprite.queue_free()
	for creature in creatures:
		creature.queue_free()
	spawner.Clear()
	carryingEggType = null
	get_tree().reload_current_scene()

func _on_friendly_death(creature):
	creatures.erase(creature)
	creature.queue_free()
