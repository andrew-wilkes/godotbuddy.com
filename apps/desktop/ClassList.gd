extends Control

var list: VBoxContainer

func _ready():
	list = $VBox/C/VBox
	for class_item in Data.settings.class_list:
		var label = Label.new()
		label.text = class_item
		list.add_child(label)
	$VBox/SS.grab_focus()


func _on_SS_text_changed(new_text: String):
	if new_text.length() > 1:
		# Find close matches
		var matches = []
		for i in list.get_child_count():
			if new_text.to_lower() in Data.settings.class_list[i].to_lower():
				matches.append(i)
		for i in list.get_child_count():
			var vis = true if matches.size() == 0 else i in matches
			list.get_child(i).visible = vis
