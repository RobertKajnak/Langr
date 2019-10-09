extends Control

var tbm = 'TextEditCheckBoxMulti'
var mbox_count = 1 # Keeps track of how many boxes there are
var to_translate = {'TextEditQuestion':'questionPlaceholder',
					'AnswerTextEdit':'answerTextPlaceholder','LabelDraw':'drawLabel',
					'LabelMultiChoice':'multiChoiceTooltip',
					tbm + '0':'multiChoiceCheckbox'}



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

#%% Helper functions
func go_back():
	var _err = get_tree().change_scene('res://QuestionList.tscn')

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