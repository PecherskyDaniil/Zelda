extends GridContainer

# Создаем AtlasTexture для каждого состояния сердца
func create_atlas_texture(region: Rect2) -> AtlasTexture:
	var atlas = AtlasTexture.new()
	atlas.atlas = preload("res://hud/Heart_Health_Bar.png")
	atlas.region = region
	return atlas

# Предположим, что в спрайтшите сердца размером 32x32 идут в ряд:
# [полное, половинное, пустое]
var heart_full: AtlasTexture
var heart_half: AtlasTexture
var heart_empty: AtlasTexture

func _ready():
	heart_full = create_atlas_texture(Rect2(0, 0, 8, 8))
	heart_half = create_atlas_texture(Rect2(16,8,8,8))
	heart_empty = create_atlas_texture(Rect2(16,16,8,8))
	GameManager.health_changed.connect(update_hearts)
	update_hearts()

func update_hearts(current = GameManager.player_health,maximum = GameManager.MAX_PLAYER_HEALTH):
	for child in get_children():
		child.queue_free()
	var heart_value = 2  # HP за одно сердце
	var total_hearts = ceil(float(maximum) / heart_value)
	var full_hearts = current / heart_value
	var has_half = current % heart_value > 0
	for i in range(total_hearts):
		var texture_rect = TextureRect.new()
		texture_rect.custom_minimum_size = Vector2(8,8)
		texture_rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		texture_rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		if i < full_hearts:
			texture_rect.texture = heart_full
		elif i == full_hearts and has_half:
			texture_rect.texture = heart_half
		else:
			texture_rect.texture = heart_empty
		
		add_child(texture_rect)
