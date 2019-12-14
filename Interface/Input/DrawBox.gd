extends VBoxContainer

var to_translate = {'ButtonClearDrawing':'drawClear',
					'ButtonUndoDrawing':'drawUndo',
					'LabelDraw':'drawLabel'}

var can_add_drawing = true

var color_on_clear = null
var width_on_clear = 0

func _ready():
	var global = $"/root/GlobalVars"
	global.retranslate(get_node('/root'),to_translate)
	global.adapt_font($HBoxContainer/ButtonClearDrawing,global.FONT_SIZE_SMALL)
	global.adapt_font($HBoxContainer/ButtonUndoDrawing,global.FONT_SIZE_SMALL)

	set_cache_status_label()
	$HBoxContainer/LabelProgress/Label.rect_size = Vector2(70,40)
	
	$LabelDraw.set_mode($LabelDraw.LABEL_MODE_SMALL)
	$LabelDraw.set_width(430)
	
	$HBoxContainer/ButtonClearDrawing.rect_min_size = Vector2(95,20)
	$HBoxContainer/ButtonUndoDrawing.rect_min_size = Vector2(90,20)
	
	
func change_size(new_size:Vector2):
	$AnswerDraw.change_size(new_size)
	
func _on_ButtonClearDrawing_pressed():
	clear_drawing()

func _on_ButtonUndoDrawing_pressed():
	$AnswerDraw.remove_last_line()

func set_color_on_clear(color:Color,width:int=4):
	self.color_on_clear = color
	self.width_on_clear = width

func clear_drawing():
	$AnswerDraw.clear_drawing()
	if self.color_on_clear!= null:
		print("Resetting color")
		$AnswerDraw.change_line_color_to(color_on_clear,width_on_clear)

func get_lines(include_cache=true):
	if include_cache:
		return $AnswerDraw.get_cache_and_lines()
	else:
		return $AnswerDraw.lines
	
func add_lines(lines):
	$AnswerDraw.lines += lines

func load_drawing(filename):
	$AnswerDraw.load_drawing(filename)
	set_cache_status_label()
	
func set_cache_status_label():
	$HBoxContainer/LabelProgress.text = $AnswerDraw.cache_status_string()
	$HBoxContainer/PreviousButton.set_icon("left")
	
	var cst = $AnswerDraw.get_cache_status()
	if cst[0] == cst[1]:
		if can_add_drawing:
			$HBoxContainer/NextButton.set_icon("plus")
		else:
			$HBoxContainer/NextButton.set_icon("empty")
	else:
		$HBoxContainer/NextButton.set_icon("right")
	if cst[0] == 1:
		$HBoxContainer/PreviousButton.disabled = true
	else:
		$HBoxContainer/PreviousButton.disabled = false
		
		
func create_empty_drawings(count,reset_position_to_0=true):
	for _i in range(count):
		$AnswerDraw.load_next_cached()
	if reset_position_to_0:
		$AnswerDraw.load_cached(0)
	set_cache_status_label()

func disable_add_drawing():
	can_add_drawing = false
	set_cache_status_label()
	
func enable_add_drawing():
	can_add_drawing = true
	set_cache_status_label()

func disable_erase():
	$HBoxContainer/ButtonClearDrawing.visible = false
	$HBoxContainer/ButtonUndoDrawing.visible = false
	
func enable_erase():
	$HBoxContainer/ButtonClearDrawing.visible = true
	$HBoxContainer/ButtonUndoDrawing.visible = true

func disable_mouse_interaction():
	$AnswerDraw.disable_mouse_interaction = true
	
func enable_mouse_interaction():
	$AnswerDraw.disable_mouse_interaction = false

func _on_PreviousButton_pressed():
	load_prev_image()
	
func _on_NextButton_pressed():
	load_next_image()

func load_image(indx : int):
	$AnswerDraw.load_cached(indx)
	set_cache_status_label()
	
func load_next_image():
	var cst = $AnswerDraw.get_cache_status()
	if can_add_drawing or cst[0]<cst[1]:
		var _cp = $AnswerDraw.load_next_cached()
		set_cache_status_label()
	
func load_prev_image():
	var _cp = $AnswerDraw.load_prev_cached()
	set_cache_status_label()	