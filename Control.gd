extends Control


func _ready():
	$VBoxContainer/LabelLesson.text = tr('lessonList')
	
	var lesson_directory = Directory.new()
	if not lesson_directory.dir_exists('user://lessons/'):
		lesson_directory.make_dir('user://lessons')
	
	var files = list_files_in_directory('user://lessons')
	for f in files:
		var lessonButton = preload("res://Buttons/SelectLessonButton.tscn").instance()
		$VBoxContainer/ScrollContainer/VBoxContainer.add_child(lessonButton)
		#TODO: change f to title in f
		lessonButton.call('set_label',f.substr(0,f.find_last('.')))
		lessonButton.connect("pressed",self,'_on_lesson_pressed',[lessonButton.text])


func list_files_in_directory(path):
    var files = []
    var dir = Directory.new()
    dir.open(path)
    dir.list_dir_begin()

    while true:
        var file = dir.get_next()
        if file == "":
            break
        elif not file.begins_with("."):
            files.append(file)

    dir.list_dir_end()

    return files


func _unhandled_input(event):
    if event is InputEventKey:
        if event.pressed and event.scancode == KEY_ESCAPE:
            get_tree().change_scene('res://MainMenu.tscn')

func _notification(what):
    if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
        # For Windows
        pass        
    if what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST: 
        # For android
        get_tree().change_scene('res://MainMenu.tscn')

func _on_lesson_pressed(lesson_name):
	print('Opening lesson: ' + lesson_name)
	get_node("/root/GlobalVars").current_lesson = lesson_name
	get_tree().change_scene('res://WordList.tscn')

func _on_ButtonAddLesson_pressed():
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

