extends TileMap
@onready var layer_0: TileMapLayer = $Layer0
@onready var player: CharacterBody2D = $"../Player"

@export var noise_height_texture : NoiseTexture2D

var noise : Noise
 
var width: int = 100
var height : int = 100

var source_id = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	noise_height_texture.noise.seed = randi() 
	noise = noise_height_texture.noise

func generate():
	for y in range(height):
		for x in range(width):
			var pos = Vector2i(x - width/2,y - height/2) + Vector2i(player.position)
			var val = noise.get_noise_2d(pos.x, pos.y)
			var tileType = Vector2i(0,0)
			#-0.5 - 0.5
			if val < -0.3:
				tileType = Vector2i(1,0)
			elif val < -0.15:
				tileType = Vector2i(2,0)
			elif val < 0.05:
				tileType = Vector2i(3,0)
			elif val < 0.3:
				tileType = Vector2i(0,1)
			#elif val < 0.3:
				#tileType = Vector2i(1,1) same colour as player health
			elif val < 0.35:
				tileType = Vector2i(2,1)
			else:
				tileType = Vector2i(3,1)
			
			layer_0.set_cell(pos, source_id,tileType)
				

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	generate()
