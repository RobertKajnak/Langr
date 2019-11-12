extends Control

var ratio = 0.75
var margin_ratio = 0.05

func _ready():
	pass # Replace with function body.

func display(title,description):
	var RR = get_viewport_rect().size*(ratio-margin_ratio*2)
	var MR = get_viewport_rect().size*margin_ratio
	
	$PopupDialog/VBoxContainer.rect_size = RR
	$PopupDialog/VBoxContainer.rect_position = Vector2(MR.x,MR.x)
	
	if title:
		$PopupDialog/VBoxContainer/Title.set_mode('normal')
		set_title(title)
		$PopupDialog/VBoxContainer/Title.set_width(RR.x)
	else:
		$PopupDialog/VBoxContainer/Title.visible = false
	
	if description:
		$PopupDialog/VBoxContainer/Description.set_mode('small')
		set_description(description)
		$PopupDialog/VBoxContainer/Description.set_width(RR.x)
	else:
		$PopupDialog/VBoxContainer/Description.visible = false
	
	$PopupDialog.popup_centered_ratio(ratio)
	
	
func get_container():
	return $PopupDialog/VBoxContainer/ScrollContainer/VBoxContainer

func set_title(text):
	$PopupDialog/VBoxContainer/Title.text = text
	
func set_description(text):
	$PopupDialog/VBoxContainer/Description.text = text
	
func _on_PopupDialog_popup_hide():
	queue_free()
	
func add_extra(node):
	$PopupDialog/VBoxContainer/ScrollContainer/VBoxContainer.add_child(node)
