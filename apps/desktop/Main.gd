extends Control

enum { ABOUT, LICENCES }

func _ready():
	var hm = $VBox/Menu/Help.get_popup()
	hm.add_item("About", ABOUT, KEY_MASK_CTRL | KEY_A)
	hm.add_separator()
	hm.add_item("Licences", LICENCES)
	hm.connect("id_pressed", self, "_on_HelpMenu_id_pressed")
	var h = InputEventKey.new()
	h.alt = true
	h.scancode = KEY_H
	$VBox/Menu/Help.shortcut = h


func _on_ClassExplorer_pressed():
	var _e = get_tree().change_scene("res://ClassList.tscn")


func _on_HelpMenu_id_pressed(id):
	match id:
		ABOUT:
			$c/About.popup_centered()
		LICENCES:
			$c/Licences.popup_centered()


func _on_ok_pressed():
	$c/Licences.hide()
