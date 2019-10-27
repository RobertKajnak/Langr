extends Control

var current_lesson

var question_manager
var global

func _ready():
	global = $"/root/GlobalVars"
	current_lesson = global.current_lesson
	$VBoxContainer/HeaderContainer/LabelTitle.text = current_lesson
	print('Opened ' + current_lesson)
	
	var lesson_file = File.new()
	if not lesson_file.file_exists('user://lessons/' + current_lesson +'.les'):
		var _err = get_tree().change_scene('res://Screens/MainMenu.tscn')
	
	question_manager = $"/root/QuestionManager"
	question_manager.load_questions()
	for question in question_manager.get_question_titles():
		var questionButton = preload("res://Interface/Buttons/SelectLessonButton.tscn").instance()
		$VBoxContainer/ScrollContainer/VBoxContainer.add_child(questionButton)
		#questionButton.call('set_label',f.substr(0,f.find_last('.')))
		questionButton.set_label(question)
		questionButton.connect("pressed",self,'_on_question_prerssed',[questionButton.text])
	lesson_file.close()

#%% Helper functions
func go_back():
	var _err = get_tree().change_scene('res://Screens/Manage.tscn')


#%% Interface handling
func _on_question_prerssed(question_text):
	#var root = get_tree().get_root() #--This variant makes the app get stuck in that scene
	#var current_scene = root.get_child(root.get_child_count() -1)
	#current_scene.queue_free()
	
	#root.add_child(q)
	var q = load('res://Screens/CreateQuestion.tscn').instance()
	
	for node in [$VBoxContainer,$Sprite]:
		remove_child(node)
		node.call_deferred("free")
	
	add_child(q)
	q.load_data('user://lessons/' + current_lesson +'.les', question_text)
	
func _on_ButtonAddWord_pressed():
	var _err = get_tree().change_scene('res://Screens/CreateQuestion.tscn')

func _on_ButtonDeleteLesson_pressed():
	print('Deleting lesson: ' + current_lesson)
	var dir = Directory.new()
	var dir_name = 'user://lessons/' + current_lesson
	dir.remove(dir_name + '.les')
	#remove all files from the directory first, otherwise the request will fail
	for f in global.list_files_in_directory(dir_name):
		dir.remove(dir_name + '/' + f)
	dir.remove(dir_name)
	current_lesson = ''
	global.current_lesson = current_lesson
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
