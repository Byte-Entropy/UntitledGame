# ******************************************************************************
# * @file    world.gd
# * @author  Javier
# * @date    Feb 01, 2026
# * @brief   Manages level-specific logic and provides an API for actors to 
# * query the environment (e.g., getting tile colors).
# ******************************************************************************

# ************************************
# * INCLUDES
# ************************************
extends Node2D

# ************************************
# * PRIVATE MACROS AND DEFINES
# ************************************
# (No constants defined yet)

# ************************************
# * VARIABLES
# ************************************

# === Node References ===

## Reference to the main TileMapLayer. Used to detect ground types.
@onready var terrain_layer: TileMapLayer = $TileMapLayer 

# === Data Cache ===

## Caches the calculated color for each tile coordinate.
## Format: { Vector2i(x,y): Color }
var _color_cache: Dictionary = {}

# ************************************
# * FUNCTION DEFINITIONS
# ************************************

## Retrieves the average color of the terrain at a specific world position.
## Checks the cache first; if missing, calculates and stores it.
##
## @param global_pos: The global pixel position of the actor (e.g. Player).
## @return Color: The average color of the tile at that location.
func get_terrain_color_at(global_pos: Vector2) -> Color:
	# Convert player's world position to the grid map position
	var local_pos = terrain_layer.to_local(global_pos)
	var map_pos = terrain_layer.local_to_map(local_pos)
	
	# Check if we already calculated this tile
	if map_pos in _color_cache:
		return _color_cache[map_pos]
		
	# If not, calculate it ("Compress" the texture)
	var new_color = _calculate_tile_color(map_pos)
	
	# Save it for next time
	_color_cache[map_pos] = new_color
	return new_color


## Internal helper to calculate the average color of a tile texture.
## Samples pixels from the Atlas texture used at the specific map coordinates.
##
## @param map_pos: The grid coordinates of the tile to analyze.
## @return Color: The averaged color (tint) of that tile.
func _calculate_tile_color(map_pos: Vector2i) -> Color:
	# A. Get the Tile Data
	var source_id = terrain_layer.get_cell_source_id(map_pos)
	var atlas_coords = terrain_layer.get_cell_atlas_coords(map_pos)
	
	if source_id == -1:
		return Color.WHITE # Fallback for empty space
		
	# B. Get the Texture Image
	var tile_set = terrain_layer.tile_set
	var source = tile_set.get_source(source_id)
	var texture = source.texture
	var image = texture.get_image() # This pulls pixel data from the texture
	
	# C. "Compress" (Average) the Pixels
	# Calculate where this specific tile is on the spritesheet
	var tile_size = tile_set.tile_size
	var region_rect = Rect2i(atlas_coords * tile_size, tile_size)
	
	var r = 0.0
	var g = 0.0
	var b = 0.0
	var pixel_count = 0
	
	# Loop through the tile's pixels (Step 4 for performance)
	for x in range(region_rect.position.x, region_rect.end.x, 4):
		for y in range(region_rect.position.y, region_rect.end.y, 4):
			var pixel = image.get_pixel(x, y)
			if pixel.a > 0.1: # Ignore transparent pixels
				r += pixel.r
				g += pixel.g
				b += pixel.b
				pixel_count += 1
				
	if pixel_count == 0: return Color.WHITE
	
	return Color(r / pixel_count, g / pixel_count, b / pixel_count)