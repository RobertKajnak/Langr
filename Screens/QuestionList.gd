extends Control

var current_lesson
var title_original

var question_manager
var global
var cd

func _ready():
	global = $"/root/GlobalVars"
	current_lesson = global.current_lesson
	title_original = current_lesson
	$VBoxContainer/HeaderContainer/LabelTitle.text = current_lesson
	$VBoxContainer/HeaderContainer/LabelTitle.set_text_size(global.FONT_SIZE_MEDIUM)
	print('Opened ' + current_lesson)
	
	var lesson_file = File.new()
	if not lesson_file.file_exists('user://lessons/' + current_lesson +'.les'):
		var _err = get_tree().change_scene('res://Screens/MainMenu.tscn')
	
	question_manager = $"/root/QuestionManager"
	question_manager.load_questions()
	for question in question_manager.get_questions():
		var questionButton = preload("res://Interface/Buttons/SelectLessonButton.tscn").instance()
		$VBoxContainer/ScrollContainer/VBoxContainer.add_child(questionButton)
		if not ('good_answer_date' in question) and not('bad_answer_date' in question):
			questionButton.add_color_override("font_color",global.skill_color_dict[null])
		else:
			questionButton.add_color_override("font_color",global.skill_color_dict[int(question['skill'])])
		questionButton.set_label(question['question'])
		questionButton.connect("pressed",self,'_on_question_prerssed',[questionButton.text])
	lesson_file.close()
	
	cd = preload('res://Interface/Interactive/ConfirmationDialog.tscn').instance()
	$VBoxContainer.add_child(cd)

	cd.set_contents(tr('confirmDeleteLessonTitle'),tr('confirmDeleteLessonMessage').format({'lesson':current_lesson}))
	cd.connect("OK",self,"_delete_current_lesson")

#%% Helper functions
func go_back():
	if $VBoxContainer/HeaderContainer/LabelTitle == null:
		push_warning('TItle was null')
		var _err = get_tree().change_scene('res://Screens/Manage.tscn')
		return
	var new_title = $VBoxContainer/HeaderContainer/LabelTitle.text
	if current_lesson =='' or new_title == '' or new_title == title_original or \
			global.change_lesson_name(current_lesson,new_title) == 0:
		var _err = get_tree().change_scene('res://Screens/Manage.tscn')
	else:
		var popup = preload("res://Interface/Interactive/ErrorPopup.tscn").instance()
		add_child(popup)
		popup.display(tr('lessonAlreadyExitsTitle'),tr('lessonAlreadyExitsMessage'))


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

func export_lesson_to_file(filename):
	var popup = preload("res://Interface/Interactive/ErrorPopup.tscn").instance()
	add_child(popup)
	if global.export_lesson(filename,current_lesson):
		popup.display(tr('fileSaveSuccessTitle'),tr('fileSaveSuccessMessage').format({'filename':current_lesson}))
	else:
		popup.display(tr('fileSaveFailTitle'),tr('fileSaveFailMessage'))
		

func _on_Export_pressed():
	var fd = FileDialog.new()
	fd.set_theme( preload('res://res/DefaultJPTheme.tres'))
	var vps = get_viewport().size 
	fd.rect_size = vps * 0.8
	fd.rect_position = vps *0.1
	fd.set_mode_overrides_title(true)
	fd.access = FileDialog.ACCESS_FILESYSTEM
	fd.mode = FileDialog.MODE_SAVE_FILE
	fd.set_filters(PoolStringArray(["*.les ; Lesson File"]))
	get_node('.').add_child(fd)
	fd.show()
	fd.invalidate()#AKA Refresh
	fd.connect("file_selected",self,"export_lesson_to_file")

func _on_ButtonDeleteLesson_pressed():

	var vpp = get_viewport_rect().size
	cd.rect_position = (vpp-cd.rect_size)/2
	cd.popup()

func _delete_current_lesson():
	print('Deleting lesson: ' + current_lesson)
	global.delete_lesson(current_lesson)
	current_lesson = ''
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

