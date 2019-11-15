extends HBoxContainer

var text:String setget set_text,get_text

signal back_pressed

func _ready():
	var _text = text
	pass


func set_text(txt):
	$LabelTitle.set_text(txt)
	$LabelTitle.set_width_auto()
	
func get_text():
	return $LabelTitle.text

func _on_BackButton_pressed():
	emit_signal("back_pressed")
