extends Area2D

signal suika_die

func _ready() -> void:
	body_entered.connect(_on_body_entered)

func _on_body_entered(_body: Node2D) -> void:
	suika_die.emit()
