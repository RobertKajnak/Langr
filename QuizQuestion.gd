extends Control

var global
var qm
var current_question

func _ready():
	qm = $"/root/QuestionManager"
	global = $"/root/GlobalVars"
	if qm._all_questions == []:
		get_node("/root/GlobalVars").current_lesson = 'lesson0'
		qm.load_questions()
		
	current_question = qm.get_next_question_to_ask()
	$VBoxContainer/LabelLessonTitle.text = global.current_lesson
	$VBoxContainer/LabelQuestion.text = current_question['question']
	
	if 'answer_free' in current_question:
		print('Adding free form answer input')
		var te = load('res://TextEditFreeForm.tscn').instance()
		$VBoxContainer/ScrollContainerAnswers/VBoxContainerAnswers.add_child(te)
		te.text=''
	if 'answer_draw' in current_question:
		print('Adding draw box to question')
		var dr = load('res://DrawBox.tscn').instance()
		$VBoxContainer/ScrollContainerAnswers/VBoxContainerAnswers.add_child(dr)

func go_back():
	var _err = get_tree().change_scene('res://MainMenu.tscn')
	

#INput handling
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

func _on_ButtonCheck_pressed():
	get_tree().change_scene('res://QuizAnswer.tscn')
