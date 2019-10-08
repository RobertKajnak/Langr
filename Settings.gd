extends Control


var buttonTexts = {'LabelTitle':'settings','LabelLanguage':'language'}
var langs


func _ready():
	langs = get_node("/root/GlobalVars")
	var ButtonLang = $VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer/ButtonLanguage
	for lang in langs.langs:
		ButtonLang.add_item(lang);
	ButtonLang.select(langs.currentLang);
	langs.retranslate($VBoxContainer,buttonTexts)
	

#%% Helper functions
func go_back():
	var _err = get_tree().change_scene('res://MainMenu.tscn')


#%%Interface Handling
func _on_ButtonLanguage_item_selected(ID):
	var globals = get_node("/root/GlobalVars")
	globals.currentLang = ID;
	TranslationServer.set_locale(globals.langs[globals.currentLang])
	langs.retranslate($VBoxContainer,buttonTexts);



#%%Input handling
func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			langs.save_settings()
			go_back()
			
func _notification(what):
	if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
		# For Windows
		pass        
	if what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST: 
		# For android
		langs.save_settings()
		go_back()
