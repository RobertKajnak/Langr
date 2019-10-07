extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var buttonTexts = {'LabelTitle':'settings','LabelLanguage':'language'}
var langs
# Called when the node enters the scene tree for the first time.
func _ready():
	langs = get_node("/root/GlobalVars")
	var ButtonLang = $VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer/ButtonLanguage
	for lang in langs.langs:
		ButtonLang.add_item(lang);
	ButtonLang.select(langs.currentLang);
	langs.retranslate($VBoxContainer,buttonTexts)
	

	
func _unhandled_input(event):
	if event is InputEventKey:
		if event.pressed and event.scancode == KEY_ESCAPE:
			langs.save_settings()
			get_tree().change_scene('res://MainMenu.tscn')
			
func _notification(what):
    if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
        # For Windows
        pass        
    if what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST: 
        # For android
        langs.save_settings()
        get_tree().change_scene('res://MainMenu.tscn')


func _on_ButtonLanguage_item_selected(ID):
	var globals = get_node("/root/GlobalVars")
	globals.currentLang = ID;
	TranslationServer.set_locale(globals.langs[globals.currentLang])
	langs.retranslate($VBoxContainer,buttonTexts);

