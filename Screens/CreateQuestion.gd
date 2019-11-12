extends Control

var to_translate = {'TextEditQuestion':'questionPlaceholder',
					'AnswerTextEdit':'answerTextPlaceholder',
					'LabelSkill':'currentSkill',
					'LabelMultiChoice':'multiChoiceTooltip',
					'ButtonClearDrawing':'drawClear',
					'ButtonUndoDrawing':'drawUndo',
					'LabelRequires':'requires',
					'LinkRequires':'none'}
var global
var qm
var original_question
var modifying_mode

var error_popup_class = preload("res://Interface/Interactive/ErrorPopup.tscn")
var link_button_class = preload("res://Interface/Buttons/SelectLessonButton.tscn")

func _ready():
	global = $"/root/GlobalVars"
	global.retranslate($VBoxContainer,to_translate)
	for control in [$VBoxContainer/ScrollContainer/VBoxContainer/TextEditQuestion,
					$VBoxContainer/ScrollContainer/VBoxContainer/AnswerTextEdit]:
		var _err = control.connect("focus_entered",self,"_tapped_to_edit",[control])
		_err = control.connect("focus_exited",self,"_tapped_away",[control])
	
	$VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer/LabelSkill.set_width_auto(20)

	qm = $"/root/QuestionManager"
	
	#Add current profficiency skill level
	for i in range(qm.MAX_SKILL_LEVEL+1):
		$VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer/OptionButtonSkill.add_item(str(i))
	modifying_mode = false

	$VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer2/LabelRequires.set_mode('medium')
	$VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer2/LabelRequires.set_width_auto(5)

func load_data(file_name,question_title,dev_mode = false):
	var question_data = qm.get_question(question_title)

	var inv_dict = $"/root/GlobalVars".adict_inv()
	for key in question_data.keys():
		if not key in inv_dict:
			push_warning("unkown key found: " + key)
			continue
		var node = $VBoxContainer/ScrollContainer/VBoxContainer/.find_node(inv_dict[key])
		match key:
			'answer_draw':
				var drawing_file_name = question_data[key]
				if drawing_file_name is String:
					drawing_file_name = [drawing_file_name]
				var full_fns = []
				for dfn in drawing_file_name:
					full_fns.append(file_name.substr(0,file_name.find_last('.')) + '/' + dfn)
				node.load_drawing(full_fns)
			'skill':
				node.select(int(question_data[key]))
			'answer_free':
				node.text = question_data[key]
				node.adapt()
			'question':
				node.text = question_data[key]
				node.adapt()
			'id': pass
			'good_answer_date':pass
			'bad_answer_date':pass
			'skip_days':pass
			_:
				push_warning("unkown key found: " + key)
		
	$VBoxContainer/CenterContainer/ButtonCreateQuestion.text_loc = 'modifyQuestion'
	$VBoxContainer/CenterContainer/ButtonCreateQuestion._ready()
	
	original_question = question_data
	$VBoxContainer/CenterContainer2/ButtonCancel.text_loc = 'deleteQuestion'
	$VBoxContainer/CenterContainer2/ButtonCancel._ready()

	modifying_mode = true

	if dev_mode:
		var stx = '' #stats text
		for s in ['id','good_answer_date','bad_answer_date','skip_days']:
			var smod = (str(question_data[s]) if s in question_data else tr('N/A'))
			if (s == 'good_answer_date' or s=='bad_answer_date') and smod!=tr('N/A'):
				var lang = TranslationServer.get_locale()
				if lang in ['ja','zh']:
					smod = smod.insert(4,'年')
					smod = smod.insert(7,'月')
				else:
					smod = smod.insert(4,'/')
					smod = smod.insert(7,'/')
			stx +=  tr(s) + ': '+ smod + '\n'
		$VBoxContainer/ScrollContainer/VBoxContainer/LableStats.text = stx
		$VBoxContainer/ScrollContainer/VBoxContainer/LableStats.set_mode('small')
	else:
		$VBoxContainer/ScrollContainer/VBoxContainer/LableStats.visible = false
		$VBoxContainer/ScrollContainer/VBoxContainer/HSeparator.visible = false
