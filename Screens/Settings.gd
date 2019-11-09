extends Control


var buttonTexts = {'LabelTitle':'settings',
					'LabelLanguage':'language',
					'LabelScale':'scale',
					'LabelRotationSize':'quizRotationSize',
					'LabelDebug':'enableDebug'}
var global


func _ready():
	global = $"/root/GlobalVars"
	
	$VBoxContainer/LabelTitle.set_mode('title')
	$VBoxContainer/LabelTitle.set_width(get_viewport_rect().size.x)
	
	$VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainerLang/LabelLanguage.set_width_auto(10)
	var ButtonLang = $VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainerLang/ButtonLanguage
	for lang in global.langs:
		ButtonLang.add_item(lang);
	ButtonLang.select(global.currentLang);
	ButtonLang.adapt()
	global.retranslate($VBoxContainer,buttonTexts)
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
	
	$VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainerRotation/HSliderRotationSize.value = global.rotation_size
	$VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainerRotation/LableRotationSizeValue.text = str(global.rotation_size)
	$VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainerRotation/LabelRotationSize.set_width(get_viewport_rect().size.x*0.45)
	$VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainerRotation/LableRotationSizeValue.set_width_auto(10)
	
	$VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainerDebug/LabelDebug.set_width_auto(10)
	$VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainerDebug/CheckBoxDebug.pressed = global.DEBUG

#%% returns the index of, or closest index to the left of the searched value.
func find_closest(array,value):
	for i in array.size():
		if array[i]>=value:
			return max(0,i)
	return array.size()-1

func go_back():
	global.DEBUG = $VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainerDebug/CheckBoxDebug.is_pressed()
	global.save_settings()
	var _err = get_tree().change_scene('res://Screens/MainMenu.tscn')


#%%Interface Handling
func _on_ButtonLanguage_item_selected(ID):
	global.currentLang = ID;
	TranslationServer.set_locale(global.langs[global.currentLang])
	global.retranslate($VBoxContainer,buttonTexts);

func _on_ButtonScale_item_selected(ID):
	global.UI_SCALE = global.POSSIBLE_SCALES[ID]
	$VBoxContainer/LabelTitle._ready()
	$VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainerLang/LabelLanguage._ready()
	$VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainerScale/LabelScale._ready()
	$VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainerRotation/LabelRotationSize._ready()
	$VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainerRotation/LableRotationSizeValue._ready()
	$VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainerDebug/LabelDebug._ready()

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



