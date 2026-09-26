extends Node2D

var suika_ball = preload("res://scenes/suika_ball.tscn")
@onready var curr :Node = null;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	curr = spawn_ball();

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if curr == null: return
	
	var mouse_pos = get_global_mouse_position()
	
	curr.global_position.x = mouse_pos.x;
	
func _input(event):
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		curr.gravity_scale = 1.0;
		curr.get_node("CollisionShape2D").disabled = false
		curr = spawn_ball();

func spawn_ball() -> Node2D:
	var new_ball = suika_ball.instantiate();
	print("spawn!");
	add_child(new_ball);
	new_ball.gravity_scale = 0.0;
	new_ball.get_node("CollisionShape2D").disabled = true
	return new_ball;
