extends Node2D



func _on_area_2d_body_shape_entered(body_rid: RID, body: Node2D, body_shape_index: int, local_shape_index: int) -> void:
	if body.name=="player" and GameManager.player_health<GameManager.MAX_PLAYER_HEALTH:
		GameManager.player_health+=3
		if GameManager.player_health>GameManager.MAX_PLAYER_HEALTH:
			GameManager.player_health=GameManager.MAX_PLAYER_HEALTH
		GameManager.health_changed.emit(GameManager.player_health,GameManager.MAX_PLAYER_HEALTH)
		queue_free()
