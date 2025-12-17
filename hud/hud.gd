extends CanvasLayer


@onready var bow_container=$Container
@onready var sword_container=$Container2
func set_sword(item:Node2D):
	sword_container.set_item(item)

func set_bow(item:Node2D):
	bow_container.set_item(item)
