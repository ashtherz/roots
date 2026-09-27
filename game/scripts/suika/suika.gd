extends Node2D

var suika_ball = preload("res://scenes/suika_ball.tscn")
@onready var curr :Node = null;
@onready var death = $Death
@export var endscreen : Node
@export var left_lim = -10;
@export var right_lim = 10;
@export var points_display : Label

var bubble_pops = [
	preload("res://assets/audio/universfield-bubble-pop-06-351337.mp3"),
 	preload("res://assets/audio/universfield-bubble-pop-07-487896.mp3"),
	preload("res://assets/audio/universfield-bubble-pop-08-351339.mp3")
]

var spawn_lim = 0;
var total_points = 0;
var dead = false;

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	curr = spawn_ball();
	spawn_lim = 0;
	death.suika_die.connect(die)

func replay():
	get_tree().reload_current_scene()
	
func back():
	SceneManager.call_deferred("return_to_previous_scene", "Suika")

func die():
	var msg = "Stinky..."
	if total_points > 500:
		msg = "Excellent work!"
	elif total_points > 250:
		msg = "So many bubbles!"
	elif total_points > 100:
		msg = "Nice!"
	endscreen.get_node("Score").text = "Score: " + str(total_points) + "\n" + msg
	endscreen.visible = true
	dead = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if curr == null: return
	
	var mouse_pos = get_global_mouse_position()
	spawn_lim -= delta;
	if spawn_lim <= 0:
		curr.get_node("CollisionShape2D").get_node("Sprite2D").modulate.a = 1;
	
	curr.global_position.x = min(max(mouse_pos.x, left_lim), right_lim);
	
func _input(event):
	if spawn_lim > 0 or dead:
		return
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		curr.gravity_scale = 1.0;
		curr.get_node("CollisionShape2D").disabled = false
		gain_points(1)
		curr = spawn_ball();

func spawn_ball() -> Node2D:
	var new_ball = suika_ball.instantiate();
	print("spawn!");
	add_child(new_ball);
	new_ball.add_points.connect(gain_points)
	new_ball.gravity_scale = 0.0;
	new_ball.get_node("CollisionShape2D").disabled = true
	new_ball.get_node("CollisionShape2D").get_node("Sprite2D").modulate.a = 0.3;
	spawn_lim = 1;
	
	var limit = min(log(total_points) / log(12), 3)
	for i in range(randi_range(0,limit)):
		new_ball.merge()
	return new_ball;

func gain_points(points):
	total_points += points
	points_display.text = "Effervescence: " + str(total_points)
	AudioManager._on_play_sfx(bubble_pops[randi_range(0,2)])