#%% Helper functions
func go_back():
	var _err = get_tree().change_scene('res://Screens/QuestionList.tscn')

#%% Interface handling
func _tapped_to_edit(control):
	if control.text == tr(to_translate[control.name]):
		control.text = ''
		
func _tapped_away(control):
	if control.text == '':
		control.text = tr(to_translate[control.name])

func _count_boxes():
	pass


func _on_Button_pressed():
	var to_save = {}
	var adict = $"/root/GlobalVars".adict;
	for q in [$VBoxContainer/ScrollContainer/VBoxContainer/AnswerTextEdit,
				$VBoxContainer/ScrollContainer/VBoxContainer/TextEditQuestion]:
		if q.text!='' and q.text!=tr(to_translate[q.name]):
			to_save[adict[q.name]] = q.text
	to_save[adict['OptionButtonSkill']] = $VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer/OptionButtonSkill.selected
	if modifying_mode:
		if not 'question' in to_save:
			to_save['question'] = original_question['question'] #This must happen before the 'AnswerDraw'='placeholder' draw,
			# so a 'questionNotSet' Error is not thrown
		elif to_save['question'] != original_question['question'] and to_save['question'] in qm.get_question_titles():
			var popup = error_popup_class.instance()
			add_child(popup)
			popup.display(tr('couldNotModifyQuestion'),tr('questionAlreadyExists'))
			return
	#TODO this feels like a wokraround
	if not $VBoxContainer/ScrollContainer/VBoxContainer/CenterContainer/VBoxContainerDraw/AnswerDraw.is_empty():
		to_save[adict['VBoxContainerDraw']] = 'placeholder'
		if (modifying_mode and qm._check_question(to_save,false)==null) or (not modifying_mode and qm._check_question(to_save,true)==null):
			to_save[adict['VBoxContainerDraw']] = $VBoxContainer/ScrollContainer/VBoxContainer/CenterContainer/VBoxContainerDraw/AnswerDraw.save_dawing()
		else:
			to_save.erase(adict['VBoxContainerDraw'])

	if modifying_mode:
		if 'good_answer_date' in original_question:
			to_save['good_answer_date'] = original_question['good_answer_date']
		if 'bad_answer_date' in original_question:
			to_save['bad_answer_date'] = original_question['bad_answer_date']
		
	var err = null
	var popup_title = null
	if self.modifying_mode:
		err = qm.replace_question(original_question['question'],to_save)
		if err!=null:
			popup_title = 'couldNotCreateQuestion'
	else:
		err = qm.add_question(to_save)
		if err!=null:
			popup_title='couldNotModifyQuestion'
	if err!=null:
		print(popup_title + ': ' + err)
		var popup = error_popup_class.instance()
		add_child(popup)
		popup.display(tr(popup_title),tr(err))
	else:
		go_back()

func add_lesson_requirement(question):
	var lb = link_button_class.instance()
	$VBoxContainer/ScrollContainer/VBoxContainer/VBoxContainerRequires.add_child(lb)
	lb.set_label(question)

func _on_LabelRequires_pressed():
	var epu = .instance()
	add_child(epu)
	var sb = preload('res://Interface/Interactive/SearchBar.tscn').instance()
	epu.add_extra(sb)
	sb.set_mode('small')
	
	global.populate_with_links(qm.get_questions(),epu.get_container(),true,get_viewport_rect().size.x*0.85)
	#epu.add_extra(load('res://Interface/Buttons/SelectLessonButton.tscn').instance())
	epu.display(tr('selectLesson'),'')

func _on_ButtonCancel_pressed():
	if $VBoxContainer/CenterContainer2/ButtonCancel.text_loc == 'deleteQuestion':
		qm.remove_question(original_question['question'])
	go_back()
		


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
		go_back()

		

