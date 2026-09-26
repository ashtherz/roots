class_name Suika_ball
extends RigidBody2D

@export var level: int

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 1000
	body_entered.connect(_on_body_entered)
	level = 1

func _on_body_entered(body : Node2D) -> void:
	if level == -1:
		return
	if body is Suika_ball:
		# we absorb the other guy and double in size
		if body.level == level:
			body.level = -1;
			body.queue_free()
			level += 1;
			$CollisionShape2D.shape.radius *= 1.5;
			$CollisionShape2D/Polygon2D.scale *= 1.5;
			$CollisionShape2D/Label.text = str(level)
			for b in get_colliding_bodies():
				_on_body_entered(b)
