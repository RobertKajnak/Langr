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
		
	var title_string = str(qm.get_lesson_for_question(current_question))
	title_string = title_string.substr(0,title_string.rfind('.'))
	if global.active_lessons.size()>1:
		title_string += ' [' + global.get_active_lessons_string(20) + ']'
	$VBoxContainer/HeaderContainer/LabelLessonTitle.text =  title_string
	
	$VBoxContainer/LabelQuestion.set_mode('small')
	$VBoxContainer/LabelQuestion.text = current_question['question']
	
	if 'answer_free' in current_question:
		te_answer = load('res://Interface/Input/TextEditFreeForm.tscn').instance()
		$VBoxContainer/ScrollContainerAnswers/VBoxContainerAnswers.add_child(te_answer)
		te_answer.text=''
	if 'answer_draw' in current_question:
		var cc = CenterContainer.new()
		cc.size_flags_horizontal = cc.SIZE_EXPAND_FILL
		dr_answer = load('res://Interface/Input/DrawBox.tscn').instance()
		$VBoxContainer/ScrollContainerAnswers/VBoxContainerAnswers.add_child(cc)
		cc.add_child(dr_answer)
		var nr_drawings = current_question['answer_draw']
		if nr_drawings is String:
			nr_drawings = 1
		else:
			nr_drawings = nr_drawings.size()
		dr_answer.create_empty_drawings(nr_drawings-1)
		dr_answer.disable_add_drawing()
	
	
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
	var temp_answer = {'answer_free':''}
	if te_answer:
		temp_answer['answer_free']=te_answer.text
	if dr_answer:
		temp_answer['answer_draw']=dr_answer.get_lines()
		
	qm.set_temp_answer(temp_answer)
	var _err = get_tree().change_scene('res://Screens/QuizAnswer.tscn')


func _on_QuizQuestionRoot_resized():
	var vpr = get_viewport_rect()
	#print('new size = ',vpr)
	$VBoxContainer.rect_position = Vector2(vpr.size.x*0.05,vpr.size.y*0.05)
	$VBoxContainer.rect_size = vpr.size*0.9
	$VBoxContainer.rect_min_size = vpr.size*0.9
	
	if te_answer:
		te_answer.rect_size.x = vpr.size.x*0.85
	
