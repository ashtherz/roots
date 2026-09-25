extends Sprite2D
signal interacted

@export var interactableId: String = "Unknown"

const INACTIVE_OUTLINE: float = 0.0
const IN_RANGE_OUTLINE: float = 2.0 # outline width in game pixels

var normalColor: Vector4 = Vector4(1.0, 1.0, 1.0, 1.0)

func set_normal_color(color: Vector4) -> void:
	normalColor = color

# Undo the sprite's scale to get the outline size in pixels
func _outline_size(gamePixels: float) -> float:
	return gamePixels / absf(global_scale.x)

# state is str and not enum because idk how to make enums work across scripts
func show_state(state: String) -> void:
	match state:
		"IN_RANGE":
			set_instance_shader_parameter("outLineSize", _outline_size(IN_RANGE_OUTLINE))
			set_instance_shader_parameter("outLineColor", normalColor)
		"INACTIVE":
			set_instance_shader_parameter("outLineSize", INACTIVE_OUTLINE)
			set_instance_shader_parameter("outLineColor", normalColor)
		_:
			push_warning("Unknown state ", state)

func interact() -> bool:
	interacted.emit()
	return true

# The shader can only draw inside the sprite's rect, so grow the drawn region past the
# texture to leave room for the outline.
# thank you syrupyy - from spdskatr
func _pad_region_for_outline() -> void:
	var texSize: Vector2 = texture.get_size()
	var pad: Vector2 = Vector2.ONE * (ceilf(_outline_size(IN_RANGE_OUTLINE)) + 1.0)
	region_enabled = true
	region_rect = Rect2(-pad, texSize + pad * 2.0)

func _ready() -> void:
	_pad_region_for_outline()
	# %InteractionManager.register_interactable(self)
	show_state("INACTIVE")


func _on_area_2d_body_entered(body: Node2D) -> void:
	show_state("IN_RANGE")


func _on_area_2d_body_exited(body: Node2D) -> void:
	show_state("INACTIVE")
