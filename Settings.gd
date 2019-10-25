extends Control


var buttonTexts = {'LabelTitle':'settings','LabelLanguage':'language','LabelScale':'scale'}
var global

var possible_scales = [8,12,14,16,24,32,48,56,64,72,96,126]

func _ready():
	global = $"/root/GlobalVars"
	$VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainerLang/LabelLanguage/LabelNormal.rect_min_size = Vector2(180,0)
	$VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainerLang/LabelLanguage/LabelNormal.rect_size = Vector2(180,0)
	var ButtonLang = $VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainerLang/ButtonLanguage
	for lang in global.langs:
		ButtonLang.add_item(lang);
	ButtonLang.select(global.currentLang);
	global.retranslate($VBoxContainer,buttonTexts)
	
	
	$VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainerScale/LabelScale/LabelNormal.rect_min_size = Vector2(180,0)
	$VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainerScale/LabelScale/LabelNormal.rect_size = Vector2(250,0)
	var ButtonScale = $VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainerScale/ButtonScale
	var index = find_closest(possible_scales,global.UI_SCALE)
	if possible_scales[index] != global.UI_SCALE:
		possible_scales.insert(index,global.UI_SCALE)
	for i in possible_scales:
		ButtonScale.add_item(str(i));
	ButtonScale.select(index);

#%% returns the index of, or closest index to the left of the searched value.
func find_closest(array,value):
	for i in array.size():
		if array[i]>=value:
			return max(0,i)
	return array.size()-1

func go_back():
	var _err = get_tree().change_scene('res://MainMenu.tscn')


#%%Interface Handling
func _on_ButtonLanguage_item_selected(ID):
	global.currentLang = ID;
	TranslationServer.set_locale(global.langs[global.currentLang])
	global.retranslate($VBoxContainer,buttonTexts);

func _on_ButtonScale_item_selected(ID):
	global.UI_SCALE = possible_scales[ID]
	$VBoxContainer/LabelTitle._ready()
	$VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainerLang/LabelLanguage._ready()
	$VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainerScale/LabelScale._ready()

#%%Input handling
func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			global.save_settings()
			go_back()
			
func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		# For Windows
		pass        
	if what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST: 
		# For android
		global.save_settings()
		go_back()


