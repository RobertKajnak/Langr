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
	
	var title_string = str(qm.get_lesson_for_question(current_question))
	title_string = title_string.substr(0,title_string.rfind('.'))
	if global.active_lessons.size()>1:
		title_string += ' [' + global.get_active_lessons_string(20) + ']'
	$VBoxContainer/HeaderContainer/LabelLessonTitle.text =  title_string
	
	$VBoxContainer/LabelQuestion.set_mode('small')
	$VBoxContainer/LabelQuestion.text = current_question['question']
	var q_color = global.skill_color_dict[int(current_question['skill'])] \
		if 'good_answer_date' in current_question or 'bad_answer_date' in current_question \
		else global.skill_color_dict[null]
	$VBoxContainer/LabelQuestion/Label.add_color_override("font_color",q_color)
	
	temp_answer = qm.get_temp_answer()
	var answer_color
	if 'answer_free' in current_question and 'answer_free' in temp_answer and \
		current_question['answer_free'] == temp_answer['answer_free']:
			answer_color = Color(0.1,0.9,0.2) 
	else:
		 answer_color = Color(1,0.5,0.3)
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
	
	if global.DEBUG:
		var cq = current_question
		var dbs = '\n'
		for dbst in ['skill','good_answer_date','bad_answer_date']:
			dbs += '| '+ (str(cq[dbst]) if dbst in cq else 'ns') + ' '
		dbs += '\n['
		for rq in qm.quiz_rotation:
			dbs += rq['question'].substr(0,10) + '| ' 
		dbs = dbs.substr(0,dbs.length()-2)
		dbs += ']'
		$VBoxContainer/LabelQuestion.text += dbs
	
	if 'answer_draw' in current_question:
		var cc = CenterContainer.new()
		cc.size_flags_horizontal = cc.SIZE_EXPAND_FILL
		dr_answer = load('res://Interface/Input/DrawBox.tscn').instance()
		$VBoxContainer/ScrollContainerAnswers/VBoxContainerAnswers.add_child(cc)
		cc.add_child(dr_answer)
		
		display_answers()
		dr_answer.set_color_on_clear(Color(0.4,0.1,0.6),4)
		

func set_color_to_retry(dr_internal):
	dr_internal.change_line_color_to(Color(0.4,0.1,0.6),4)
	dr_answer.disable_add_drawing()
	dr_answer.set_cache_status_label()

func draw_correct_answer(dr_internal, idx: int):
	dr_internal.change_line_color_to(Color(0,0.8,0.2,0.6),9)
	var fns = current_question['answer_draw']
	if fns is String:
		fns = [fns]
	
	var drawing_file_name = 'user://lessons/' + qm.get_lesson_for_question(current_question,true) \
							+ '/' + fns[idx]
	dr_internal.load_drawing(drawing_file_name)

func display_answers():
	#if not correct_dr_answer:
	var fns = current_question['answer_draw']
	var temp_answer_cache = temp_answer['answer_draw']
	var dr_internal = dr_answer.find_node('AnswerDraw')
	if fns is String:
		fns = [fns]
		
	var lim = max(temp_answer_cache.size(),fns.size())
	for i in range(lim):
		if i<fns.size():
			draw_correct_answer(dr_internal,i)
			#var correct_dr_answer = dr_answer.get_lines()
		#else:
		#	dr_answer.add_lines(correct_dr_answer)	
		if i<temp_answer_cache.size():
			dr_internal.change_line_color_to(Color(0.4,0.1,0.6),3)
			
			dr_internal.change_line_color_to()
			dr_answer.add_lines(temp_answer_cache[i][0])
		if i<lim-1:
			dr_internal.load_next_cached()
	dr_internal.load_cached(0)
	set_color_to_retry(dr_internal)
	
func load_and_show_correct_answer(idx=-1):
	var dr_internal = dr_answer.find_node('AnswerDraw')
	if idx == -1:
		idx = dr_internal.currently_loaded
	dr_internal.load_cached(idx)
	dr_internal.clear_drawing()
	draw_correct_answer(dr_internal,idx)	
	set_color_to_retry(dr_internal)
	
func go_back():
	qm.exit_quiz()
	var _err = get_tree().change_scene('res://Screens/MainMenu.tscn')
	

#INput handling
func _on_ButtonForceIncorrect_pressed():
	qm.update_question_skill(current_question,-1)
	qm.move_question_to_rotation_end(current_question)
	global.current_question = ''
	var _err = get_tree().change_scene('res://Screens/QuizQuestion.tscn')

func _on_ButtonForceCorrect_pressed():
	qm.update_question_skill(current_question,2)
	qm.remove_from_rotation(current_question)
	global.current_question = ''
	var _err = get_tree().change_scene('res://Screens/QuizQuestion.tscn')

func _on_ButtonOnlyCorrect_pressed():
	#dr_answer.clear_drawing()
	load_and_show_correct_answer()


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
