extends Control

var current_lesson
# Called when the node enters the scene tree for the first time.
func _ready():
	current_lesson = get_node("/root/GlobalVars").current_lesson
	print('Opened ' + current_lesson)
	
	var lesson_file = File.new()
	if not lesson_file.file_exists('user://lessons/' + current_lesson +'.les'):
		get_tree().change_scene('res://MainMenu.tscn')
		


func _unhandled_input(event):
    if event is InputEventKey:
        if event.pressed and event.scancode == KEY_ESCAPE:
            get_tree().change_scene('res://Manage.tscn')

func _on_ButtonAddWord_pressed():
	pass # Replace with function body.


func _on_ButtonDeleteLesson_pressed():
	get_tree().change_scene($VBoxContainer/ButtonDeleteLesson.scene_to_load)
