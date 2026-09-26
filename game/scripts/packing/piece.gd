extends Node2D

var cell := 56.0

var cells: Array[Vector2i] = []
var color := Color.WHITE
var on_board := false
var texture: Texture2D = null
var tint_strength := 0.25


func setup(new_cells: Array, new_color: Color) -> void:
	cells.clear()
	for c in new_cells:
		cells.append(c)
	_normalise()
	color = new_color
	queue_redraw()


func contains_point(world_pos: Vector2) -> bool:
	var local := (world_pos - global_position) / cell
	return Vector2i(floori(local.x), floori(local.y)) in cells


func rotate_cw(world_pivot: Vector2) -> void:
	_transform(world_pivot,
		func(c: Vector2i) -> Vector2i: return Vector2i(-c.y - 1, c.x),
		func(p: Vector2) -> Vector2: return Vector2(-p.y, p.x))


func flip_h(world_pivot: Vector2) -> void:
	_transform(world_pivot,
		func(c: Vector2i) -> Vector2i: return Vector2i(-c.x - 1, c.y),
		func(p: Vector2) -> Vector2: return Vector2(-p.x, p.y))

func _transform(world_pivot: Vector2, cell_map: Callable, point_map: Callable) -> void:
	var pivot: Vector2 = point_map.call((world_pivot - global_position) / cell)
	var mapped: Array[Vector2i] = []
	for c in cells:
		mapped.append(cell_map.call(c))
	cells = mapped
	var shift := _normalise()
	pivot -= Vector2(shift)
	global_position = world_pivot - pivot * cell
	queue_redraw()


func bbox_cells() -> Vector2i:
	var mx := Vector2i.ZERO
	for c in cells:
		mx = Vector2i(maxi(mx.x, c.x), maxi(mx.y, c.y))
	return mx + Vector2i.ONE


func _normalise() -> Vector2i:
	var mn := Vector2i(1 << 30, 1 << 30)
	for c in cells:
		mn = Vector2i(mini(mn.x, c.x), mini(mn.y, c.y))
	for i in cells.size():
		cells[i] -= mn
	return mn


func _draw() -> void:
	var tint := Color.WHITE.lerp(color, tint_strength)
	for c in cells:
		var r := Rect2(Vector2(c) * cell, Vector2(cell, cell))
		if texture:
			draw_texture_rect(texture, r, false, tint)
		else:
			draw_rect(r.grow(-1.5), color)

	var w := 3.0
	var line := Color.WHITE
	for c in cells:
		var o := Vector2(c) * cell
		if (c + Vector2i.UP) not in cells:
			draw_line(o, o + Vector2(cell, 0), line, w)
		if (c + Vector2i.DOWN) not in cells:
			draw_line(o + Vector2(0, cell), o + Vector2(cell, cell), line, w)
		if (c + Vector2i.LEFT) not in cells:
			draw_line(o, o + Vector2(0, cell), line, w)
		if (c + Vector2i.RIGHT) not in cells:
			draw_line(o + Vector2(cell, 0), o + Vector2(cell, cell), line, w)
