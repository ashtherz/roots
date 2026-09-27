extends Node2D
const Piece = preload("res://scripts/packing/piece.gd")
const DIRS = [Vector2i.RIGHT, Vector2i.LEFT, Vector2i.UP, Vector2i.DOWN]

@export var cols := 6
@export var rows := 5
@export var max_cell_size := 110.0   # biggest a square is allowed to get
@export var min_cell_size := 32.0    # never shrink below this
@export_range(0.3, 0.8) var board_area := 0.5
@export var margin := 40.0
@export var top_space := 110.0       # room reserved for the status text
@export var bottom_space := 60.0     # room reserved for the hint text
@export var block_texture: Texture2D
@export var background_texture: Texture2D
@export var mushroom_textures: Texture2D
@export_range(0, 10) var mushroom_count := 3
#@export var status_font_size := 32

var cell_size := 56.0   # calculated automatically in _fit_cell_size()

var board_origin := Vector2.ZERO
var tray_rect := Rect2()

var grid := {}
var blocked := {}
var pieces: Array = []
var dragging: Piece = null
var drag_offset := Vector2.ZERO
var status: Label
var hint: Label


func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var view := get_viewport_rect().size

	status = Label.new()
	status.position = Vector2(40, 24)
	status.add_theme_font_size_override("font_size", 50)
	add_child(status)

	hint = Label.new()
	hint.text = "Stuck? Press N for a new arrangement"
	hint.add_theme_font_size_override("font_size", 22)
	hint.modulate = Color(1, 1, 1, 0.7)
	hint.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	hint.position = Vector2(0, view.y - bottom_space + 12)
	hint.size = Vector2(view.x, bottom_space - 12)
	add_child(hint)

	new_puzzle()

func new_puzzle() -> void:
	for p in pieces:
		p.queue_free()
	pieces.clear()
	grid.clear()
	blocked.clear()
	dragging = null

	_place_mushrooms()
	var groups := _partition_board()

	# Decide rotations up front so we know each piece's size in the tray
	var rots: Array[int] = []
	var sizes: Array[Vector2i] = []
	for g in groups:
		var r := randi() % 4
		rots.append(r)
		var s := _group_size(g)
		sizes.append(Vector2i(s.y, s.x) if r % 2 == 1 else s)

	_fit_cell_size(sizes)
	_layout_board()

	for i in groups.size():
		var p := Piece.new()
		add_child(p)
		p.texture = block_texture
		p.cell = cell_size
		p.setup(groups[i], Color.from_hsv(float(i) / groups.size(), 0.55, 0.95))
		for r in rots[i]:
			p.rotate_cw(p.global_position)
		if randf() < 0.5:
			p.flip_h(p.global_position)
		pieces.append(p)
	_layout_tray()

	_update_status()
	queue_redraw()


func _group_size(g: Array) -> Vector2i:
	var lo: Vector2i = g[0]
	var hi: Vector2i = g[0]
	for c in g:
		lo = Vector2i(mini(lo.x, c.x), mini(lo.y, c.y))
		hi = Vector2i(maxi(hi.x, c.x), maxi(hi.y, c.y))
	return hi - lo + Vector2i.ONE


func _tray_rect() -> Rect2:
	var view := get_viewport_rect().size
	var split := view.x * board_area
	return Rect2(split, top_space, view.x - split - margin, view.y - top_space - bottom_space)


# Pick the biggest cell size where the board fits its half of the screen
# AND every piece fits in the tray.
func _fit_cell_size(sizes: Array[Vector2i]) -> void:
	var view := get_viewport_rect().size
	var split := view.x * board_area
	var avail_h := view.y - top_space - bottom_space
	var c := floorf(minf(split * 0.85 / cols, avail_h * 0.9 / rows))
	c = minf(c, max_cell_size)
	var tray := _tray_rect()
	while c > min_cell_size and not _tray_fits(sizes, c, tray):
		c -= 2.0
	cell_size = c


func _tray_fits(sizes: Array[Vector2i], c: float, tray: Rect2) -> bool:
	var gap := c * 0.5
	var x := 0.0
	var y := 0.0
	var row_h := 0.0
	for s in sizes:
		var sz := Vector2(s) * c
		if sz.x > tray.size.x:
			return false
		if x > 0.0 and x + sz.x > tray.size.x:
			x = 0.0
			y += row_h + gap
			row_h = 0.0
		x += sz.x + gap
		row_h = maxf(row_h, sz.y)
	return y + row_h <= tray.size.y


