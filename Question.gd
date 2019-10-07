extends Control

# Declare member variables here. Examples:
# var a = 2
# var b = "text"

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.

func _unhandled_input(event):
    if event is InputEventKey:
        if event.pressed and event.scancode == KEY_ESCAPE:
            get_tree().change_scene('res://MainMenu.tscn')
			
func _notification(what):
    if what == MainLoop.NOTIFICATION_WM_QUIT_REQUEST:
        # For Windows
        pass        
    if what == MainLoop.NOTIFICATION_WM_GO_BACK_REQUEST: 
        # For android
        get_tree().change_scene('res://MainMenu.tscn')