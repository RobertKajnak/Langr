extends PopupDialog

signal OK
signal Cancel


func _ready():
	#$VBoxContainer/VBoxContainerText.rect_min_size = get_node('.').rect_size - Vector2(200,200)
	$VBoxContainer/VBoxContainerText.rect_size = get_node('.').rect_size - Vector2(200,200)
	$VBoxContainer/HBoxContainer/ButtonCancel.grab_focus()
	
func set_contents(title, message):
	$VBoxContainer/VBoxContainerText/LabelTitle.text = title
	$VBoxContainer/VBoxContainerText/LabelMessage.text = message
	

func _on_ButtonOK_pressed():
	emit_signal("OK")

func _notification(notif):
	if notif == NOTIFICATION_POST_POPUP:
		$VBoxContainer/HBoxContainer/ButtonCancel.grab_focus()

func _on_ButtonCancel_pressed():
	emit_signal("Cancel")
	hide()
