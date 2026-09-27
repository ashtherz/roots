extends CanvasModulate

@export var max_darkness : float = 0.75

func set_darkness(level: float) -> void:
	var spotlight: PointLight2D = %Player/Spotlight
	if abs(level) <= 1e-5:
		visible = false
		spotlight.visible = false
	else:
		var d = (1 - level) * max_darkness + (1 - max_darkness)
		var spotlight_color = Color(1-d, 1-d, 1-d)
		var darkness_color = Color(d, d, d)
		visible = true
		spotlight.visible = true
		color = darkness_color
		spotlight.color = spotlight_color
