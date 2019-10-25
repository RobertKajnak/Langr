extends Control

var checkBoxes = []
var to_translate = {'LabelLesson':'lessonList',
					'LabelCheckActiveLessons':'checkActiveLessons',
					}
var global 
func _ready():
	global = $"/root/GlobalVars"
	global.retranslate($VBoxContainer,to_translate)
	
	$VBoxContainer/LabelLesson/LabelTitle.rect_size = Vector2($VBoxContainer.rect_size.x,60)
	$VBoxContainer/LabelCheckActiveLessons/LabelSmall.rect_size = Vector2($VBoxContainer.rect_size.x,60)
	
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
		var lessonButton = load("res://Buttons/SelectLessonButton.tscn").instance()
		
		box.add_child(checkBox)
		box.add_child(lessonButton)
		$VBoxContainer/ScrollContainer/VBoxContainer.add_child(box)
		
		#TODO: change f to title in f
		lessonButton.call('set_label',f.substr(0,f.find_last('.')))
		lessonButton.connect("pressed",self,'_on_lesson_pressed',[lessonButton.text])

#%% Helper functions
func go_back():
	change_active_lessons()
	var _err = get_tree().change_scene('res://MainMenu.tscn')

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
	get_node("/root/GlobalVars").current_lesson = lesson_name
	var _err = get_tree().change_scene('res://QuestionList.tscn')

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
