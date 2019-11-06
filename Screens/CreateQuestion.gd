extends Control

var tbm = 'TextEditCheckBoxMulti'
var mbox_count = 1 # Keeps track of how many boxes there are
var to_translate = {'TextEditQuestion':'questionPlaceholder',
					'AnswerTextEdit':'answerTextPlaceholder',
					'LabelSkill':'currentSkill',
					'LabelMultiChoice':'multiChoiceTooltip',
					'ButtonClearDrawing':'drawClear',
					'ButtonUndoDrawing':'drawUndo',
					tbm + '0':'multiChoiceCheckbox'}
var qm
var original_question
var modifying_mode

func _ready():
	$"/root/GlobalVars".retranslate($VBoxContainer,to_translate)
	for control in [$VBoxContainer/ScrollContainer/VBoxContainer/TextEditQuestion,
					$VBoxContainer/ScrollContainer/VBoxContainer/AnswerTextEdit]:
		var _err = control.connect("focus_entered",self,"_tapped_to_edit",[control])
		_err = control.connect("focus_exited",self,"_tapped_away",[control])
	
	$VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer/LabelSkill/Label.rect_min_size = Vector2(180,0)
	$VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer/LabelSkill/Label.rect_size = Vector2(400,0)
	var chbox = $VBoxContainer/ScrollContainer/VBoxContainer/ScrollContainerMultiChoice/VBoxContainerMultiChoice/HBoxContainer/TextEditCheckBoxMulti0
	chbox.connect("focus_entered",self,"_tapped_to_edit",[chbox])
	chbox.connect("focus_exited",self,"_tapped_away",[chbox])
	chbox.connect("text_changed",self,"_text_modified_chbox",[chbox])

	qm = $"/root/QuestionManager"
	
	#Add current profficiency skill level
	for i in range(qm.MAX_SKILL_LEVEL+1):
		$VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer/OptionButtonSkill.add_item(str(i))
	modifying_mode = false

func load_data(file_name,question_title):
	var question_data = qm.get_question(question_title)

	var inv_dict = $"/root/GlobalVars".adict_inv
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

func _text_modified_chbox(box):
	print("modifying " + box.name)
	if box.text != tr(to_translate[box.name]) and box.text != '' and box.name == tbm + str(mbox_count-1):
		print('adding buttons')
		var box_list = $VBoxContainer/ScrollContainer/VBoxContainer/ScrollContainerMultiChoice/VBoxContainerMultiChoice
		var hbox = HBoxContainer.new()
		$VBoxContainer/ScrollContainer/VBoxContainer/ScrollContainerMultiChoice.rect_size.y+=80
		box_list.add_child(hbox)
		hbox.rect_size.y = 180
		var tick = CheckBox.new()
		var text = TextEdit.new()
		hbox.add_child(tick)
		hbox.add_child(text)
		text.rect_size.y = 180
		text.name = tbm + str(mbox_count)
		mbox_count += 1
		text.connect("focus_entered",self,"_tapped_to_edit",[text])
		text.connect("focus_exited",self,"_tapped_away",[text])
		text.connect("text_changed",self,"_text_modified_chbox",[text])


func _on_Button_pressed():
	var to_save = {}
	var adict = $"/root/GlobalVars".adict;
	for q in [$VBoxContainer/ScrollContainer/VBoxContainer/AnswerTextEdit,
				$VBoxContainer/ScrollContainer/VBoxContainer/ScrollContainerMultiChoice/VBoxContainerMultiChoice/HBoxContainer/TextEditCheckBoxMulti0,
				$VBoxContainer/ScrollContainer/VBoxContainer/TextEditQuestion]:
		if q.text!='' and q.text!=tr(to_translate[q.name]):
			to_save[adict[q.name]] = q.text
	to_save[adict['OptionButtonSkill']] = $VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer/OptionButtonSkill.selected
	if modifying_mode:
		if not 'question' in to_save:
			to_save['question'] = original_question['question'] #This must happen before the 'AnswerDraw'='placeholder' draw,
			# so a 'questionNotSet' Error is not thrown
	
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
		var popup = preload("res://Interface/Interactive/ErrorPopup.tscn").instance()
		add_child(popup)
		popup.display(tr(popup_title),tr(err))
	else:
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



		

func _on_ButtonCancel_pressed():
	if $VBoxContainer/CenterContainer2/ButtonCancel.text_loc == 'deleteQuestion':
		qm.remove_question(original_question['question'])
	go_back()
		
