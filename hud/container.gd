extends Node2D
#@export var item:CompressedTexture2D
@onready var container:TextureRect = $TextureRect
var inner_item:Node2D
#func _ready() -> void:
#	container.texture=item

func set_item(item:Node2D)->void:
	container.texture=item.texture
	inner_item=item
