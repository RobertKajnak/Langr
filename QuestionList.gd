extends Control

var current_lesson


func _ready():
	current_lesson = get_node("/root/GlobalVars").current_lesson
	$VBoxContainer/LabelTitle.text = current_lesson
	print('Opened ' + current_lesson)
	
	var lesson_file = File.new()
	if not lesson_file.file_exists('user://lessons/' + current_lesson +'.les'):
		var _err = get_tree().change_scene('res://MainMenu.tscn')
		

#%% Helper functions
func go_back():
	var _err = get_tree().change_scene('res://Manage.tscn')


#%% Interface handling
func _on_ButtonAddWord_pressed():
	var _err = get_tree().change_scene($VBoxContainer/ButtonAddWord.scene_to_load)

func _on_ButtonDeleteLesson_pressed():
	print('Deleting lesson: ' + current_lesson)
	var dir = Directory.new()
	dir.remove('user://lessons/' + current_lesson + '.les')
	current_lesson = ''
	get_node("/root/GlobalVars").current_lesson = current_lesson
	go_back()


#%% Input handling
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
