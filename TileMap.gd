extends TileMap
@onready var layer_0: TileMapLayer = $Layer0
@onready var player: CharacterBody2D = $"../Player"

@export var noise_height_texture : NoiseTexture2D

var noise : Noise
 
var width: int = 100
var height : int = 100

var source_id = 0

var tiles_generated = {}

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	noise_height_texture.noise.seed = randi() 
	noise = noise_height_texture.noise

func generate():
	for y in range(height):
		for x in range(width):
			var pos = Vector2i(x - width/2,y - height/2) + local_to_map(player.position) 
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
			tiles_generated[pos] = true
			
	remove_distant_tiles()

func remove_distant_tiles():
	var to_remove = []
	var player_tile_pos = Vector2i(player.position/16)
	for tile_pos in tiles_generated.keys():
		if abs(player_tile_pos.x - tile_pos.x) > (0.5*width) || abs(player_tile_pos.y- tile_pos.y) > (0.5*height):
			to_remove.append(tile_pos)
			
	for tile_pos in to_remove:
		layer_0.set_cell(tile_pos, -1)
		tiles_generated.erase(tile_pos)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	generate()
