extends Control



func _ready():
	$VBoxContainer/LabelLesson.text = tr('lessonList')
	var files = list_files_in_directory('res://data/lessons')
	for f in files:
		var lessonButton = load("res://Buttons/SelectLessonButton.tscn")
		lessonButton.set("label",f)
		$VBoxContainer/ScrollContainer/VBoxContainer.add_child(lessonButton.instance())
		#lessonButton.call('set_label')
		


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

