extends Camera2D

@export var target: NodePath

@export var lerp_speed: float = 5.0

var player: Node2D

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if target:
		player = get_node(target)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player:
		position = position.lerp(player.position, lerp_speed * delta)
