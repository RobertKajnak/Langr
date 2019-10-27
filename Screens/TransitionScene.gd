extends Control

var global

func _ready():
	global = $"/root/GlobalVars"
	$CenterContainer/VBoxContainer/Label.text = tr(global._transition_title)
	$CenterContainer/VBoxContainer/LabelMessage.text = tr(global._transition_message)
	#print($CenterContainer/VBoxContainer/LabelMessage.rect_position)
	
func go_back():
	var _err = get_tree().change_scene('res://Screens/MainMenu.tscn')

func perform_transition():
	var _err = get_tree().change_scene(global._transition_goal)


#%% Input handling
func _on_TransitionScene_gui_input(event):
	if event is InputEventMouseButton:
		perform_transition()

func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			go_back()
		else:
			perform_transition()
			
func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		# For Windows
		pass        
	if what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST: 
		# For android
		go_back()
