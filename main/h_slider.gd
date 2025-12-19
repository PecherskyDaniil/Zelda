extends HSlider

func _ready() -> void:
	var bus = AudioServer.get_bus_index("Master")
	value=AudioServer.get_bus_volume_linear(bus)
