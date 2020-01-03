extends Control

func _ready():
	randomize() #Randomizes the seed for the RNG. One line of code shall be sacrificed to the RNG Gods
	
	#Check and create the lesson, dictionaries etc. folders exits
	$"/root/GlobalVars".create_folder_tree()
	
	#get_tree().set("display/window/stretch/aspect","Keep")
	for control in $CenterContainer/VBoxContainer2/VBoxContainer.get_children():
		if "Button" in control.name:
			control.connect("pressed",self,"_on_ButtonStart_pressed",[control.scene_to_load])
			
func has_valid_extension(file_name,filter):
	if filter == null:
		return true
	else:
		if filter is String:
			filter = [filter]
		for ft in filter:
			if ft[0] != '.':
				ft = '.' + ft
			if file_name.substr(file_name.length()-ft.length(),ft.length()) == ft:
				return true
	return false
#%% Interface handling
func _on_ButtonStart_pressed(to_load):
	if to_load == 'res://Screens/QuizQuestion.tscn':
		$"/root/QuestionManager".load_lessons_for_quiz()
		
	var _err = get_tree().change_scene(to_load)


#%% Input handling
func _unhandled_input(event):
    if event is InputEventKey:
        if event.pressed and event.scancode == KEY_ESCAPE:
            get_tree().quit()
			
func _notification(what):
    if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
        # For Windows
        pass        
    if what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST: 
        # For android
        get_tree().quit()