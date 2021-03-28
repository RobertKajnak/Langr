extends VBoxContainer

var to_translate = {'LabelDraw':'drawLabel'}

var can_add_drawing = true

var color_on_clear = null
var width_on_clear = 0

var current_surface_idx = 0 setget _set_current_surface_idx
var surfaces = []

onready var labelDraw = $HBoxContainerMinimap/LabelDraw
onready var labelProgress = $HBoxContainerMinimap/LabelProgress
onready var nextButton = $HBoxContainerMain/VBoxContainerRight/VBoxContainerNext/HBoxContainerNext/NextButton
onready var prevButton = $HBoxContainerMain/VBoxContainerLeft/VBoxContainerPrevious/HBoxContainerPrevious/PreviousButton
onready var clearButton = $HBoxContainerMain/VBoxContainerRight/HBoxContainerClear/ButtonClearDrawing
onready var undoButton = $HBoxContainerMain/VBoxContainerLeft/HBoxContainerUndo/ButtonUndoDrawing

onready var containerNext = $HBoxContainerMain/VBoxContainerRight/VBoxContainerNext
onready var containerPrevious = $HBoxContainerMain/VBoxContainerLeft/VBoxContainerPrevious
onready var containerUndo = $HBoxContainerMain/VBoxContainerLeft/HBoxContainerUndo
onready var containerClear = $HBoxContainerMain/VBoxContainerRight/HBoxContainerClear


func _ready():
	var global = $"/root/GlobalVars"
	
	var answerDraw = load('res://Interface/Input/DrawSurface.tscn').instance()
	if global.draw_columns > 1:
		$HBoxContainerMain/VBoxContainerLeft/VBoxContainerPrevious/HBoxContainerPrevious/PreviousButton.visible = false
		$HBoxContainerMain/VBoxContainerRight/VBoxContainerNext/HBoxContainerNext/NextButton.visible = false
		$HBoxContainerMinimap/LabelProgress.visible = false
		$HBoxContainerMinimap/LabelDraw.visible = false
		$HBoxContainerMain/SpacerCenter.visible = true
		$HBoxContainerMain/SpacerRight.visible = true
		$HBoxContainerMain/VBoxContainerClearAll.visible = true
		$HBoxContainerMain/VBoxContainerClearAll/ButtonClearAll.visible = true
		$HBoxContainerMain/VBoxContainerClearAll/ButtonClearAll.set_icon('XX')
		$GridContainer.columns = global.draw_columns
		
		if GlobalVars.draw_columns == 3:
			$GridContainer.set("custom_constants/hseparation", 30)
			$GridContainer.set("custom_constants/vseparation", 30)
		elif GlobalVars.draw_columns == 4:
			$GridContainer.set("custom_constants/hseparation", 13)
			$GridContainer.set("custom_constants/vseparation", 20)
		else:
			$GridContainer.set("custom_constants/hseparation", 8)
			$GridContainer.set("custom_constants/vseparation", 15)
		
		$GridContainer.add_child(answerDraw)
		answerDraw.set_true_parent(self)
	else:
		$HBoxContainerMain.add_child_below_node($HBoxContainerMain/VBoxContainerLeft, answerDraw)
	surfaces.append(answerDraw)
	
	global.retranslate(get_node('/root'),to_translate)
	#global.adapt_font(clearButton,global.FONT_SIZE_SMALL)
	#global.adapt_font(undoButton,global.FONT_SIZE_SMALL)
	undoButton.set_icon('undo')
	clearButton.set_icon('X')

	set_cache_status_label()
	labelProgress.set_width(110)#rect_size = Vector2(70,40)
	
	labelDraw.set_mode(labelDraw.LABEL_MODE_SMALL)
	labelDraw.set_width(430)
	
	#clearButton.rect_min_size = Vector2(95,20)
	#undoButton.rect_min_size = Vector2(90,20)

func _set_current_surface_idx(new_val):
	
	#surfaces[current_surface_idx].modulate = Color('ffffff')
	current_surface_idx = new_val
	#surfaces[current_surface_idx].modulate = Color('dad5cb')

func change_size(new_size:Vector2):
	for surface in surfaces:
		surface.change_size(new_size)
	
func _on_ButtonClearDrawing_pressed():
	clear_drawing()

func _on_ButtonUndoDrawing_pressed():
	surfaces[current_surface_idx].remove_last_line()
#!
func set_color_on_clear(color:Color,width:int=4):
	self.color_on_clear = color
	self.width_on_clear = width

func clear_drawing(idx = -1):
	if idx == -1:
		idx = current_surface_idx
	surfaces[idx].clear_drawing()
	if self.color_on_clear!= null:
		#print("Resetting color")
		surfaces[idx].change_line_color_to(color_on_clear,width_on_clear)

func get_lines(include_cache=true):
	if include_cache:
		var cache_arr = []
		for s in surfaces:
			cache_arr += s.get_cache_and_lines()
		return cache_arr
	else:
		return surfaces[current_surface_idx].lines
	
func add_lines(lines):
	surfaces[current_surface_idx].lines += lines

func load_drawing(filename, idx = -1):
	if idx == -1:
		idx = current_surface_idx
	if typeof(filename) == 19:
		for i in len(filename):
			if i!=0:
				load_next_cached()
			surfaces[i].load_drawing(filename[i])
	else:
		surfaces[idx].load_drawing(filename)
		set_cache_status_label()
	
	
