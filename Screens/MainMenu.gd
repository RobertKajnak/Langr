extends Control



func _ready():
	randomize() #Randomizes the seed for the RNG. One line of code shall be sacrificed to the RNG Gods
	for control in $CenterContainer/VBoxContainer2/VBoxContainer.get_children():
		if "Button" in control.name:
			control.connect("pressed",self,"_on_ButtonStart_pressed",[control.scene_to_load])

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