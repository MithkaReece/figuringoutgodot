extends Camera2D

@export var target: NodePath
var player: Node2D
@export var lerp_speed: float = 5.0



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if target:
		player = get_node(target)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if player:
		position = position.lerp(player.position, lerp_speed * delta)

var zoom_speed = 0.5
var min_zoom = Vector2(0.5,0.5)
var max_zoom = Vector2(5.0,5.0)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
			zoom -= Vector2(zoom_speed, zoom_speed)
			zoom = zoom.clamp(min_zoom,max_zoom)
		elif event.button_index == MOUSE_BUTTON_WHEEL_UP:
			zoom += Vector2(zoom_speed,zoom_speed)
			zoom =zoom.clamp(min_zoom,max_zoom)
