extends Node2D
#@export var item:CompressedTexture2D
@onready var container:TextureRect = $TextureRect
@onready var price_label:Label=$PriceLabel
var price:int
var inner_item:Node2D
var is_active:bool=false
var inner_object_class:String
func _ready() -> void:
	price_label.text=str(price)+"$"
	

func set_item(item:Node2D)->void:
	container.texture=item.texture
	inner_item=item
	
func update_texture():
	if inner_item!=null:
		container.texture=inner_item.texture

func set_price(p:int):
	price=p
	price_label.text=str(price)+"$"
	
func _input(event: InputEvent) -> void:
	if event.is_action_pressed("buy") and is_active:
		if GameManager.coins<price:
			return
		GameManager.add_coins(-price)
		if inner_object_class=="sword":
			GameManager.player.set_sword(inner_item)
		elif inner_object_class=="bow":
			GameManager.player.set_bow(inner_item)
		hide()

func _on_texture_rect_mouse_entered() -> void:
	is_active=true

func _on_texture_rect_mouse_exited() -> void:
	is_active=false
