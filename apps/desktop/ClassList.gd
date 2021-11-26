extends Control

var list: VBoxContainer
var list_button = preload("res://ListButton.tscn")
var button_color: Color
var item_desc = {}

func _ready():
	list = $VBox/C/M/VBox
	for class_item in Data.settings.class_list:
		var button = list_button.instance()
		list.add_child(button)
		button.connect("pressed", self, "item_pressed", [button])
	button_color = list.get_child(0).modulate
	update_labels()
	clear_search_box()


func clear_search_box():
	$VBox/SS.grab_focus()
	$VBox/SS.text = ""


func item_pressed(button):
	clear_search_box()
	$VBox/C.scroll_vertical = 0
	for class_item in Data.settings.class_list:
		if class_item.keyword == button.text:
			class_item.weight += 1
			Data.settings_changed = true
			break
	update_labels()


func update_labels():
	var weights = []
	var weighted_items = []
	var unweighted_items = []
	for class_item in Data.settings.class_list:
		var weight = class_item.weight
		if weight > 0:
			weights.append(weight)
			weighted_items.append(class_item.duplicate())
		else:
			unweighted_items.append(class_item)
	weights.sort()
	weights.invert()
	var i = 0
	for weight in weights:
		for item in weighted_items: # Find first item with this weight
			if item.weight == weight:
				var button: Button = list.get_child(i)
				button.text = item.keyword
				button.hint_tooltip = get_brief_description(item.keyword)
				button.modulate = button_color.lightened(0.2)
				item.weight = 0 # Skip this item for this weight from now on
				break
		i += 1
	for item in unweighted_items:
		var button: Button = list.get_child(i)
		button.text = item.keyword
		button.hint_tooltip = get_brief_description(item.keyword)
		button.modulate = button_color
		i += 1
	for item in list.get_children():
		item.visible = true


func _on_SS_text_changed(new_text: String):
	var matches = []
	if new_text.length() > 1:
		# Find close matches
		var idx = 0
		for item in list.get_children():
			if new_text.to_lower() in item.text.to_lower():
				matches.append(idx)
			idx += 1
	# Make all visible or just those matched
	for i in list.get_child_count():
		var vis = true if matches.size() == 0 else i in matches
		list.get_child(i).visible = vis


func get_brief_description(key):
	if not item_desc.has(key):
		item_desc[key] = Data.classes[key].get_string_from_ascii().split("brief_description")[1].split("\n")[1].dedent().replace("[", "").replace("]", "")
	return item_desc[key]