func set_cache_status_label():
	if GlobalVars.draw_columns != 1:
		return
	var cst = surfaces[current_surface_idx].get_cache_status()
	
	if cst[1]==1:
		labelDraw.visible = true
		labelProgress.visible = false
	else:
		labelDraw.visible = false
		labelProgress.visible = true
		labelProgress.text = surfaces[current_surface_idx].cache_status_string()
	prevButton.set_icon("left")
	
	nextButton.disabled = false
	#print(can_add_drawing)
	if cst[0] == cst[1]:
		if can_add_drawing:
			nextButton.set_icon("plus")
		else:
			nextButton.set_icon("right")
			nextButton.disabled = true
	else:
		nextButton.set_icon("right")
	if cst[0] == 1:
		prevButton.disabled = true
	else:
		prevButton.disabled = false
		
		
func add_empty_drawing():
	var draw_box = load('res://Interface/Input/DrawSurface.tscn').instance()
	$GridContainer.add_child(draw_box)
	surfaces.append(draw_box)
	_set_current_surface_idx(len(surfaces)-1)
	surfaces[current_surface_idx].set_true_parent(self)
	
	if GlobalVars.draw_columns >1 and len(surfaces)<=GlobalVars.draw_columns:
		$GridContainer.columns  = len(surfaces)
		
func create_empty_drawings(count,reset_position_to_0=true):
	if GlobalVars.draw_columns == 1:
		for _i in range(count):
			surfaces[current_surface_idx].load_next_cached()
		if reset_position_to_0:
			surfaces[current_surface_idx].load_cached(0)
		set_cache_status_label()
	else:
		for _i in range(count):
			add_empty_drawing()
			
			if reset_position_to_0:
				_set_current_surface_idx(0)

func load_next_cached():
	if GlobalVars.draw_columns == 1:
		surfaces[current_surface_idx].load_next_cached()
	else:
		if current_surface_idx+1 >= len(surfaces):
			add_empty_drawing()
#		current_surface_idx += 1

func set_focus_drawing_prev():
	_set_current_surface_idx(max(0, current_surface_idx-1))

func set_focus_drawing_next():
	if current_surface_idx == len(surfaces)-1:
		add_empty_drawing()
		
	_set_current_surface_idx(min(len(surfaces)-1, current_surface_idx+1))
	

func set_focus_drawing(index):
	_set_current_surface_idx(max(0, max(len(surfaces)-1, index)))
	if index != current_surface_idx:
		print("Invalid index requested: ", index)

func change_line_color_to(color, width):
	for s in surfaces:
		s.change_line_color_to(color, width)

func disable_add_drawing():
	if GlobalVars.draw_columns == 1:
		can_add_drawing = false
		set_cache_status_label()

		
func enable_add_drawing():
	if GlobalVars.draw_columns == 1:
		can_add_drawing = true
		set_cache_status_label()


func disable_erase():
	clearButton.visible = false
	undoButton.visible = false
	
func enable_erase():
	clearButton.visible = true
	undoButton.visible = true

func disable_mouse_interaction():
	surfaces[current_surface_idx].disable_mouse_interaction = true
	
func enable_mouse_interaction():
	surfaces[current_surface_idx].disable_mouse_interaction = false

func _on_PreviousButton_pressed():
	load_prev_image()
	
func _on_NextButton_pressed():
	load_next_image()

func _on_ClearButton_pressed():
	clear_drawing()

func _on_ButtonClearAll_pressed():
	for i in len(surfaces):
		clear_drawing(i)

func _on_ButtonAddDedicated_pressed():
	add_empty_drawing()
	
func get_internal_idx():
	return surfaces[current_surface_idx].currently_loaded

func load_image(indx : int):
	surfaces[current_surface_idx].load_cached(indx)
	set_cache_status_label()
	
func load_next_image():
	var cst = surfaces[current_surface_idx].get_cache_status()
	if can_add_drawing or cst[0]<cst[1]:
		var _cp = surfaces[current_surface_idx].load_next_cached()
		set_cache_status_label()
	
func load_prev_image():
	set_focus_drawing_prev()
	var _cp = surfaces[current_surface_idx].load_prev_cached()
	set_cache_status_label()	

func on_pressed(event,control,function):
	if event is InputEventMouseButton:
		if not event.pressed:
			if Rect2(Vector2(0,0),control.rect_size).has_point(event.position):
				self.call(function)

func set_draw_focus(box):
	_set_current_surface_idx(surfaces.find(box))

func _on_VBoxContainerPrevious_gui_input(event):
	on_pressed(event,containerPrevious,'_on_PreviousButton_pressed')

func _on_VBoxContainerNext_gui_input(event):
	on_pressed(event,containerNext,'_on_NextButton_pressed')

func _on_HBoxContainerUndo_gui_input(event):
	on_pressed(event,containerUndo,'_on_UndoButton_pressed')

func _on_HBoxContainerClear_gui_input(event):
	on_pressed(event,containerClear,'_on_ClearButton_pressed')

func _on_VBoxContainerClearAll_gui_input(event):
	on_pressed(event,containerClear,'_on_ButtonClearAll_pressed')


