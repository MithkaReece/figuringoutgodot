extends Node2D

@onready var player: CharacterBody2D = $"../Player"
@onready var score_label: Label = $"../CanvasLayer/ScoreLabel"

var creatureTypes = ["Beanel", "Malo" , "Shall", "Frog", "Mouse"]
var creatureScene = preload("res://beanel.tscn")
var creatures = []
var max_creatures: int = 100

var egg_scene = preload("res://Egg.tscn")
var eggs = []
var max_eggs: int = 3

const spawningMinRadius = 140
const spawningMaxRadius = 300
var despawningRadius = spawningMaxRadius + 30
var spawnInterval: float = 0.001
var timeTillSpawn = spawnInterval

var score = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	SignalManager.egg_pickup.connect(_on_egg_pickup)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	max_creatures = 70 + 50 * player.creatures.size()
	
	timeTillSpawn -= delta
	if timeTillSpawn < 0:
		timeTillSpawn = spawnInterval
		if creatures.size() < max_creatures:
			spawn_creature()
	
	if eggs.size() < max_eggs:
		spawn_egg()

func spawn_creature():
	var creature = creatureScene.instantiate()
	get_tree().root.add_child(creature)
	
	creature.position = random_spawn_point()

	creature.connect("creature_died", _on_creature_died)
	creature.player = player
	creature.spawner = self 
	creature.SetType(creatureTypes[randi_range(0, creatureTypes.size() - 1)])
	creature.maxHealth += 3 * player.creatures.size() * player.creatures.size()
	creature.health = creature.maxHealth
	creatures.append(creature)


func spawn_egg():
	var egg = egg_scene.instantiate()
	egg.position = random_spawn_point()
	
	get_tree().root.add_child(egg)
	eggs.append(egg)
	egg.type = creatureTypes[randi_range(0, creatureTypes.size() - 1)]
	egg.player = player
	egg.spawner = self 

func random_spawn_point():
	var validPos = false
	var pos
	while !validPos:
		pos = player.position + Vector2(randf_range(-spawningMaxRadius, spawningMaxRadius), randf_range(-spawningMaxRadius, spawningMaxRadius))
		if !player:
			return pos
		
		validPos = true
		for posOnPath in player.path:
			if pos.distance_to(posOnPath) < spawningMinRadius:
				validPos = false
				break
	return pos

func _on_creature_died(creature):
	creatures.erase(creature)
	creature.queue_free()

func _on_egg_pickup(egg):
	eggs.erase(egg)
	egg.queue_free()
	
func Clear():
	for egg in eggs:
		if egg && is_instance_valid(egg):
			egg.queue_free()
	for creature in creatures:
		if creature && is_instance_valid(creature):
			creature.queue_free()
	creatures.clear()
	
func AddScore(value):
	score += value
	score_label.text = str(int(score))
