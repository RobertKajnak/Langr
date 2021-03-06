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
	
	if GlobalVars.EINK:
		$Sprite.texture = null
	else:
		$Sprite.texture = preload('res://.import/Wood15.jpg-50e2cbf6645f0a7ed0cb9f91f5de5cca.stex')
	#global.retranslate($VBoxContainer,to_translate)
	
	current_question = global.current_question
	
	var title_string = str(qm.get_lesson_for_question(current_question))
	title_string = title_string.substr(0,title_string.rfind('.'))
	if global.active_lessons.size()>1:
		title_string += ' [' + global.get_active_lessons_string(20) + ']'
	var to_recap_count = qm.get_recap_question_count()
	if to_recap_count[0]>0 or to_recap_count[1]>0:
		title_string += ' (' + str(to_recap_count[0]) + '/' + str(to_recap_count[1]) + ')'
	$VBoxContainer/HeaderContainer/LabelLessonTitle.text =  title_string
	
	$VBoxContainer/LabelQuestion.set_mode('small')
	$VBoxContainer/LabelQuestion.text = current_question['question']
	global.set_question_color($VBoxContainer/LabelQuestion/Label,current_question)
	
	temp_answer = qm.get_temp_answer()
	var answer_color
	var correct_answer_provided = false
	if 'answer_free' in current_question and 'answer_free' in temp_answer and \
		current_question['answer_free'] == temp_answer['answer_free']:
			answer_color = Color(0.1,0.9,0.2) 
			correct_answer_provided = true
	else:
		 answer_color = Color(1,0.5,0.3)
		
	if 'answer_free' in current_question:
		var txt_answer_content = []
		if correct_answer_provided:
			txt_answer_content.append(tr('correctlyAnswered') + ':')
		else:
			txt_answer_content.append(tr('expectedAnswer') + ':')
			
		txt_answer_content.append('     ' + current_question['answer_free'].replace('\n','\n     '))
		if temp_answer['answer_free'].length() >0 and not correct_answer_provided:
			txt_answer_content.append(tr('givenAnswer') + ':')
			txt_answer_content.append('     ' + temp_answer['answer_free'].replace('\n','\n     '))
			
		for txt in txt_answer_content:
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
		for dbst in ['skill','good_answer_date','bad_answer_date','skip_days']:
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
	else:
		$VBoxContainer/CenterContainer/ButtonOnlyCorrect.visible = false
		
	if 'required_questions' in current_question:
		$VBoxContainer/ScrollContainerAnswers/VBoxContainerAnswers.add_child(HSeparator.new())
		var rqlabel = preload("res://Interface/TextDisplay/LabelAdaptive.tscn").instance()
		$VBoxContainer/ScrollContainerAnswers/VBoxContainerAnswers.add_child(rqlabel)
		rqlabel.set_text(tr('requires'))
		rqlabel.set_mode('normal')
		rqlabel.set_width_auto()
		
		var SLB = preload("res://Interface/Buttons/SelectLessonButton.tscn")
		for rq in current_question['required_questions']:
			var lb = SLB.instance()
			$VBoxContainer/ScrollContainerAnswers/VBoxContainerAnswers.add_child(lb)
			lb.set_label(rq)
			lb.auto_ellipse(get_viewport_rect().size.x*0.85)
			lb.connect("pressed",self,"show_required_quesiton",[lb.original_text])

	$VBoxContainer/LabelQuestion.set_width($VBoxContainer.rect_size.x)
	
func show_required_quesiton(question_text):
	var epu = preload("res://Interface/Interactive/ErrorPopup.tscn").instance()
	add_child(epu)
	var question_data = qm.get_question(question_text)
	var answer_text = ''
	if 'answer_free' in question_data:
		answer_text = question_data['answer_free']
	if 'answer_draw' in question_data:
		var cc = CenterContainer.new()
		cc.size_flags_horizontal = cc.SIZE_EXPAND_FILL
		dr_answer = load('res://Interface/Input/DrawBox.tscn').instance()
		cc.add_child(dr_answer)
		epu.add_extra(cc)
		
		var fns = question_data['answer_draw']
		if fns is String:
			fns = [fns]
			
		dr_answer.create_empty_drawings(len(fns)-1)
		for fn in fns:
			dr_answer.load_drawing('user://lessons/' + qm.get_lesson_for_question(question_data,true) + '/' + fn)
			dr_answer.load_next_image()
		dr_answer.load_image(0)
		dr_answer.disable_add_drawing()
		dr_answer.disable_erase()
		dr_answer.disable_mouse_interaction()
		#dr_answer.change_size(Vector2(109*2,109*2))
		
	epu.display(question_text,answer_text)
	
	
func set_color_to_retry():
	dr_answer.change_line_color_to(Color(0.4,0.1,0.6),4)
	dr_answer.disable_add_drawing()
	dr_answer.set_cache_status_label()

func draw_correct_answer(idx: int):
	dr_answer.change_line_color_to(Color(0,0.8,0.2,0.6),7)
	var fns = current_question['answer_draw']
	if fns is String:
		fns = [fns]
	
	var drawing_file_name = 'user://lessons/' + qm.get_lesson_for_question(current_question,true) \
							+ '/' + fns[idx]
	dr_answer.load_drawing(drawing_file_name, -1 if GlobalVars.draw_columns == 1 else idx)

func display_answers():
	#if not correct_dr_answer:
	var fns = current_question['answer_draw']
	var temp_answer_cache = temp_answer['answer_draw']
	if fns is String:
		fns = [fns]
		
	var lim = max(temp_answer_cache.size(),fns.size())
	for i in range(lim):
		if i<fns.size():
			draw_correct_answer(i)
			#var correct_dr_answer = dr_answer.get_lines()
		#else:
		#	dr_answer.add_lines(correct_dr_answer)	
		if i<temp_answer_cache.size():
			dr_answer.change_line_color_to(Color(0.4,0.1,0.6),3)
			
			dr_answer.add_lines(temp_answer_cache[i][0])
		set_color_to_retry()
		if i<lim-1:
			dr_answer.load_next_cached()
	dr_answer.load_image(0)
	
func load_and_show_correct_answer(idx=-1):
	if dr_answer==null:
		return
		
	if idx == -1:
		if GlobalVars.draw_columns == 1:
			idx = dr_answer.get_internal_idx()
			#dr_answer.load_image(idx)
			dr_answer.clear_drawing()
			draw_correct_answer(idx)
			set_color_to_retry()
		else:
			#idx = dr_answer.current_surface_idx
			for i in len(dr_answer.surfaces):
				dr_answer.clear_drawing(i)
				draw_correct_answer(i)
				set_color_to_retry()


	
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
