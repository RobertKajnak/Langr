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

var req_candidates
var current_sort_order = 0

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
	
	$VBoxContainer/ScrollContainer/VBoxContainer/LableStats.visible = false
	$VBoxContainer/ScrollContainer/VBoxContainer/HSeparator.visible = false
	$VBoxContainer/ScrollContainer/VBoxContainer/HeaderContainer.visible = false
	
	set_require_label_auto()
#%% Helper functions
func load_data(file_name,question_title,dev_mode = false):
	var question_data = qm.get_question(question_title)
	
	var hc = $VBoxContainer/ScrollContainer/VBoxContainer/HeaderContainer
	var q_title = question_title
	var txt_lim = 25 - tr('currentlyEditing').length()
	if q_title.length()>txt_lim:
		q_title = q_title.substr(0,txt_lim-5) + '[...]'
	hc.text = tr('currentlyEditing') + ': ' + q_title
	#global.auto_ellipse(get_viewport_rect().size.x*0.85,hc.find_node("LabelTitle"))
	
	
	hc.visible = true

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
			'required_questions':
				for q in question_data[key]:
					add_lesson_requirement(q)
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
		$VBoxContainer/ScrollContainer/VBoxContainer/LableStats.set_text(stx)
		$VBoxContainer/ScrollContainer/VBoxContainer/LableStats.set_mode('small')
		
		
		$VBoxContainer/ScrollContainer/VBoxContainer/LableStats.visible = true
		$VBoxContainer/ScrollContainer/VBoxContainer/HSeparator.visible = true
		
	else:
		$VBoxContainer/ScrollContainer/VBoxContainer/LableStats.visible = false
		$VBoxContainer/ScrollContainer/VBoxContainer/HSeparator.visible = false
		
		
	set_require_label_auto()
	
func generate_to_require_candidates():
	var cand = []
	var to_ignore = []
	if original_question:
		to_ignore += [original_question['question']]
		for q in  qm.required_by_questions(original_question['question']):
			to_ignore.append(q['question'])
	for child in $VBoxContainer/ScrollContainer/VBoxContainer/VBoxContainerRequires.get_children():
		to_ignore.append(child.original_text)
	for q in qm.get_questions():
		if not q['question'] in to_ignore:
			cand.append(q)
	return cand
		
func remove_link(container:Container, text:String):
	for child in container.get_children():
		if "original_text" in child and child.original_text == text:
			container.remove_child(child)
		
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
	
	var reqs = []
	for child in $VBoxContainer/ScrollContainer/VBoxContainer/VBoxContainerRequires.get_children():
		reqs.append(child.original_text)
	if reqs:
		to_save['required_questions'] = reqs
		
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
	#Check if question already added:
	for added_link in $VBoxContainer/ScrollContainer/VBoxContainer/VBoxContainerRequires.get_children():
		if added_link.original_text == question:
			return
	var lb = link_button_class.instance()
	$VBoxContainer/ScrollContainer/VBoxContainer/VBoxContainerRequires.add_child(lb)
	lb.set_label(question)
	lb.auto_ellipse(get_viewport_rect().size.x*0.85)
	lb.connect("pressed",self,"remove_lesson_requirement",[lb.original_text])
	
	global.set_question_color(lb,qm.get_question(question))
	
	set_require_label_auto()
	
func set_require_label_auto():
	if $VBoxContainer/ScrollContainer/VBoxContainer/VBoxContainerRequires.get_child_count() == 0:
		#TODO: Workaround!
		$VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer2/LinkRequires.set_label(tr('none'))
	else:
		$VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer2/LinkRequires.set_label(tr('add'))
	
func remove_lesson_requirement(question_text):
	for child in $VBoxContainer/ScrollContainer/VBoxContainer/VBoxContainerRequires.get_children():
		if child.original_text == question_text:
			$VBoxContainer/ScrollContainer/VBoxContainer/VBoxContainerRequires.remove_child(child)
			set_require_label_auto()
			return

func _on_LabelRequires_pressed():
	var epu = error_popup_class.instance()
	add_child(epu)
	
	for child in epu.get_container().get_children():
		epu.get_container().remove_child(child)
		
	req_candidates = generate_to_require_candidates()
	
	if req_candidates:
		var sb = preload('res://Interface/Interactive/SearchBar.tscn').instance()
		print(epu.find_node("Description",true,false))
		epu.find_node("VBoxContainer").add_child_below_node(epu.find_node("Description",true,false),sb)
		sb.disable_label()
		sb.add_options(qm.SORT_MODES)
		sb.select(global.question_sort_mode)
		sb.set_mode('small')
		sb.select(0)
		sb.connect("filter_changed",self,"_on_epu_search_changed",[epu])
		sb.connect("order_changed",self,"on_epu_order_changed",[epu])
		
	var links = global.populate_with_links(req_candidates,epu.get_container(),\
											true,get_viewport_rect().size.x*0.85*0.8)
	for link in links:
		link.connect("pressed",self,'add_lesson_requirement',[link.original_text])
		link.connect("pressed",self,"remove_link",[epu.get_container(),link.original_text])
	#epu.add_extra(load('res://Interface/Buttons/SelectLessonButton.tscn').instance())
	
	epu.display(tr('selectQuestions'),'')
	


func _on_ButtonCancel_pressed():
	if $VBoxContainer/CenterContainer2/ButtonCancel.text_loc == 'deleteQuestion':
		qm.remove_question(original_question['question'])
	go_back()
		

func _on_epu_search_changed(tes,epu):	
	req_candidates = generate_to_require_candidates()
	req_candidates = qm.fitler_quesiton_list(req_candidates,tes)
	var links = global.populate_with_links(req_candidates,epu.get_container(),\
											true,get_viewport_rect().size.x*0.85*0.8)
	for link in links:
		link.connect("pressed",self,'add_lesson_requirement',[link.original_text])
		link.connect("pressed",self,"remove_link",[epu.get_container(),link.original_text])
	on_epu_order_changed(current_sort_order,epu)

func on_epu_order_changed(ID,epu):
	current_sort_order = ID
	var sorted_candidates = req_candidates.duplicate()
	match ID/2:
		1: sorted_candidates.sort_custom(qm,'sort_alphabetical')
		2: sorted_candidates.sort_custom(qm,'sort_skill')
		_: pass
	if ID%2==1:
		sorted_candidates.invert()
	
	var links = global.populate_with_links(sorted_candidates,epu.get_container(),\
											true,get_viewport_rect().size.x*0.85*0.8)
	for link in links:
		link.connect("pressed",self,'add_lesson_requirement',[link.original_text])
		link.connect("pressed",self,"remove_link",[epu.get_container(),link.original_text])



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

		

