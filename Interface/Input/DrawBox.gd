extends VBoxContainer

var to_translate = {'LabelDraw':'drawLabel'}

var can_add_drawing = true

var color_on_clear = null
var width_on_clear = 0

onready var labelDraw = $HBoxContainerMinimap/LabelDraw
onready var labelProgress = $HBoxContainerMinimap/LabelProgress
onready var answerDraw = $HBoxContainerMain/AnswerDraw
onready var nextButton = $HBoxContainerMain/VBoxContainerRight/VBoxContainerNext/HBoxContainerNext/NextButton
onready var prevButton = $HBoxContainerMain/VBoxContainerLeft/VBoxContainerPrevious/HBoxContainerPrevious/PreviousButton
onready var clearButton = $HBoxContainerMain/VBoxContainerRight/ButtonClearDrawing
onready var undoButton = $HBoxContainerMain/VBoxContainerLeft/ButtonUndoDrawing

func _ready():
	var global = $"/root/GlobalVars"
	global.retranslate(get_node('/root'),to_translate)
	#global.adapt_font(clearButton,global.FONT_SIZE_SMALL)
	#global.adapt_font(undoButton,global.FONT_SIZE_SMALL)
	undoButton.set_icon('undo')
	clearButton.set_icon('X')

	set_cache_status_label()
	labelProgress.set_width(70)#rect_size = Vector2(70,40)
	
	labelDraw.set_mode(labelDraw.LABEL_MODE_SMALL)
	labelDraw.set_width(430)
	
	#clearButton.rect_min_size = Vector2(95,20)
	#undoButton.rect_min_size = Vector2(90,20)
	
	
func change_size(new_size:Vector2):
	answerDraw.change_size(new_size)
	
func _on_ButtonClearDrawing_pressed():
	clear_drawing()

func _on_ButtonUndoDrawing_pressed():
	answerDraw.remove_last_line()

func set_color_on_clear(color:Color,width:int=4):
	self.color_on_clear = color
	self.width_on_clear = width

func clear_drawing():
	answerDraw.clear_drawing()
	if self.color_on_clear!= null:
		print("Resetting color")
		answerDraw.change_line_color_to(color_on_clear,width_on_clear)

func get_lines(include_cache=true):
	if include_cache:
		return answerDraw.get_cache_and_lines()
	else:
		return answerDraw.lines
	
func add_lines(lines):
	answerDraw.lines += lines

func load_drawing(filename):
	answerDraw.load_drawing(filename)
	set_cache_status_label()
	
func set_cache_status_label():
	if answerDraw.get_cache_status()[1]==1:
		labelDraw.visible = true
		labelProgress.visible = false
	else:
		labelDraw.visible = false
		labelProgress.visible = true
		labelProgress.text = answerDraw.cache_status_string()
	prevButton.set_icon("left")
	
	var cst = answerDraw.get_cache_status()
	if cst[0] == cst[1]:
		if can_add_drawing:
			nextButton.set_icon("plus")
		else:
			nextButton.set_icon("empty")
	else:
		nextButton.set_icon("right")
	if cst[0] == 1:
		prevButton.disabled = true
	else:
		prevButton.disabled = false
		
		
func create_empty_drawings(count,reset_position_to_0=true):
	for _i in range(count):
		answerDraw.load_next_cached()
	if reset_position_to_0:
		answerDraw.load_cached(0)
	set_cache_status_label()

func disable_add_drawing():
	can_add_drawing = false
	set_cache_status_label()
	
func enable_add_drawing():
	can_add_drawing = true
	set_cache_status_label()

func disable_erase():
	clearButton.visible = false
	undoButton.visible = false
	
func enable_erase():
	clearButton.visible = true
	undoButton.visible = true

func disable_mouse_interaction():
	answerDraw.disable_mouse_interaction = true
	
func enable_mouse_interaction():
	answerDraw.disable_mouse_interaction = false

func _on_PreviousButton_pressed():
	load_prev_image()
	
func _on_NextButton_pressed():
	load_next_image()

func load_image(indx : int):
	answerDraw.load_cached(indx)
	set_cache_status_label()
	
func load_next_image():
	var cst = answerDraw.get_cache_status()
	if can_add_drawing or cst[0]<cst[1]:
		var _cp = answerDraw.load_next_cached()
		set_cache_status_label()
	
func load_prev_image():
	var _cp = answerDraw.load_prev_cached()
	set_cache_status_label()	