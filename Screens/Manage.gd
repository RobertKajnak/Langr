extends Control

var checkBoxes = []
var to_translate = {'HeaderContainer':'lessonList',
					'LabelCheckActiveLessons':'checkActiveLessons',
					}
var global 

var lesson_container

func _ready():
	global = $"/root/GlobalVars"
	if GlobalVars.EINK:
		$Sprite.texture = null
	else:
		$Sprite.texture = preload('res://.import/Wood24.jpg-4a3597f20fd006272deaaf45f7635168.stex')
	
	global.retranslate($VBoxContainer,to_translate)
	
	
	
	$VBoxContainer/LabelCheckActiveLessons.set_width(get_viewport_rect().size.x*0.75)
	$VBoxContainer/LabelCheckActiveLessons.rect_size.y=0
	$VBoxContainer/LabelCheckActiveLessons/Label.rect_size.y=0
	$VBoxContainer/LabelCheckActiveLessons.set_mode('small')
	
	lesson_container = $VBoxContainer/ScrollContainer/VBoxContainer
	populate_with_lessons(lesson_container)
	
	if global.active_dict.empty():
		global.load_dictionary_contents()

#%% Helper functions
func populate_with_lessons(node):	
	var files = global.list_files_in_directory('user://lessons')
	for f in files:
		var box = HBoxContainer.new()
		var checkBox = CheckBox.new()
		checkBoxes.append([checkBox,f])
		box.rect_min_size.y = 0 #TODO: GYURI HEEELP!
		box.rect_size.y = 5
		checkBox.rect_min_size.y = 0
		checkBox.rect_min_size.x = 20
		checkBox.rect_size.y = 5
		checkBox.grow_horizontal = false
		checkBox.grow_vertical = false
		checkBox.rect_min_size= Vector2(60,60)
		checkBox.align = Button.ALIGN_CENTER
		
		if f in global.active_lessons:
			checkBox.pressed = true
		box.set('size_flags_vertical',0)
		checkBox.set('size_flags_vertical',0)
		#print(box.size_flags_vertical)
		var lessonButton = load("res://Interface/Buttons/SelectLessonButton.tscn").instance()
		
		box.add_child(checkBox)
		box.add_child(lessonButton)
		node.add_child(box)
		
		#TODO: change f to title in f
		lessonButton.call('set_label',f.substr(0,f.find_last('.')))
		lessonButton.connect("pressed",self,'_on_lesson_pressed',[lessonButton.text])

func go_back():
	change_active_lessons()
	var _err = get_tree().change_scene('res://Screens/MainMenu.tscn')

func change_active_lessons():
	var active_lessons = []
	for cb in checkBoxes:
		if cb[0].is_pressed():
			active_lessons.append(cb[1])
	global.set_active_lessons(active_lessons)

#%% Interface Handling
func _on_lesson_pressed(lesson_name):
	change_active_lessons()
	print('Opening lesson: ' + lesson_name)
	#change_active_lessons()
	global.current_lesson = lesson_name
	var _err = get_tree().change_scene('res://Screens/QuestionList.tscn')


func import_lesson(filename):
	var popup = preload("res://Interface/Interactive/ErrorPopup.tscn").instance()
	add_child(popup)
	if global.import_lesson(filename):
		#popup.display(tr('importSuccessTitle'),tr('importSuccessMessage').format({'filename':filename}))
		#for child in lesson_container.get_children():
		#	lesson_container.remove_child(child)
		#	child.queue_free()
		#populate_with_lessons(lesson_container)
		#go_back()
		
		change_active_lessons()
		global.to_transition_scene(get_tree(),'res://Screens/MainMenu.tscn',\
				tr('importSuccessTitle'),tr('importSuccessMessage').format({'lesson':filename.replace('/','/ ')}))
		
	else:
		popup.display(tr('importFailTitle'),tr('importFailMessage'))
		

func _on_ButtonImport_pressed():
	var fd
	if OS.get_name() in ["Android"]:
		if not global.check_if_folder_ok_android():
			var popup = preload("res://Interface/Interactive/ErrorPopup.tscn").instance()
			add_child(popup)
			popup.display(tr('fileSaveFailTitle'),tr('fileSaveFailMessage'))
		else:
			fd = preload("res://Interface/Interactive/FileDialogRestricted.tscn").instance()
			get_node('.').add_child(fd)
			fd.load_folder(global.ANDROID_PATH,'.les',false,tr("chooseFilename"),"",true)
	else:
		fd = global.create_file_dialog(get_viewport_rect(),get_node('.'),FileDialog.MODE_OPEN_FILE,["*.les ; Lesson File"])
	fd.connect("file_selected",self,"import_lesson")
	

func _on_ButtonAddLesson_pressed():
	change_active_lessons()
	print('Creating lesson')
	var lesson_file = File.new()
	var i =0;
	var fn = 'user://lessons/lesson'+ str(i) + global.LES_EXT
	while lesson_file.file_exists(fn):
		i += 1
		fn = 'user://lessons/lesson'+ str(i) + global.LES_EXT
	
	lesson_file.open(fn, File.WRITE)
	lesson_file.close()
	_on_lesson_pressed('lesson' + str(i))


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


