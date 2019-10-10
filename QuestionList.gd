extends Control

var current_lesson

var all_questions = []

func _ready():
	current_lesson = get_node("/root/GlobalVars").current_lesson
	$VBoxContainer/LabelTitle.text = current_lesson
	print('Opened ' + current_lesson)
	
	var lesson_file = File.new()
	if not lesson_file.file_exists('user://lessons/' + current_lesson +'.les'):
		var _err = get_tree().change_scene('res://MainMenu.tscn')
	
	
	var adict = $"/root/GlobalVars".adict;
	lesson_file.open('user://lessons/' + current_lesson +'.les', File.READ)
	while not lesson_file.eof_reached():
		var question = parse_json(lesson_file.get_line())
		if question == null:
			break
		var questionButton = preload("res://Buttons/SelectLessonButton.tscn").instance()
		$VBoxContainer/VBoxContainer.add_child(questionButton)
		#questionButton.call('set_label',f.substr(0,f.find_last('.')))
		#questionButton.connect("pressed",self,'_on_lesson_pressed',[lessonButton.text])
		questionButton.text = question['question']
		all_questions.append(question['question'])
	lesson_file.close()

#%% Helper functions
func go_back():
	var _err = get_tree().change_scene('res://Manage.tscn')


#%% Interface handling
func _on_ButtonAddWord_pressed():
	$"/root/GlobalVars".all_questions = all_questions
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
