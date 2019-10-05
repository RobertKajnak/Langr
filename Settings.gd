extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var buttonTexts = {'LabelTitle':'settings','LabelLanguage':'language'}

# Called when the node enters the scene tree for the first time.
func _ready():
	var langs = get_node("/root/GlobalVars")
	var ButtonLang = $VBoxContainer/ScrollContainer/VBoxContainer/HBoxContainer/ButtonLanguage
	for lang in langs.langs:
		ButtonLang.add_item(lang);
	ButtonLang.select(langs.currentLang);
	retranslate($VBoxContainer);

func retranslate(node):
	if node.name in buttonTexts:
		node.text = tr(buttonTexts[node.name])
	for child in node.get_children():
		retranslate(child)

func _unhandled_input(event):
    if event is InputEventKey:
        if event.pressed and event.scancode == KEY_ESCAPE:
            get_tree().change_scene('res://MainMenu.tscn')

func _on_ButtonLanguage_item_selected(ID):
	var globals = get_node("/root/GlobalVars")
	globals.currentLang = ID;
	TranslationServer.set_locale(globals.langs[globals.currentLang])
	retranslate($VBoxContainer);

