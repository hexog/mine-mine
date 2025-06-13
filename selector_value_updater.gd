extends Control

@onready var value_label: Label = $Value
@onready var slider: HSlider = $Slider

var value:
	get():
		return slider.value

func _on_slider_value_changed(_value: float) -> void:
	value_label.text = "%d" % _value