func _layout_board() -> void:
	var view := get_viewport_rect().size
	var split := view.x * board_area
	var avail_h := view.y - top_space - bottom_space
	board_origin = Vector2(
		(split - cols * cell_size) / 2.0,
		top_space + (avail_h - rows * cell_size) / 2.0
	).round()
	tray_rect = _tray_rect()


func _layout_tray() -> void:
	var gap := cell_size * 0.5
	var x := 0.0
	var y := 0.0
	var row_h := 0.0
	var spots: Array[Vector2] = []
	for p in pieces:
		var sz := Vector2(p.bbox_cells()) * cell_size
		if x > 0.0 and x + sz.x > tray_rect.size.x:
			x = 0.0
			y += row_h + gap
			row_h = 0.0
		spots.append(Vector2(x, y))
		x += sz.x + gap
		row_h = maxf(row_h, sz.y)
	var top := tray_rect.position.y + maxf(0.0, (tray_rect.size.y - (y + row_h)) / 2.0)
	for i in pieces.size():
		pieces[i].global_position = Vector2(tray_rect.position.x, top) + spots[i]


func _place_mushrooms() -> void:
	var cells: Array[Vector2i] = []
	for y in rows:
		for x in cols:
			cells.append(Vector2i(x, y))
	cells.shuffle()

	for c in cells:
		if blocked.size() >= mushroom_count:
			break
		var touching := false
		for d in DIRS:
			if blocked.has(c + d):
				touching = true
				break
		if touching:
			continue
		blocked[c] = mushroom_textures


func _partition_board() -> Array:
	var cell_owner := {}
	var groups: Array = []
	var order: Array[Vector2i] = []
	for y in rows:
		for x in cols:
			order.append(Vector2i(x, y))
	order.shuffle()

	for start in order:
		if cell_owner.has(start) or blocked.has(start):
			continue
		var id := groups.size()
		var group: Array[Vector2i] = [start]
		cell_owner[start] = id
		var target: int = [3, 4, 4, 4, 5].pick_random()
		while group.size() < target:
			var frontier := _free_neighbours(group, cell_owner)
			if frontier.is_empty():
				break
			var n: Vector2i = frontier.pick_random()
			cell_owner[n] = id
			group.append(n)
		groups.append(group)

	for id in groups.size():
		var g: Array = groups[id]
		if g.is_empty() or g.size() >= 3:
			continue
		var into := -1
		for c in g:
			for d in DIRS:
				var n: Vector2i = c + d
				if cell_owner.has(n) and cell_owner[n] != id and not groups[cell_owner[n]].is_empty():
					into = cell_owner[n]
					break
			if into != -1:
				break
		if into == -1:
			continue
		for c in g:
			cell_owner[c] = into
			groups[into].append(c)
		g.clear()

	return groups.filter(func(g): return not g.is_empty())


func _free_neighbours(group: Array, cell_owner: Dictionary) -> Array[Vector2i]:
	var out: Array[Vector2i] = []
	for c in group:
		for d in DIRS:
			var n: Vector2i = c + d
			if _in_bounds(n) and not cell_owner.has(n) and not blocked.has(n) and not out.has(n):
				out.append(n)
	return out

func _unhandled_input(event: InputEvent) -> void:
	var mouse := get_global_mouse_position()
	if event is InputEventMouseButton and event.pressed:
		match event.button_index:
			MOUSE_BUTTON_LEFT:
				_pick_up(mouse)
			MOUSE_BUTTON_RIGHT, MOUSE_BUTTON_WHEEL_UP:
				_modify(mouse, func(p, pv): p.rotate_cw(pv))
			MOUSE_BUTTON_WHEEL_DOWN:
				_modify(mouse, func(p, pv):
					for i in 3:
						p.rotate_cw(pv))
	elif event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and dragging:
		_drop()
	elif event is InputEventMouseMotion and dragging:
		dragging.global_position = mouse + drag_offset
		queue_redraw()
	elif event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_R:
				_modify(mouse, func(p, pv): p.rotate_cw(pv))
			KEY_F:
				_modify(mouse, func(p, pv): p.flip_h(pv))
			KEY_N:
				new_puzzle()


func _piece_at(pos: Vector2) -> Piece:
	for i in range(pieces.size() - 1, -1, -1):
		if pieces[i].contains_point(pos):
			return pieces[i]
	return null


