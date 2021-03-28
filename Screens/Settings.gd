extends Control


var buttonTexts = {'LabelTitle':'settings',
					'LabelLanguage':'language',
					'LabelScale':'scale',
					'LabelRotationSize':'quizRotationSize',
					'LabelDebug':'enableDebug',
					'LabelEInk':'EInkMode',
					'LabelColumns': 'drawColumns'}
var global


func _ready():
	global = $"/root/GlobalVars"
	if global.EINK:
		$Sprite.texture = null
	else:
		$Sprite.texture = preload('res://.import/Wood24.jpg-4a3597f20fd006272deaaf45f7635168.stex')
	
	global.retranslate($VBoxContainer,buttonTexts)
	
	$VBoxContainer/LabelTitle.set_mode('title')
	$VBoxContainer/LabelTitle.set_width(get_viewport_rect().size.x)
	
	$VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainerLang/LabelLanguage.set_width_auto(10)
	var ButtonLang = $VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainerLang/ButtonLanguage
	for lang in global.langs:
		ButtonLang.add_item(lang);
	ButtonLang.select(global.currentLang);
	ButtonLang.adapt()
	global.adapt_font(ButtonLang,global.FONT_SIZE_MEDIUM,null,true)
	
	
	$VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainerScale/LabelScale.set_width_auto(10)
	var ButtonScale = $VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainerScale/ButtonScale
	var index = find_closest(global.POSSIBLE_SCALES,global.UI_SCALE)
	if global.POSSIBLE_SCALES[index] != global.UI_SCALE:
		global.POSSIBLE_SCALES.insert(index,global.UI_SCALE)
	for i in global.POSSIBLE_SCALES:
		ButtonScale.add_item(str(i));
	ButtonScale.select(index);
	ButtonScale.adapt()
	
	$VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainerColumns/LabelColumns.set_width_auto(10)
	var buttonColumns = $VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainerColumns/OptionButtonColumns
	index = find_closest(global.POSSIBLE_COLUMNS, global.draw_columns)
	if global.POSSIBLE_COLUMNS[index] != global.draw_columns:
		global.POSSIBLE_COLUMNS.insert(index,global.POSSIBLE_COLUMNS)
	for i in global.POSSIBLE_COLUMNS:
		buttonColumns.add_item(str(i));
	buttonColumns.select(index);
	buttonColumns.adapt()
	
	$VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainerEInk/LabelEInk.set_width_auto(10)
	$VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainerEInk/CheckBoxEInk.pressed = global.EINK
	$VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainerEInk/CheckBoxEInk.rect_min_size = Vector2(60,60)
	
	$VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainerRotation/HSliderRotationSize.value = global.rotation_size
	$VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainerRotation/LableRotationSizeValue.text = str(global.rotation_size)
	#$VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainerRotation/LabelRotationSize.set_width(get_viewport_rect().size.x*0.45)
	$VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainerRotation/LableRotationSizeValue.set_width_auto(10)
	$VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainerRotation/LabelRotationSize.set_width_auto(10)
	
	
	$VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainerDebug/LabelDebug.set_width_auto(10)
	$VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainerDebug/CheckBoxDebug.pressed = global.DEBUG
	$VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainerDebug/CheckBoxDebug.rect_min_size = Vector2(60,60)

#%% returns the index of, or closest index to the left of the searched value.
func find_closest(array,value):
	for i in array.size():
		if array[i]>=value:
			return max(0,i)
	return array.size()-1

func go_back():
	global.EINK = $VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainerEInk/CheckBoxEInk.is_pressed()
	global.DEBUG = $VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainerDebug/CheckBoxDebug.is_pressed()
	global.save_settings()
	var _err = get_tree().change_scene('res://Screens/MainMenu.tscn')

func refresh():
	go_back()
	var _err = get_tree().change_scene("res://Screens/Settings.tscn")
	return

#%%Interface Handling
func _on_ButtonLanguage_item_selected(ID):
	global.currentLang = ID;
	TranslationServer.set_locale(global.langs[global.currentLang])
	refresh()
	print(ID,global.currentLang,global.langs[global.currentLang],';',TranslationServer.get_locale())
	#global.retranslate($VBoxContainer,buttonTexts);

func _on_ButtonScale_item_selected(ID):
	global.UI_SCALE = global.POSSIBLE_SCALES[ID]
	refresh()

func _on_OptionButtonColumns_item_selected(index):
	global.draw_columns = global.POSSIBLE_COLUMNS[index]
	
func _on_HSliderRotationSize_value_changed(value):
	$VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainerRotation/LableRotationSizeValue.text = str(value)
	global.rotation_size = value
	
#%%Input handling
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



