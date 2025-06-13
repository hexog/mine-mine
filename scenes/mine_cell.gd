extends Node2D
class_name MineCell

const CELL_CLOSED = preload("res://assets/cell_closed.png")
const CELL_CLOSED_MINE = preload("res://assets/cell_closed_mine.png")
const CELL_FLAGGED = preload("res://assets/cell_flagged.png")
const CELL_OPEN = preload("res://assets/cell_open.png")
const CELL_OPEN_MINE = preload("res://assets/cell_open_mine.png")
const CELL_OPEN_1 = preload("res://assets/cell_open_1.png")
const CELL_OPEN_2 = preload("res://assets/cell_open_2.png")
const CELL_OPEN_3 = preload("res://assets/cell_open_3.png")
const CELL_OPEN_4 = preload("res://assets/cell_open_4.png")
const CELL_OPEN_5 = preload("res://assets/cell_open_5.png")
const CELL_OPEN_6 = preload("res://assets/cell_open_6.png")
const CELL_OPEN_7 = preload("res://assets/cell_open_7.png")
const CELL_OPEN_8 = preload("res://assets/cell_open_8.png")

@onready var sprite: Sprite2D = $Sprite2D

var state = State.Closed

enum State {
	Closed,
	ClosedMine,
	Flagged,
	Open,
	OpenMine,
	Open1, Open2, Open3, Open4,
	Open5, Open6, Open7, Open8,
}

func set_state(new_state: State) -> void:
	if state == new_state:
		return
	
	if new_state == State.Closed:
		sprite.texture = CELL_CLOSED
	elif new_state == State.ClosedMine:
		sprite.texture = CELL_CLOSED_MINE
	elif new_state == State.Flagged:
		sprite.texture = CELL_FLAGGED
	elif new_state == State.Open:
		sprite.texture = CELL_OPEN
	elif new_state == State.OpenMine:
		sprite.texture = CELL_OPEN_MINE
	elif new_state == State.Open1:
		sprite.texture = CELL_OPEN_1
	elif new_state == State.Open2:
		sprite.texture = CELL_OPEN_2
	elif new_state == State.Open3:
		sprite.texture = CELL_OPEN_3
	elif new_state == State.Open4:
		sprite.texture = CELL_OPEN_4
	elif new_state == State.Open5:
		sprite.texture = CELL_OPEN_5
	elif new_state == State.Open6:
		sprite.texture = CELL_OPEN_6
	elif new_state == State.Open7:
		sprite.texture = CELL_OPEN_7
	elif new_state == State.Open8:
		sprite.texture = CELL_OPEN_8

	state = new_state

func reset() -> void:
	set_state(MineCell.State.Closed)
