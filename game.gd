extends Node2D

@onready var camera: Camera2D = $Camera

@onready var game_lost_canvas: CanvasLayer = $LoseScreen
@onready var game_won_canvas: CanvasLayer = $WinScreen
@onready var game_field: GameField = $GameField
@onready var main_menu: CanvasLayer = $MainMenu
@onready var game_controls: CanvasLayer = $GameControls

@onready var rows_selector: Control = $MainMenu/Panel/Options/RowsSelector
@onready var columns_selector: Control = $MainMenu/Panel/Options/ColumnsSelector
@onready var difficulty_slider: HSlider = $MainMenu/Panel/Options/DifficultySelector/Slider

func _on_game_field_game_lost() -> void:
	game_lost_canvas.show()
	game_controls.hide()

func _on_restart_button_pressed() -> void:
	game_lost_canvas.hide()
	game_won_canvas.hide()
	game_controls.show()
	game_field.initialize()
	camera.position = get_viewport_rect().get_center()

func _on_exit_button_pressed() -> void:
	game_field.hide()
	game_controls.hide()
	game_lost_canvas.hide()
	game_won_canvas.hide()
	main_menu.show()

func _on_start_button_pressed() -> void:
	game_field.rows = rows_selector.value
	game_field.columns = columns_selector.value
	game_field.difficulty = difficulty_slider.value
	
	game_field.initialize()
	
	main_menu.hide()
	game_controls.show()
	game_field.show()
	camera.position = get_viewport_rect().get_center()

func _unhandled_input(event: InputEvent) -> void:
	if game_field.visible:
		if event is InputEventMouseButton:
			if event.button_index == MOUSE_BUTTON_WHEEL_UP:
				var zoom = camera.zoom
				if zoom.x <= 3:
					zoom += Vector2(0.1, 0.1)
					camera.zoom = zoom
			elif event.button_index == MOUSE_BUTTON_WHEEL_DOWN:
				var zoom = camera.zoom
				if zoom.x >= 0.5:
					zoom -= Vector2(0.1, 0.1)
					camera.zoom = zoom
		elif event is InputEventMouseMotion:
			if Input.is_mouse_button_pressed(MOUSE_BUTTON_MIDDLE):
				var viewport = get_viewport_rect()
				var viewport_position = viewport.position
				var viewport_size = viewport.size
				var x_position = event.relative.x * 1 / camera.zoom.x
				var y_position = event.relative.y * 1 / camera.zoom.y
				var camera_position = camera.position - Vector2(x_position, y_position)
				camera.position = Vector2(
					clamp(camera_position.x, viewport_position.x, viewport_position.x + viewport_size.x),
					clamp(camera_position.y, viewport_position.y, viewport_position.y + viewport_size.y)
				)

func _on_game_field_game_won() -> void:
	game_controls.hide()
	game_won_canvas.show()
	pass
