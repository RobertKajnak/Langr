extends Control


func _ready():
	pass # Replace with function body.

func display(title,description):
	set_title(title)
	set_description(description)
	$PopupDialog.popup()

func set_title(text):
	$PopupDialog/Title.text = text
	
func set_description(text):
	$PopupDialog/Description.text = text
	
func _on_PopupDialog_popup_hide():
	queue_free()
