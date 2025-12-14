extends Control

func _ready() -> void:
	GameManager.trader_hud_open.connect(open)
	GameManager.trader_hud_close.connect(close)

func open():
	self.visible=true

func close():
	self.visible=false
