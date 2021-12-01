extends Control

enum { RAW, FORMATTED }

export(int) var max_description_size_y = 400

var desc: RichTextLabel
var descbox
var notes
var desc_button
var notes_button
var first_run = true
var history = []
var stepping_back = false
var back_button
var tab_list = [
	"methods",
	"members",
	"signals",
	"constants",
	"tutorials",
	"theme_items",
]
var tabs

func _ready():
	desc = find_node("Desc")
	descbox = find_node("DescBox")
	notes = find_node("Notes")
	desc_button = find_node("DescButton")
	notes_button = find_node("NotesButton")
	back_button = find_node("BackButton")
	tabs = find_node("TabContainer")
	back_button.disabled = true
	descbox.hide()
	notes.get_parent().hide()
	update_content("File")


func update_content(cname, new = true):
	if new:
		if stepping_back:
			history.clear()
			stepping_back = false
		set_back_button_state()
		history.append(cname)
	else:
		if not stepping_back:
			stepping_back = true
			# Get the previous cname
			cname = history.pop_back()
		set_back_button_state()

	var info = get_info(cname)
	find_node("ClassName").text = cname
	find_node("BDesc").set_content(info.brief_description)
	desc.set_content(info.description)
	call_deferred("set_description_scroll_container_size")
	
	# Set up tabs
	var remove = false
	for tab in tabs.get_children():
		if remove:
			# Avoid problem of duplicate names
			tab.name = "x"
			tab.queue_free()
		remove = true
	var add = false
	var tab = tabs.get_child(0)
	for key in tab_list:
		if info.has(key):
			if add:
				tab = tab.duplicate()
				tabs.add_child(tab)
			tab.name = key.capitalize()
			add = true
			add_items_to_tab(tab, info[key])


func add_items_to_tab(tab: RichContent, items):
	var content = PoolStringArray([])
	for key in items.keys():
		content.append(key)
	tab.set_content(content.join("\n"))


func set_back_button_state():
	back_button.disabled = true if history.size() < 1 else false


func set_description_scroll_container_size():
	if first_run:
		first_run = false
		# RichTextLabel does not resize on first run if child of scroll container
		desc.get_parent().remove_child(desc)
		descbox.get_child(0).get_child(0).add_child(desc)
	# Make RichTextLabel shrink to fit content
	desc.rect_size.y = 0
	# Set min size of scroll container based on desc size.y
	var scroll_container = descbox.get_child(0)
	scroll_container.rect_min_size.y = min(desc.rect_size.y, max_description_size_y)


func get_info(cname) -> Dictionary:
	var info = {}
	var node_name = ""
	var group_name = ""
	var member_name = ""
	var text_target
	var method_target
	var text_node_name
	var text_mode
	var parser = XMLParser.new()
	if parser.open_buffer(Data.classes[cname]) == OK:
		while true:
			if parser.read() != OK:
				return info
			match parser.get_node_type():
				parser.NODE_ELEMENT:
					node_name = parser.get_node_name()
					match node_name:
						"brief_description":
							text_mode = RAW
							text_target = info
							text_node_name = node_name
						"description":
							if group_name == "":
								text_mode = RAW
								text_target = info
								text_node_name = node_name
						"tutorials":
							info[node_name] = {}
							group_name = node_name
						"link":
							text_node_name = parser.get_named_attribute_value_safe("title")
							text_target = info[group_name]
						"methods":
							info[node_name] = {} # Methods may have the same name
							group_name = node_name
							text_node_name = "description"
						"method":
							var method_name = parser.get_named_attribute_value("name")
							var method = {
								"qualifiers": parser.get_named_attribute_value_safe("qualifiers"),
								"args": {},
								"return_type": "",
								"description": "",
							}
							if info[group_name].has(method_name):
								info[group_name][method_name].append(method)
							else:
								info[group_name][method_name] = [method]
							method_target = method
							text_target = method
							text_mode = RAW
						"return":
							method_target["return_type"] = parser.get_named_attribute_value("type")
						"argument":
							var keys = ["index", "type", "default"]
							var _member_name = add_argument(parser, method_target, keys)
						"members":
							info["properties"] = {}
							group_name = "properties"
						"member":
							var keys = ["type", "setter", "getter", "default"]
							member_name = add_member(parser, info, group_name, keys)
							text_target = info[group_name][member_name]
							text_mode = RAW
						"signals":
							info[node_name] = {}
							group_name = node_name
						"signal":
							member_name = parser.get_named_attribute_value("name")
							var asignal = {
								"args": {},
							}
							info[group_name][member_name] = asignal
							text_target = info[group_name][member_name]
							text_mode = RAW
						"constants":
							info[node_name] = {}
							group_name = node_name
						"constant":
							var keys = ["value", "enum"]
							member_name = add_member(parser, info, group_name, keys)
							text_target = info[group_name][member_name]
							text_mode = RAW
				parser.NODE_TEXT:
					if text_target != null:
						var txt = get_node_text(parser.get_node_data())
						# We get unexpected blank text nodes, so ignore them
						if txt.length() > 0:
							if text_mode == FORMATTED:
								txt = format_text(txt)
							text_target[text_node_name] = txt
							text_target = null
	return info


func add_member(parser: XMLParser, info: Dictionary, group_name, keys: Array) -> String:
	var member_name = parser.get_named_attribute_value("name")
	var member = {}
	for key in keys:
		member[key] = parser.get_named_attribute_value_safe(key)
	info[group_name][member_name] = member
	return member_name


func add_argument(parser: XMLParser, method_target, keys: Array):
	var arg_name = parser.get_named_attribute_value("name")
	var arg = {}
	for key in keys:
		arg[key] = parser.get_named_attribute_value_safe(key)
	method_target["args"][arg_name] = arg


func get_node_text(txt: String):
	return txt.lstrip("\n\t ").rstrip("\n\t ").replace("\t", "")


func format_text(txt):
	return txt.replace("[", "").replace("]", "")


func _on_meta_clicked(meta):
	meta = String(meta)
	if meta.begins_with("http"):
		var _e = OS.shell_open(str(meta))
	else:
		update_content(meta)


func _on_Description_pressed():
	descbox.visible = not descbox.visible
	desc_button.text = "-" if descbox.visible else "+"


func _on_NotesButton_pressed():
	var nb = notes.get_parent()
	nb.visible = not nb.visible
	notes_button.text = "-" if nb.visible else "+"


func _on_BackButton_pressed():
	update_content(history.pop_back(), false)
