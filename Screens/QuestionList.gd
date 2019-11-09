extends Control

var current_lesson
var title_original

var qm
var global
var cd

var sorted_questions = []

var to_translate = {'LabelSort':'sortBy',
					'TextEditSearch':'search'}


func _ready():
	global = $"/root/GlobalVars"
	global.retranslate($VBoxContainer,to_translate)
	
	qm = $"/root/QuestionManager"
	
	current_lesson = global.current_lesson
	title_original = current_lesson
	$VBoxContainer/HeaderContainer/LabelTitle.text = current_lesson
	$VBoxContainer/HeaderContainer/LabelTitle.set_text_size(global.FONT_SIZE_MEDIUM)
	print('Opened ' + current_lesson)
	$VBoxContainer/HBoxContainerSearch/LabelSort.set_width(200)

	var searchBar = $VBoxContainer/HBoxContainerSearch/TextEditSearch
	var _err = searchBar.connect("focus_entered",self,"_tapped_to_edit",[searchBar])
	_err = searchBar.connect("focus_exited",self,"_tapped_away",[searchBar])
	
	for crit in qm.SORT_MODES:
		for dir in ['↓','↑']:
			$VBoxContainer/HBoxContainerSearch/OptionButtonSort.add_item(dir+tr(crit))
	
	$VBoxContainer/HBoxContainerSearch/OptionButtonSort.adapt()
	#var lesson_file = File.new()
	#if not lesson_file.file_exists('user://lessons/' + current_lesson +'.les'):
	#	_err = get_tree().change_scene('res://Screens/MainMenu.tscn')
	#lesson_file.close()
	
	qm.load_questions()
	$VBoxContainer/HBoxContainerSearch/OptionButtonSort.select(global.question_sort_mode)
	_on_OptionButtonSort_item_selected(global.question_sort_mode)
	
	cd = preload('res://Interface/Interactive/ConfirmationDialog.tscn').instance()
	$VBoxContainer.add_child(cd)
		
	cd.set_contents(tr('confirmDeleteLessonTitle'),tr('confirmDeleteLessonMessage').format({'lesson':current_lesson}))
	cd.connect("OK",self,"_delete_current_lesson")

#%% Helper functions
func go_back():
	if get_node("VBoxContainer/HeaderContainer/LabelTitle") == null:
		push_warning('Title was null')
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

func populate_with_questions(questions):
	for child in $VBoxContainer/ScrollContainer/VBoxContainer.get_children():
		$VBoxContainer/ScrollContainer/VBoxContainer.remove_child(child)
	for question in questions:
		var questionButton = preload("res://Interface/Buttons/SelectLessonButton.tscn").instance()
		$VBoxContainer/ScrollContainer/VBoxContainer.add_child(questionButton)
		if not ('good_answer_date' in question) and not('bad_answer_date' in question):
			questionButton.add_color_override("font_color",global.skill_color_dict[null])
		else:
			questionButton.add_color_override("font_color",global.skill_color_dict[int(question['skill'])])
		questionButton.set_label(question['question'])
		questionButton.auto_ellipse(get_viewport_rect().size.x*0.85)
		questionButton.connect("pressed",self,'_on_question_prerssed',[questionButton.original_text])

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
	q.load_data('user://lessons/' + current_lesson +'.les', question_text,global.DEBUG)
	
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
	var fd = global.create_file_dialog(get_viewport_rect(),get_node('.'),FileDialog.MODE_SAVE_FILE)
	fd.connect("file_selected",self,"export_lesson_to_file")
	disable_scroll()
	#fd.connect("mouse_entered",self,"disable_scroll")
	#fd.connect("confirmed",self,"enable_scroll")
	#fd.connect("mouse_exited",self,"enable_scroll")

func disable_scroll():
	print('disabled')
	$VBoxContainer/ScrollContainer.scroll_vertical_enabled = false

func enable_scroll():
	print("enabled")
	$VBoxContainer/ScrollContainer.scroll_vertical_enabled = true

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
func _tapped_to_edit(control):
	if control.text == tr(to_translate[control.name]):
		control.text = ''
		
func _tapped_away(control):
	if control.text == '':
		control.text = tr(to_translate[control.name])
	
func _on_TextEditSearch_text_changed():
	var tes :String= $VBoxContainer/HBoxContainerSearch/TextEditSearch.text
	sorted_questions = qm.get_questions()
	if tes != tr(to_translate['TextEditSearch']) and tes != '':
		sorted_questions = qm.fitler_quesiton_list(sorted_questions,tes)
	
	populate_with_questions(sorted_questions)

func _on_OptionButtonSort_item_selected(ID):
	sorted_questions = qm.get_questions().duplicate()
	match ID/2:
		1: sorted_questions.sort_custom(qm,'sort_alphabetical')
		2: sorted_questions.sort_custom(qm,'sort_skill')
		_: pass
	if ID%2==1:
		sorted_questions.invert()
	populate_with_questions(sorted_questions)
	if 	global.question_sort_mode != ID:
		global.question_sort_mode = ID
		global.save_settings()
		
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



