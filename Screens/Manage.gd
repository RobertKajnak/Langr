extends Control

var checkBoxes = []
var to_translate = {'LabelLesson':'lessonList',
					'LabelCheckActiveLessons':'checkActiveLessons',
					}
var global 

var lesson_container

func _ready():
	global = $"/root/GlobalVars"
	global.retranslate($VBoxContainer,to_translate)
	
	$VBoxContainer/HeaderContainer/LabelLesson/Label.rect_size = Vector2($VBoxContainer.rect_size.x,60)
	$VBoxContainer/LabelCheckActiveLessons/Label.rect_size = Vector2($VBoxContainer.rect_size.x,60)
	$VBoxContainer/LabelCheckActiveLessons.set_mode('small')
	
	lesson_container = $VBoxContainer/ScrollContainer/VBoxContainer
	populate_with_lessons(lesson_container)

#%% Helper functions
func populate_with_lessons(node):
	var lesson_directory = Directory.new()
	if not lesson_directory.dir_exists('user://lessons/'):
		lesson_directory.make_dir('user://lessons')
	
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
	print('Opening lesson: ' + lesson_name)
	change_active_lessons()
	global.current_lesson = lesson_name
	var _err = get_tree().change_scene('res://Screens/QuestionList.tscn')


func import_lesson(filename):
	var popup = preload("res://Interface/Interactive/ErrorPopup.tscn").instance()
	add_child(popup)
	if global.import_lesson(filename):
		popup.display(tr('importSuccessTitle'),tr('importSuccessMessage').format({'filename':filename}))
		#for child in lesson_container.get_children():
		#	lesson_container.remove_child(child)
		#	child.queue_free()
		#populate_with_lessons(lesson_container)
		go_back()
	else:
		popup.display(tr('importFailTitle'),tr('importFailMessage'))
		

func _on_ButtonImport_pressed():
	var fd = global.create_file_dialog(get_viewport_rect(),get_node('.'),FileDialog.MODE_OPEN_FILE)
	fd.connect("file_selected",self,"import_lesson")
	

func _on_ButtonAddLesson_pressed():
	change_active_lessons()
	print('Creating lesson')
	var lesson_file = File.new()
	var i =0;
	var fn = 'user://lessons/lesson'+ str(i) +'.les'
	while lesson_file.file_exists(fn):
		i += 1
		fn = 'user://lessons/lesson'+ str(i) +'.les'
	
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


