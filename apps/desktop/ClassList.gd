extends Control

var list: VBoxContainer

func _ready():
	list = $VBox/C/VBox
	for class_item in Data.settings.class_list:
		var label = Label.new()
		label.text = class_item.keyword
		list.add_child(label)
	update_labels()
	$VBox/SS.grab_focus()


func update_labels():
	var weights = []
	var weighted_items = {}
	var unweighted_items = []
	for class_item in Data.settings.class_list:
		var weight = class_item.weight
		if weight > 0:
			weights.append(weight)
			weighted_items[weight] = class_item.keyword
		else:
			unweighted_items.append(class_item.keyword)
	weights.sort()
	weights.invert()
	var i = 0
	for weight in weights:
		list.get_child(i).text = weighted_items[weight]
		i += 1
	for keyword in unweighted_items:
		list.get_child(i).text = keyword
		i += 1


func _on_SS_text_changed(new_text: String):
	if new_text.length() > 1:
		# Find close matches
		var matches = []
		for i in list.get_child_count():
			if new_text.to_lower() in Data.settings.class_list[i].keyword.to_lower():
				matches.append(i)
		for i in list.get_child_count():
			var vis = true if matches.size() == 0 else i in matches
			list.get_child(i).visible = vis
