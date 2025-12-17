extends Control

@onready var sword2:Node2D=preload("res://items/sword_2.tscn").instantiate()
@onready var bow1:Node2D=preload("res://items/bow.tscn").instantiate()
@onready var bow2:Node2D=preload("res://items/bow2.tscn").instantiate()

@onready var container1:Node2D=$CenterContainer/VBoxContainer/HBoxContainer/Trade_container
@onready var container2:Node2D=$CenterContainer/VBoxContainer/HBoxContainer/Trade_container2
@onready var container3:Node2D=$CenterContainer/VBoxContainer/HBoxContainer/Trade_container3
func _ready() -> void:
	container1.set_item(sword2)
	container1.set_price(40)
	container1.inner_object_class="sword"
	container2.set_item(bow1)
	container2.set_price(40)
	container2.inner_object_class="bow"
	container3.set_item(bow2)
	container3.set_price(80)
	container3.inner_object_class="bow"
	GameManager.trader_hud_open.connect(open)
	GameManager.trader_hud_close.connect(close)



func open():
	container1.update_texture()
	container2.update_texture()
	container3.update_texture()
	self.visible=true

func close():
	self.visible=false
