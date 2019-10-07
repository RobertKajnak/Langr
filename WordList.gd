extends Control

var current_lesson
# Called when the node enters the scene tree for the first time.
func _ready():
	current_lesson = get_node("/root/GlobalVars").current_lesson
	$VBoxContainer/LabelTitle.text = current_lesson
	print('Opened ' + current_lesson)
	
	var lesson_file = File.new()
	if not lesson_file.file_exists('user://lessons/' + current_lesson +'.les'):
		get_tree().change_scene('res://MainMenu.tscn')
		

func _unhandled_input(event):
    if event is InputEventKey:
        if event.pressed and event.scancode == KEY_ESCAPE:
            get_tree().change_scene('res://Manage.tscn')
func _notification(what):
    if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
        # For Windows
        pass        
    if what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST: 
        # For android
        get_tree().change_scene('res://Manage.tscn')


func _on_ButtonAddWord_pressed():
	get_tree().change_scene($VBoxContainer/ButtonAddWord.scene_to_load)


func _on_ButtonDeleteLesson_pressed():
	print('Deleting lesson: ' + current_lesson)
	var dir = Directory.new()
	dir.remove('user://lessons/' + current_lesson + '.les')
	current_lesson = ''
	get_tree().change_scene($VBoxContainer/ButtonDeleteLesson.scene_to_load)
