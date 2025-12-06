extends Node2D

class_name LevelGenerator

# Конфигурация цветов
const WALL_COLOR := Color.BLACK
const FLOOR_COLOR := Color.WHITE
const OBJECT_COLOR:= Color.YELLOW
const EMPTY_COLOR := Color(0, 0, 0, 0)  # Прозрачный
var BASE_WALL_TILE=Vector2i(14,0)
var FLOOR_TILE=Vector2i(1,2)
var teleport_pos=Vector2i(0,0)
const MORPHOLOGY_TEMPLATES: Dictionary = {
	# Угловые стены
	"111111111":Vector2i(12,0),
	"****11*10":Vector2i(13,0),
	"***111*0*":Vector2i(14,0),
	"***11*01*":Vector2i(15,0),
	"000010000":Vector2i(12,1),
	"*1**10*1*":Vector2i(13,1),
	"*1**0****":Vector2i(14,1),
	"*1*01**1*":Vector2i(15,1),
	"*10*11***":Vector2i(13,2),
	"*0*111***":Vector2i(14,2),
	"01*11****":Vector2i(15,2),
	"000010*1*":Vector2i(12,3),
	"*1*010000":Vector2i(13,3),
	"*1*110*00":Vector2i(14,3),
	"*1*01100*":Vector2i(15,3),
	"00*01100*":Vector2i(12,4),
	"*00110*00":Vector2i(13,4),
	"*00110*1*":Vector2i(14,4),
	"00*011*1*":Vector2i(15,4),
}
func get_teleport_pos():
	return teleport_pos
func generate_from_png(base_tile_map:TileMapLayer,objects_tile_map:TileMapLayer,image_path: String) -> void:
	# 1. Загружаем и парсим PNG
	var grid = load_image_to_grid(image_path)
	if grid.is_empty():
		return
	
	# 2. Очищаем тайлмапу
	base_tile_map.clear()
	objects_tile_map.clear()
	# 3. Сначала расставляем базовые тайлы
	for x in range(grid.size()):
		for y in range(grid[0].size()):
			if grid[x][y] == 1:  # Стена
				base_tile_map.set_cell(Vector2i(x, y), 0, BASE_WALL_TILE)
			elif grid[x][y] == 0 or grid[x][y] == 3 or grid[x][y]==2:  # Пол
				base_tile_map.set_cell(Vector2i(x, y), 0, FLOOR_TILE)
				if  grid[x][y] == 3:
					objects_tile_map.set_cell(Vector2i(x,y),0,Vector2i(randi_range(3,5),5))
				if  grid[x][y] == 2:
					teleport_pos=objects_tile_map.map_to_local(Vector2i(x,y))
	# 4. Применяем морфологические шаблоны
	apply_morphology_templates(base_tile_map,grid)
func load_image_to_grid(image_path: String) -> Array:
	var image := Image.load_from_file(image_path)
	if not image:
		printerr("Не удалось загрузить изображение")
		return []
	
	var grid := []
	var width = image.get_width()
	var height = image.get_height()
	
	grid.resize(width)
	for x in range(width):
		grid[x] = []
		grid[x].resize(height)
		
		for y in range(height):
			var color = image.get_pixel(x, y)
			# Черный = стена (1), Белый = пол (0), Прозрачный = пропуск (-1)
			if color.a < 0.1:
				grid[x][y] = -1
			elif color == Color.BLACK:
				grid[x][y] = 1
			elif color == Color.YELLOW:
				grid[x][y] = 3
			elif color == Color.GREEN:
				grid[x][y] = 2
			else:
				grid[x][y] = 0
	
	return grid


func get_3x3_pattern(grid: Array, x: int, y: int) -> String:
	var pattern := ""
	
	for dy in range(-1, 2):
		for dx in range(-1, 2):
			var nx = x + dx
			var ny = y + dy
			
			if nx >= 0 and nx < grid.size() and ny >= 0 and ny < grid[0].size():
				if grid[nx][ny] == 1:
					pattern += "1"
				elif grid[nx][ny] == 0:
					pattern += "0"
				else:
					pattern += "*"  # Пропуск/граница
			else:
				pattern += "*"  # За пределами карты
	return pattern

func apply_morphology_templates(tile_map:TileMapLayer,grid: Array) -> void:
	for x in range(grid.size()):
		for y in range(grid[0].size()):
			#if grid[x][y] != 1:
			#	continue  # Пропускаем не-стены
			
			var pattern = get_3x3_pattern(grid, x, y)
			
			# Ищем совпадение с шаблонами
			for template in MORPHOLOGY_TEMPLATES.keys():
				if pattern_matches(template, pattern):
					var tile_index = MORPHOLOGY_TEMPLATES[template]
					tile_map.set_cell(Vector2i(x, y), 0, tile_index)
					break

func pattern_matches(template: String, pattern: String) -> bool:
	if template.length() != pattern.length():
		return false
	
	for i in range(template.length()):
		if template[i] == "*":
			continue  # Любой символ подходит
		if template[i] != pattern[i]:
			return false
	return true
