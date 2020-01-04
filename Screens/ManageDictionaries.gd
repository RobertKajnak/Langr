extends Control

var global


const unselected_color = Color(1,1,1)
const selected_color = Color(0.2,0,0.6)

var currently_selected = null

func _ready():
	global = $"/root/GlobalVars"
	
	$VBoxContainer/HeaderContainer.set_text(tr("dictionaries"))
	populate()
		
func populate():
	var path = 'user://dictionaries'
	var dir = Directory.new()
	if dir.dir_exists(path):
		for f in global.list_files_in_directory(path):
			var HC = HBoxContainer.new()
			$VBoxContainer/ScrollContainerDicts/VBoxContainerDicts.add_child(HC)
			
			
			var label = preload("res://Interface/TextDisplay/LabelAdaptive.tscn").instance()
			HC.add_child(label)
			label.set_mode("small")
			label.text = f
			label.set_valign(VALIGN_CENTER)
			label.get_node('Label').add_color_override("font_color",unselected_color)
			label.adapt()
			
			HC.connect("gui_input",self,"check_for_click",[label])
			label.connect("gui_input",self,"check_for_click",[label])
	else:
		print("Dict folder doesn't exist. Creating")
var button_down = false
func check_for_click(event,fileLabel):
	#print(event is InputEventMouseMotion)
	if event is InputEventMouseButton:
		if button_down:
			file_clicked(fileLabel)
		button_down = !button_down
	
func file_clicked(fileLabel):
	if currently_selected == fileLabel:
		return
	
	if currently_selected != null:
		currently_selected.get_node('Label').add_color_override("font_color",unselected_color)
		
	fileLabel.get_node('Label').add_color_override("font_color",selected_color)
	currently_selected = fileLabel
	print(fileLabel.text)
	

func _on_ButtonDelete_pressed():
	global.active_dict = {}
	global.delete_dictionary(currently_selected.text)
	go_back()

	
func import_lesson(filename):
	var popup = preload("res://Interface/Interactive/ErrorPopup.tscn").instance()
	add_child(popup)
	if global.import_dictionary(filename):
		global.to_transition_scene(get_tree(),'res://Screens/MainMenu.tscn',\
				tr('importSuccessTitle'),tr('importSuccessMessage').format({'lesson':filename.replace('/','/ ')}))
		
	else:
		popup.display(tr('importFailTitle'),tr('importFailMessage'))
		

func _on_ButtonImport_pressed():
	global.active_dict = {}
	var fd
	if OS.get_name() in ["Android"]:
		if not global.check_if_folder_ok_android():
			var popup = preload("res://Interface/Interactive/ErrorPopup.tscn").instance()
			add_child(popup)
			popup.display(tr('fileSaveFailTitle'),tr('fileSaveFailMessage'))
		else:
			fd = preload("res://Interface/Interactive/FileDialogRestricted.tscn").instance()
			get_node('.').add_child(fd)
			fd.load_folder(global.ANDROID_PATH,'.dict',false,tr("chooseFilename"),"",true)
	else:
		fd = global.create_file_dialog(get_viewport_rect(),get_node('.'),FileDialog.MODE_OPEN_FILE,["*.dict ; Dictionary File"])
	fd.connect("file_selected",self,"import_lesson")
	
func go_back():
	var _err = get_tree().change_scene('res://Screens/MainMenu.tscn')
	
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

