extends Control

signal file_selected(file_name)
signal cancelled 
signal option_toggled(status)

const unselected_color = Color(1,1,1)
const selected_color = Color(0.2,0,0.6)

var currently_selected = null
var path = ''
var filter = null

func _ready():
	self.visible = false
	pass

func load_folder(path, filter=null, save_dialog = false, message = null, option_text:String = '', return_full_path = false):
	"""Displays the file prompt at the specified path. 
	Params:
		path:
			path of the folder
		filter:
			only includes the specified extensions. Null value shows all
		save_dialog: 
			true: save button
			false: select button
		message:
			If message is left as null, the provided path will be used as a header. Using an emptystring will hide the header.
		option_text: 
			ditto
		return_full_path:
			attaches the path to the filename selected 
	"""
	
	self.filter = filter
	
	if return_full_path:
		self.path = path
	
	if message==null:
		message = str(path)
	elif message == '':
		$VBoxContainer/LableAdaptive.visible = false
		
	$VBoxContainer/LableAdaptive.text = message
	$VBoxContainer/LableAdaptive.set_width($VBoxContainer.rect_size.x)

	if option_text == '':
		$VBoxContainer/CheckBox.visible = false
	else:
		$VBoxContainer/CheckBox.text = option_text
		$"/root/GlobalVars".adapt_font($VBoxContainer/CheckBox)
	

	if save_dialog:
		$VBoxContainer/HBoxContainer/ButtonSelect.text_loc = "save"
	else:
		$VBoxContainer/HBoxContainer/ButtonSelect.text_loc = "select"
		
	$VBoxContainer/HBoxContainer/ButtonSelect._ready()
	
	self.visible = true
	
	populate_with_files(path)
	
func has_valid_extension(file_name,filter):
	if filter == null:
		return true
	else:
		if filter is String:
			filter = [filter]
		for ft in filter:
			if ft[0] != '.':
				ft = '.' + ft
			if file_name.substr(file_name.length()-ft.length(),ft.length()) == ft:
				return true
	return false
			
func list_files_in_directory(path):
	var file_list = []
	var dir = Directory.new()
	if dir.open(path) == OK:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while (file_name != ""):
			if not file_name in ['.','..'] and has_valid_extension(file_name,self.filter):
				file_list.append([file_name,dir.current_is_dir()])
			file_name = dir.get_next()
	else:
		print("An error occurred when trying to access the path.")
	return file_list
	
func populate_with_files(path):
	var dir = Directory.new()
	
	if dir.dir_exists(path):
		for f in list_files_in_directory(path):
			var HC = HBoxContainer.new()
			$VBoxContainer/ScrollContainer/VBoxContainerFiles.add_child(HC)
			
			var icon = preload("res://Interface/Buttons/IconButton.tscn").instance()
			if f[1]:
				icon.set_icon('folder')
			else:
				icon.set_icon('file')
			
			HC.add_child(icon)
			
			var label = preload("res://Interface/TextDisplay/LabelAdaptive.tscn").instance()
			HC.add_child(label)
			label.set_mode("small")
			label.text = f[0]
			label.set_valign(VALIGN_CENTER)
			label.find_node('Label').rect_size.y = icon.rect_size.y*0.9
			label.get_node('Label').add_color_override("font_color",unselected_color)
			
			icon.connect("pressed",self,"file_clicked",[label])
			HC.connect("gui_input",self,"check_for_click",[label])
			label.connect("gui_input",self,"check_for_click",[label])
	
func file_clicked(fileLabel):
	if currently_selected == fileLabel:
		return
	
	if currently_selected != null:
		currently_selected.get_node('Label').add_color_override("font_color",unselected_color)
		
	fileLabel.get_node('Label').add_color_override("font_color",selected_color)
	currently_selected = fileLabel
	
	$VBoxContainer/TextEditFreeform.text = fileLabel.text
	
var button_down = false
func check_for_click(event,fileLabel):
	#print(event is InputEventMouseMotion)
	if event is InputEventMouseButton:
		if button_down:
			file_clicked(fileLabel)
		button_down = !button_down

func close():
	self.visible = false
	self.queue_free()
	
func _on_ButtonSelect_pressed():
	emit_signal("file_selected",path+'/'+$VBoxContainer/TextEditFreeform.text)
	close()
	
func _on_ButtonCancel_pressed():
	emit_signal("cancelled")
	self.queue_free()
	close()

func _on_CheckBox_toggled(button_pressed):
	emit_signal("option_toggled",button_pressed)
