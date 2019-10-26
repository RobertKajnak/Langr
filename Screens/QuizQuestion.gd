extends Control

var global
var qm
var current_question
var te_answer
var dr_answer

func _ready():
	qm = $"/root/QuestionManager"
	global = $"/root/GlobalVars"
	
	current_question = qm.get_next_question_to_ask()
	if not global.active_lessons:
		global.to_transition_scene(get_tree(),'res://Screens/Manage.tscn','noActiveLessons','noLessonsRedirect')
		return
	if not current_question:
		global.to_transition_scene(get_tree(),'res://Screens/Manage.tscn','noActiveQuestions','noQuestionsRedirect')
		return
		
		
	$VBoxContainer/LabelLessonTitle.text = str(global.active_lessons)
	$VBoxContainer/LabelQuestion.text = current_question['question']
	
	if 'answer_free' in current_question:
		te_answer = load('res://Interface/Input/TextEditFreeForm.tscn').instance()
		$VBoxContainer/ScrollContainerAnswers/VBoxContainerAnswers.add_child(te_answer)
		te_answer.text=''
	if 'answer_draw' in current_question:
		dr_answer = load('res://Interface/Input/DrawBox.tscn').instance()
		$VBoxContainer/ScrollContainerAnswers/VBoxContainerAnswers.add_child(dr_answer)

func go_back():
	qm.exit_quiz()
	var _err = get_tree().change_scene('res://Screens/MainMenu.tscn')
	

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
	var temp_answer = {}
	if te_answer:
		temp_answer['answer_free']=te_answer.text
	if dr_answer:
		temp_answer['answer_draw']=dr_answer.get_lines()
		
	qm.set_temp_answer(temp_answer)
	var _err = get_tree().change_scene('res://Screens/QuizAnswer.tscn')
