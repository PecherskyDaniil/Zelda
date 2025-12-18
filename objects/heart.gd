extends Node2D


func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.name=="player":
		GameManager.MAX_PLAYER_HEALTH+=2
		GameManager.player_health+=2
		GameManager.health_changed.emit(GameManager.player_health,GameManager.MAX_PLAYER_HEALTH)
		queue_free()
