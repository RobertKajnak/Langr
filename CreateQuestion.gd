extends Control

var to_translate = {'TextEditQuestion':'questionPlaceholder',
					'AnswerTextEdit':'answerTextPlaceholder','LabelDraw':'drawLabel'}



func _ready():
	$"/root/GlobalVars".retranslate($VBoxContainer,to_translate)
	for control in [$VBoxContainer/ScrollContainer/VBoxContainer/TextEditQuestion,
					$VBoxContainer/ScrollContainer/VBoxContainer/AnswerTextEdit]:
		var _err = control.connect("focus_entered",self,"_tapped_to_edit",[control])
		control.connect("focus_exited",self,"_tapped_away",[control])

#%% Helper functions
func go_back():
	var _err = get_tree().change_scene('res://WordList.tscn')

#%% Interface handling
func _tapped_to_edit(control):
	if control.text == tr(to_translate[control.name]):
		control.text = ''
		
func _tapped_away(control):
	if control.text == '':
		control.text = tr(to_translate[control.name])



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
		var _err = get_tree().change_scene('res://WordList.tscn')