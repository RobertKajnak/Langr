extends Control

var tbm = 'TextEditCheckBoxMulti'
var mbox_count = 1 # Keeps track of how many boxes there are
var to_translate = {'TextEditQuestion':'questionPlaceholder',
					'AnswerTextEdit':'answerTextPlaceholder',
					'LabelDraw':'drawLabel',
					'LabelMultiChoice':'multiChoiceTooltip',
					'ButtonClearDrawing':'drawClear',
					tbm + '0':'multiChoiceCheckbox'}
var all_questions = []


func _ready():
	$"/root/GlobalVars".retranslate($VBoxContainer,to_translate)
	for control in [$VBoxContainer/ScrollContainer/VBoxContainer/TextEditQuestion,
					$VBoxContainer/ScrollContainer/VBoxContainer/AnswerTextEdit]:
		var _err = control.connect("focus_entered",self,"_tapped_to_edit",[control])
		_err = control.connect("focus_exited",self,"_tapped_away",[control])
	
	var chbox = $VBoxContainer/ScrollContainer/VBoxContainer/ScrollContainerMultiChoice/VBoxContainerMultiChoice/HBoxContainer/TextEditCheckBoxMulti0
	chbox.connect("focus_entered",self,"_tapped_to_edit",[chbox])
	chbox.connect("focus_exited",self,"_tapped_away",[chbox])
	chbox.connect("text_changed",self,"_text_modified_chbox",[chbox])

	all_questions = $"/root/GlobalVars".all_questions
	
#%% Helper functions
func go_back():
	var _err = get_tree().change_scene('res://QuestionList.tscn')

func get_draw_data():
	return null

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
	
	if get_draw_data():
		pass
		
	if to_save and 'question' in to_save and not (to_save['question'] in all_questions) \
			and (adict['AnswerTextEdit'] in to_save or adict['TextEditCheckBoxMulti0'] in to_save):
		var lesson_file = File.new()
		lesson_file.open("user://lessons/" + $"/root/GlobalVars".current_lesson + '.les', File.READ_WRITE)
		lesson_file.seek_end()
		lesson_file.store_line(to_json(to_save))
		lesson_file.close()
		go_back()
	else:
		var popup = preload("res://ErrorPopup.tscn").instance()
		add_child(popup)
		if not to_save:
			popup.display("Could not create new Question",'None of the fields are set')
		elif not ('question' in to_save):
			popup.display("Could not create new Question",'Question field not set')
		elif to_save['question'] in all_questions:
			popup.display("Could not create new Question",'Question Already in database. There Cannot be two identical questions (with different answers. And having two questions with the same answer is pointless)')
		elif not (adict['AnswerTextEdit'] in to_save or adict['TextEditCheckBoxMulti0'] in to_save):
			popup.display("Could not create new Question",'None of the answer fields are set')
		
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


var button_down = false
func _on_AnswerDraw_gui_input(event):
	#print(event is InputEventMouseMotion)
	if event is InputEventMouseButton:
		if button_down:
			$VBoxContainer/ScrollContainer/VBoxContainer/VBoxContainerDraw/AnswerDraw.save_line()
		button_down = !button_down
	if button_down and event is InputEventMouseMotion:
		$VBoxContainer/ScrollContainer/VBoxContainer/VBoxContainerDraw/AnswerDraw.update_mouse(event.position)
		

func _on_ButtonClearDrawing_pressed():
	$VBoxContainer/ScrollContainer/VBoxContainer/VBoxContainerDraw/AnswerDraw.clear_drawing()
