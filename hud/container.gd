extends Node2D
@export var item:CompressedTexture2D
@onready var container:TextureRect = $TextureRect

func _ready() -> void:
	container.texture=item