func _pick_up(mouse: Vector2) -> void:
	var p := _piece_at(mouse)
	if p == null:
		return
	_lift(p)
	dragging = p
	drag_offset = p.global_position - mouse
	pieces.erase(p)
	pieces.append(p)
	move_child(p, -1)
	p.modulate.a = 0.85
	queue_redraw()


func _drop() -> void:
	var p := dragging
	dragging = null
	p.modulate.a = 1.0
	var at := _snap_cell(p)
	if _fits(p, at):
		_place(p, at)
	_update_status()
	queue_redraw()

func _modify(mouse: Vector2, action: Callable) -> void:
	var p: Piece = dragging if dragging else _piece_at(mouse)
	if p == null:
		return
	var pivot := _pivot(p, mouse)

	if p == dragging:
		action.call(p, pivot)
		drag_offset = p.global_position - mouse
	else:
		var was_placed := p.on_board
		var old_cells := p.cells.duplicate()
		var old_pos := p.global_position
		_lift(p)
		action.call(p, pivot)
		if was_placed:
			var at := _snap_cell(p)
			if not _fits(p, at):
				p.cells.assign(old_cells)
				p.global_position = old_pos
				p.queue_redraw()
				at = _snap_cell(p)
			_place(p, at)

	_update_status()
	queue_redraw()


func _pivot(p: Piece, mouse: Vector2) -> Vector2:
	var local := ((mouse - p.global_position) / cell_size).floor() + Vector2(0.5, 0.5)
	return p.global_position + local * cell_size

func _in_bounds(c: Vector2i) -> bool:
	return c.x >= 0 and c.y >= 0 and c.x < cols and c.y < rows


func _snap_cell(p: Piece) -> Vector2i:
	var rel := (p.global_position - board_origin) / cell_size
	return Vector2i(roundi(rel.x), roundi(rel.y))


func _fits(p: Piece, at: Vector2i) -> bool:
	for c in p.cells:
		var g: Vector2i = at + c
		if not _in_bounds(g) or grid.has(g) or blocked.has(g):
			return false
	return true


func _place(p: Piece, at: Vector2i) -> void:
	p.global_position = board_origin + Vector2(at) * cell_size
	for c in p.cells:
		grid[at + c] = p
	p.on_board = true


func _lift(p: Piece) -> void:
	if not p.on_board:
		return
	for key in grid.keys():
		if grid[key] == p:
			grid.erase(key)
	p.on_board = false


func _free_cell_count() -> int:
	return cols * rows - blocked.size()


func _is_packed() -> bool:
	return grid.size() == _free_cell_count()


func _update_status() -> void:
	if _is_packed():
		status.text = "Good job! Everything now fits! Keep rearranging, or press N for a new puzzle."
	else:
		status.text = "Filled %d / %d    drag = move · R = rotate · F = flip" \
			% [grid.size(), _free_cell_count()]
	hint.visible = not _is_packed()

func _draw() -> void:
	if background_texture:
		draw_texture_rect(background_texture, Rect2(Vector2.ZERO, get_viewport_rect().size), false)

	var board := Rect2(board_origin, Vector2(cols, rows) * cell_size)
	var frame := Color(0.3, 0.85, 0.45) if _is_packed() else Color(0.3, 0.3, 0.36)
	draw_rect(board.grow(6), frame)
	draw_rect(board, Color(0.12, 0.12, 0.15))
	for x in cols + 1:
		var px := board_origin.x + x * cell_size
		draw_line(Vector2(px, board.position.y), Vector2(px, board.end.y), Color(1, 1, 1, 0.08))
	for y in rows + 1:
		var py := board_origin.y + y * cell_size
		draw_line(Vector2(board.position.x, py), Vector2(board.end.x, py), Color(1, 1, 1, 0.08))

	for c in blocked:
		var r := Rect2(board_origin + Vector2(c) * cell_size, Vector2.ONE * cell_size)
		var tex: Texture2D = blocked[c]
		if tex:
			draw_texture_rect(tex, r.grow(-3), false)
		else:
			draw_circle(r.get_center(), cell_size * 0.3, Color(0.6, 0.35, 0.25))

	if dragging:
		var at := _snap_cell(dragging)
		if _fits(dragging, at):
			for c in dragging.cells:
				var r := Rect2(board_origin + Vector2(at + c) * cell_size, Vector2(cell_size, cell_size))
				draw_rect(r.grow(-1.5), Color(1, 1, 1, 0.18))
