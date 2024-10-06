extends StaticBody2D

@export var player: CharacterBody2D
@export var spawner: Node2D

var type = "Beanel"
var timeLeftToIncubate = 5.0;

func _ready() -> void:
	self.add_to_group("Egg")
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player && is_instance_valid(player) && spawner && is_instance_valid(spawner):
		if position.distance_to(player.position) > spawner.despawningRadius:
			SignalManager.egg_pickup.emit(self)
			queue_free()
