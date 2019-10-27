extends Control

var global
var qm
var current_question

#var to_translate = {}

var dr_answer
var temp_answer
#var correct_dr_answer 

func _ready():
	qm = $"/root/QuestionManager"
	global = $"/root/GlobalVars"
	#global.retranslate($VBoxContainer,to_translate)
	
	current_question = global.current_question
	$VBoxContainer/HeaderContainer/LabelLessonTitle.text = global.get_active_lessons_string()
	$VBoxContainer/LabelQuestion.text = current_question['question']
	$VBoxContainer/LabelQuestion/Label.add_color_override("font_color",global.skill_color_dict[int(current_question['skill'])])
	
	temp_answer = qm.get_temp_answer()
	print(temp_answer)
	var answer_color
	if 'answer_free' in current_question and 'answer_free' in temp_answer and \
		current_question['answer_free'] == temp_answer['answer_free']:
			answer_color = Color(0.1,0.9,0.2) 
	else:
		 answer_color = Color(0.7,0.1,0.1)
	if 'answer_free' in current_question:
		for txt in ['Expected Answer:',
					'      ' + current_question['answer_free'],
					'Given Answer:',
					'      ' + temp_answer['answer_free']]:
			var label = load('res://Interface/TextDisplay/LabelAdaptive.tscn').instance()
			$VBoxContainer/ScrollContainerAnswers/VBoxContainerAnswers.add_child(label)
			label.text = txt
			label.get_node('Label').add_color_override('font_color',answer_color)
			label.set_mode(label.LABEL_MODE_SMALL)
		#var te = load('res://Interface/TextDisplay/TextEditFreeForm.tscn').instance()
		#$VBoxContainer/ScrollContainerAnswers/VBoxContainerAnswers.add_child(te)
		#te.text = current_question['answer_free']
		
	
	if 'answer_draw' in current_question:
		var cc = CenterContainer.new()
		cc.size_flags_horizontal = cc.SIZE_EXPAND_FILL
		dr_answer = load('res://Interface/Input/DrawBox.tscn').instance()
		$VBoxContainer/ScrollContainerAnswers/VBoxContainerAnswers.add_child(cc)
		cc.add_child(dr_answer)
		
		display_answers()
		

func display_answers(only_correct = false):
	#if not correct_dr_answer:
	var fns = current_question['answer_draw']
	var temp_answer_cache = temp_answer['answer_draw']
	var dr_internal = dr_answer.find_node('AnswerDraw')
	if fns is String:
		fns = [fns]
		
	var lim = max(temp_answer_cache.size(),fns.size())
	for i in range(lim):
		if i<fns.size():
			dr_internal.change_line_color_to(Color(0,0.8,0.2,0.6),9)
			var drawing_file_name = 'user://lessons/' + qm.get_lesson_for_question(current_question,true) \
									+ '/' + fns[i]
			dr_internal.load_drawing(drawing_file_name)
			#var correct_dr_answer = dr_answer.get_lines()
		#else:
		#	dr_answer.add_lines(correct_dr_answer)	
		if (not only_correct) and i<temp_answer_cache.size():
			dr_internal.change_line_color_to(Color(0.4,0.1,0.6),3)
			
			
			dr_internal.change_line_color_to()
			dr_answer.add_lines(temp_answer_cache[i][0])
		if i<lim-1:
			dr_internal.load_next_cached()
	dr_internal.load_chached(0)
	dr_internal.change_line_color_to(Color(0.4,0.1,0.6),3)
	dr_answer.disable_add_drawing()
	dr_answer.set_cache_status_label()
	
func go_back():
	qm.exit_quiz()
	var _err = get_tree().change_scene('res://Screens/MainMenu.tscn')
	

#INput handling
func _on_ButtonForceIncorrect_pressed():
	qm.update_question_skill(current_question,-2)
	var _err = get_tree().change_scene('res://Screens/QuizQuestion.tscn')

func _on_ButtonForceCorrect_pressed():
	qm.update_question_skill(current_question,2)
	var _err = get_tree().change_scene('res://Screens/QuizQuestion.tscn')

func _on_ButtonOnlyCorrect_pressed():
	dr_answer.clear_drawing()
	display_answers(true)


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
