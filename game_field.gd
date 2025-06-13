extends Node2D

class_name GameField

const MINE_CELL = preload("res://scenes/mine_cell.tscn")

signal game_lost
signal game_won

class PlayingCell:
	var mine_cell: MineCell
	var has_mine: bool
	var is_open: bool
	var neighbor_mines: int = -1
	var is_flagged: bool
	
	func _init(_mine_cell: MineCell):
		self.mine_cell = _mine_cell
	
	func reset():
		mine_cell.reset()
		has_mine = false
		is_open = false
		neighbor_mines = -1
		is_flagged = false

var cells : Array[PlayingCell] = []

@export var rows := 8
@export var columns := 10

@export var difficulty := 0.3

var game_state : GameState = GameState.Created

enum GameState {
	Created,
	Started,
	Won,
	Lost,
}

func is_game_finished():
	return game_state == GameState.Won || game_state == GameState.Lost

var center : Vector2
var workspace : Vector2

func _ready() -> void:
	var viewport_rect = get_viewport_rect()
	center = viewport_rect.get_center()
	workspace = viewport_rect.size * 0.8

func initialize() -> void:
	game_state = GameState.Created
	
	var cell_size = min(workspace.y / rows, workspace.x / columns)
	var cell_scale = cell_size / 512
	
	for cell in cells:
		cell.mine_cell.queue_free()
	
	cells.clear()
	
	for row in range(rows):
		for column in range(columns):
			var cell: PlayingCell
			var mine_cell = MINE_CELL.instantiate()
			cell = PlayingCell.new(mine_cell)
			add_child(mine_cell)
			cells.push_back(cell)
			cell.mine_cell.input_event.connect(make_input_handler(cell, row, column))
			
			cell.mine_cell.scale = Vector2.ONE * cell_scale
			
			var x = (column - (columns / 2.0)) * cell_size
			var y = (row - (rows / 2.0)) * cell_size
			
			cell.mine_cell.position = Vector2(x, y) + center

func make_input_handler(cell: PlayingCell, row: int, column: int):
	return func(_viewport: Node, event: InputEvent, _shape_idx: int) -> void:
		if is_game_finished():
			return
		
		if event is InputEventMouseButton && event.is_pressed():
			if event.button_index == MOUSE_BUTTON_LEFT:
				if game_state == GameState.Created:
					initialize_mines_on_game_field(row, column)
				open_cell(cell, row, column)
				check_win()
			if event.button_index == MOUSE_BUTTON_RIGHT:
				flag_cell(cell)
				check_win()

func initialize_mines_on_game_field(starting_row: int, starting_column: int) -> void:
	for row in range(rows):
		for column in range(columns):
			if row == starting_row && column == starting_column:
				continue
			
			var is_mine = randf() < difficulty
			var cell = get_cell(row, column)
			
			cell.has_mine = is_mine
	
	game_state = GameState.Started

func get_cell(row: int, column: int) -> PlayingCell:
	return cells[row * columns + column]

func open_cell(cell: PlayingCell, row: int, column: int) -> void:
	calculate_neighbors(cell, row, column)
	open_cell_core(cell)
	if cell.neighbor_mines == 0:
		rec_open_cells(row, column)

func flag_cell(cell: PlayingCell):
	if cell.is_open:
		return
	
	if cell.is_flagged:
		cell.is_flagged = false
		cell.mine_cell.set_state(MineCell.State.Closed)
	else:
		cell.is_flagged = true
		cell.mine_cell.set_state(MineCell.State.Flagged)

func check_win() -> void:
	var all_cells_open = true
	var all_mines_flagged = true
	
	for cell in cells:
		if not cell.has_mine && not cell.is_open:
			all_cells_open = false
		elif cell.has_mine && not cell.is_flagged:
			all_mines_flagged = false
		
		if not all_cells_open && not all_mines_flagged:
			return
	
	if all_cells_open || all_mines_flagged:
		game_state = GameState.Won
		game_won.emit()

func calculate_neighbors(cell: PlayingCell, row: int, column: int) -> void:
	if cell.neighbor_mines == -1:
		cell.neighbor_mines = 0
		for next_row in range(max(row - 1, 0), min(row + 2, rows)):
			for next_column in range(max(column - 1, 0), min(column + 2, columns)):
				var next_cell = get_cell(next_row, next_column)
				if next_cell.has_mine:
					cell.neighbor_mines += 1

func rec_open_cells(starting_row: int, starting_column: int) -> void:
	var cells_to_open: Array[Vector2i] = []
	for next_row in range(max(starting_row - 1, 0), min(starting_row + 2, rows)):
		for next_column in range(max(starting_column - 1, 0), min(starting_column + 2, columns)):
			if next_row == starting_row && next_column == starting_column:
				continue
			
			cells_to_open.push_back(Vector2i(next_row, next_column))
	
	while not cells_to_open.is_empty():
		var cell_position = cells_to_open.pop_front()
		var row = cell_position.x
		var column = cell_position.y
		var cell = get_cell(row, column)
		
		if cell.is_open:
			continue
		
		if cell.is_flagged:
			continue
		
		calculate_neighbors(cell, row, column)
		open_cell_core(cell)
		
		if cell.neighbor_mines == 0:
			for next_row in range(max(row - 1, 0), min(row + 2, rows)):
				for next_column in range(max(column - 1, 0), min(column + 2, columns)):
					if next_row == row && next_column == column:
						continue
					cells_to_open.push_back(Vector2i(next_row, next_column))

func open_cell_core(cell: PlayingCell):
	if cell.is_open:
		return
	
	if cell.is_flagged:
		return
	
	cell.is_open = true
	
	if cell.has_mine:
		on_game_lost()
		cell.mine_cell.set_state(MineCell.State.OpenMine)
		return
	
	if cell.neighbor_mines == 0:
		cell.mine_cell.set_state(MineCell.State.Open)
	elif cell.neighbor_mines == 1:
		cell.mine_cell.set_state(MineCell.State.Open1)
	elif cell.neighbor_mines == 2:
		cell.mine_cell.set_state(MineCell.State.Open2)
	elif cell.neighbor_mines == 3:
		cell.mine_cell.set_state(MineCell.State.Open3)
	elif cell.neighbor_mines == 4:
		cell.mine_cell.set_state(MineCell.State.Open4)
	elif cell.neighbor_mines == 5:
		cell.mine_cell.set_state(MineCell.State.Open5)
	elif cell.neighbor_mines == 6:
		cell.mine_cell.set_state(MineCell.State.Open6)
	elif cell.neighbor_mines == 7:
		cell.mine_cell.set_state(MineCell.State.Open7)
	elif cell.neighbor_mines == 8:
		cell.mine_cell.set_state(MineCell.State.Open8)

func on_game_lost() -> void:
	for c in cells:
		if c.has_mine && not c.is_open:
			c.mine_cell.set_state(MineCell.State.ClosedMine)
	
	game_state = GameState.Lost
	game_lost.emit()
