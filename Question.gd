extends Control



func _ready():
	if $"/root/GlobalVars".active_lessons == ['']:
		$"/root/GlobalVars".active_lessons = ['lesson0']#TODO: find the latest added lesson
	

func go_back():
	var _err = get_tree().change_scene('res://MainMenu.tscn')
	

#INput handling
func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			go_back()

func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		# For Windows
		pass        
	if what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST: 
		# For android
		go_back()