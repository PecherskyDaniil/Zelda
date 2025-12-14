extends Label

@onready var anim_player=get_node("AnimationPlayer")
func _ready() -> void:
	GameManager.coins_changed.connect(on_coins_changed)


func on_coins_changed(money:int):
	anim_player.play("changed_coins")
	self.text=str(money)+"$"
