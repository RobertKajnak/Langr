extends Control

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
	
	title_original = global.current_lesson
	$VBoxContainer/HeaderContainer/LabelTitle.text = global.current_lesson
	$VBoxContainer/HeaderContainer/LabelTitle.set_text_size(global.FONT_SIZE_MEDIUM)
	print('Opened ' + global.current_lesson)
	
	$VBoxContainer/SearchBar.add_options(qm.SORT_MODES)
	#var lesson_file = File.new()
	#if not lesson_file.file_exists('user://lessons/' + current_lesson +'.les'):
	#	_err = get_tree().change_scene('res://Screens/MainMenu.tscn')
	#lesson_file.close()
	
	qm.load_questions()
	$VBoxContainer/SearchBar.select(global.question_sort_mode)
	_on_OptionButtonSort_item_selected(global.question_sort_mode)
	
	cd = preload('res://Interface/Interactive/ConfirmationDialog.tscn').instance()
	$VBoxContainer.add_child(cd)
		
	cd.set_contents(tr('confirmDeleteLessonTitle'),tr('confirmDeleteLessonMessage').format({'lesson':global.current_lesson}))
	cd.connect("OK",self,"_delete_current_lesson")

#%% Helper functions
func save_lesson_title():
	"""Returns true on success"""
	var new_title = $VBoxContainer/HeaderContainer/LabelTitle.text
	if global.current_lesson =='' or new_title == '' or new_title == title_original or \
			global.change_lesson_name(global.current_lesson,new_title) == 0:
		print("Attempting to change lesson title to: ",new_title," successfully completed")
		title_original = new_title
		global.current_lesson = new_title
		
		#Refreshes the lessons names, etc. in the question manager
		qm.load_questions() 
		return true
	else:
		print("Attempting to change lesson title to: ",new_title," failed")
		var popup = preload("res://Interface/Interactive/ErrorPopup.tscn").instance()
		add_child(popup)
		popup.display(tr('lessonAlreadyExitsTitle'),tr('lessonAlreadyExitsMessage'))
		return false

func go_back():
	if get_node("VBoxContainer/HeaderContainer/LabelTitle") == null:
		push_warning('Title was null')
		var _err = get_tree().change_scene('res://Screens/Manage.tscn')
		return
	if save_lesson_title():
		var _err = get_tree().change_scene('res://Screens/Manage.tscn')

#%% Interface handling
func _on_question_prerssed(question_text):
	#var root = get_tree().get_root() #--This variant makes the app get stuck in that scene
	#var current_scene = root.get_child(root.get_child_count() -1)
	#current_scene.queue_free()
	
	#root.add_child(q)
	if save_lesson_title():
		var q = load('res://Screens/CreateQuestion.tscn').instance()

		for node in [$VBoxContainer,$Sprite]:
			remove_child(node)
			node.call_deferred("free")
		
		add_child(q)
		q.load_data('user://lessons/' + global.current_lesson +'.les', question_text,global.DEBUG)
		

	
func _on_ButtonAddWord_pressed():
	if save_lesson_title():
		var _err = get_tree().change_scene('res://Screens/CreateQuestion.tscn')
	
func export_lesson_to_file(filename):
	var popup = preload("res://Interface/Interactive/ErrorPopup.tscn").instance()
	add_child(popup)
	if global.export_lesson(filename,global.current_lesson):
		popup.display(tr('fileSaveSuccessTitle'),tr('fileSaveSuccessMessage').format({'filename':filename.replace('/','/ ')}))
	else:
		popup.display(tr('fileSaveFailTitle'),tr('fileSaveFailMessage'))
		

func _on_Export_pressed():
	var fd
	if OS.get_name() in ["Android"]:
		if not global.check_if_folder_ok_android():
			var popup = preload("res://Interface/Interactive/ErrorPopup.tscn").instance()
			add_child(popup)
			popup.display(tr('fileSaveFailTitle'),tr('fileSaveFailMessage'))
		else:
			fd = preload("res://Interface/Interactive/FileDialogRestricted.tscn").instance()
			get_node('.').add_child(fd)
			fd.load_folder(global.ANDROID_PATH,true,tr("chooseFilename"),'',true)#tr("saveProgress")
	else:
		disable_scroll()
		fd = global.create_file_dialog(get_viewport_rect(),get_node('.'),FileDialog.MODE_SAVE_FILE)
	
	fd.connect("file_selected",self,"export_lesson_to_file")
	#fd.connect("mouse_entered",self,"disable_scroll")
	#fd.connect("confirmed",self,"enable_scroll")
	#fd.connect("mouse_exited",self,"enable_scroll")

func disable_scroll():
	print('Scroll disabled')
	$VBoxContainer/ScrollContainer.scroll_vertical_enabled = false

func enable_scroll():
	print("Scroll enabled")
	$VBoxContainer/ScrollContainer.scroll_vertical_enabled = true

func _on_ButtonDeleteLesson_pressed():

	var vpp = get_viewport_rect().size
	cd.rect_position = (vpp-cd.rect_size)/2
	cd.popup()

func _delete_current_lesson():
	print('Deleting lesson: ' + global.current_lesson)
	global.delete_lesson(global.current_lesson)
	global.current_lesson = ''
	go_back()
	


#%% Input handling	
func _on_TextEditSearch_text_changed(tes):
	sorted_questions = qm.get_questions()
	if tes != tr(to_translate['TextEditSearch']) and tes != '':
		sorted_questions = qm.fitler_quesiton_list(sorted_questions,tes)
	
	var links = global.populate_with_links(sorted_questions,$VBoxContainer/ScrollContainer/VBoxContainer,true,get_viewport_rect().size.x*0.85)
	for link in links:
		link.connect("pressed",self,'_on_question_prerssed',[link.original_text])

func _on_OptionButtonSort_item_selected(ID):
	sorted_questions = qm.get_questions().duplicate()
	match ID/2:
		1: sorted_questions.sort_custom(qm,'sort_alphabetical')
		2: sorted_questions.sort_custom(qm,'sort_skill')
		_: pass
	if ID%2==1:
		sorted_questions.invert()
	
	var links = global.populate_with_links(sorted_questions,$VBoxContainer/ScrollContainer/VBoxContainer,true,get_viewport_rect().size.x*0.85)
	for link in links:
		link.connect("pressed",self,'_on_question_prerssed',[link.original_text])
	
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





func _on_LabelTitle_focus_exited():
	save_lesson_title()
