extends Control

var ratio = 0.75
func _ready():
	pass # Replace with function body.

func display(title,description):
	$PopupDialog/VBoxContainer/Title.set_mode('normal')
	$PopupDialog/VBoxContainer/Description.set_mode('small')
	set_title(title)
	set_description(description)
	$PopupDialog/VBoxContainer/Title/Label.rect_size = Vector2(get_viewport_rect().size.x*ratio,60)
	$PopupDialog/VBoxContainer/Description/Label.rect_size = Vector2(get_viewport_rect().size.x*ratio,60)
	$PopupDialog.popup_centered_ratio (ratio)
	

func set_title(text):
	$PopupDialog/VBoxContainer/Title.text = text
	
func set_description(text):
	$PopupDialog/VBoxContainer/Description.text = text
	
func _on_PopupDialog_popup_hide():
	queue_free()
