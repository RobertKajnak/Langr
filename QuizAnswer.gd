extends Control

var global
var qm
var current_question

#var to_translate = {}

var dr_answer
var correct_dr_answer 

func _ready():
	qm = $"/root/QuestionManager"
	global = $"/root/GlobalVars"
	#global.retranslate($VBoxContainer,to_translate)
	
	current_question = global.current_question
	$VBoxContainer/LabelLessonTitle.text = str(global.active_lessons)
	$VBoxContainer/LabelQuestion.text = current_question['question']
	
	var temp_answer = qm.get_temp_answer()
	if 'answer_free' in current_question:
		for txt in ['Expected Answer:',
					'      ' + current_question['answer_free'],
					'Given Answer:',
					'      ' + temp_answer['answer_free']]:
			var label = load('res://LabelAdaptiveSmall.tscn').instance()
			$VBoxContainer/ScrollContainerAnswers/VBoxContainerAnswers.add_child(label)
			label.text = txt
		#var te = load('res://TextEditFreeForm.tscn').instance()
		#$VBoxContainer/ScrollContainerAnswers/VBoxContainerAnswers.add_child(te)
		#te.text = current_question['answer_free']
		
	
	if 'answer_draw' in current_question:
		dr_answer = load('res://DrawBox.tscn').instance()
		$VBoxContainer/ScrollContainerAnswers/VBoxContainerAnswers.add_child(dr_answer)
		
		display_correct_answer()
		
		dr_answer.find_node('AnswerDraw').change_line_color_to()
		dr_answer.add_lines(temp_answer['answer_draw'])
		
		dr_answer.find_node('AnswerDraw').change_line_color_to(Color(0.4,0.1,0.6),3)

func display_correct_answer():
	dr_answer.find_node('AnswerDraw').change_line_color_to(Color(0,0.8,0.2,0.6),9)
	if not correct_dr_answer:
		var drawing_file_name = 'user://lessons/' + qm.get_lesson_for_question(current_question,true) \
								+ '/' + current_question['answer_draw']
		dr_answer.find_node('AnswerDraw').load_drawing(drawing_file_name)
		correct_dr_answer = dr_answer.get_lines()
	else:
		dr_answer.add_lines(correct_dr_answer)	
	dr_answer.find_node('AnswerDraw').change_line_color_to(Color(0.4,0.1,0.6),3)
	
func go_back():
	qm.exit_quiz()
	var _err = get_tree().change_scene('res://MainMenu.tscn')
	

#INput handling
func _on_ButtonForceIncorrect_pressed():
	qm.update_question_skill(current_question,-2)
	var _err = get_tree().change_scene('res://QuizQuestion.tscn')

func _on_ButtonForceCorrect_pressed():
	qm.update_question_skill(current_question,2)
	var _err = get_tree().change_scene('res://QuizQuestion.tscn')

func _on_ButtonOnlyCorrect_pressed():
	dr_answer.clear_drawing()
	display_correct_answer()


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
