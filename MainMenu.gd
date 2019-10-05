extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	for control in $CenterContainer/VBoxContainer2/VBoxContainer.get_children():
		if "Button" in control.name:
			control.connect("pressed",self,"_on_ButtonStart_pressed",[control.scene_to_load]);


func _on_ButtonStart_pressed(to_load):
	get_tree().change_scene(to_load)

func _unhandled_input(event):
    if event is InputEventKey:
        if event.pressed and event.scancode == KEY_ESCAPE:
            get_tree().quit()