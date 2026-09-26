extends Sprite2D
signal interacted

@export var interactableId: String = "Unknown"

const INACTIVE_OUTLINE: float = 0.0
const IN_RANGE_OUTLINE: float = 2.0 # outline width in game pixels
const IN_RANGE_COLOR: Vector4 = Vector4(1.0, 1.0, 1.0, 1.0)

# We have enum at home
var interactionState: String = "INACTIVE"

# Undo the sprite's scale to get the outline size in pixels
func _outline_size(gamePixels: float) -> float:
	return gamePixels / absf(global_scale.x)

# state is str and not enum because idk how to make enums work across scripts
func show_state() -> void:
	match interactionState:
		"IN_RANGE":
			set_instance_shader_parameter("outLineSize", _outline_size(IN_RANGE_OUTLINE))
			set_instance_shader_parameter("outLineColor", IN_RANGE_COLOR)
		"INACTIVE":
			set_instance_shader_parameter("outLineSize", INACTIVE_OUTLINE)
			set_instance_shader_parameter("outLineColor", IN_RANGE_COLOR)
		_:
			push_warning("Unknown state ", interactionState)

func interact() -> void:
	interacted.emit()

# The shader can only draw inside the sprite's rect, so grow the drawn region past the
# texture to leave room for the outline.
# thank you syrupyy - from spdskatr
func _pad_region_for_outline() -> void:
	var tex_size: Vector2 = texture.get_size()
	var pad: Vector2 = Vector2.ONE * (ceilf(_outline_size(IN_RANGE_OUTLINE)) + 1.0)
	region_enabled = true
	region_rect = Rect2(-pad, tex_size + pad * 2.0)

func _ready() -> void:
	_pad_region_for_outline()
	show_state()


func _on_area_2d_body_entered(body: Node2D) -> void:
	interactionState = "IN_RANGE"
	show_state()


func _on_area_2d_body_exited(body: Node2D) -> void:
	interactionState = "INACTIVE"
	show_state()

func _physics_process(delta: float) -> void:
	if interactionState == "IN_RANGE" and Input.is_action_just_pressed("Interact"):
		interact()
