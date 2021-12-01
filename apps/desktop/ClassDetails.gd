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
	"properties",
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
	#update_content("CollisionObject2D")
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
			add_items_to_tab(key, tab, info[key])


func add_items_to_tab(prop, tab: RichContent, items):
	var content = PoolStringArray([])
	match prop:
		"methods":
			content.append("[table=2]")
			for key in items.keys():
				content.append(get_method_string(key, items[key]))
			content.append("[/table]")
		"properties":
			content.append("[table=2]")
			for key in items.keys():
				content.append(get_property_string(key, items[key]))
			content.append("[/table]")
		"signals":
			for key in items.keys():
				content.append(key + " (" + get_args(items[key].args) + ")\n[indent]" + items[key].description + "[/indent]\n")
		"constants":
			pass
		"tutorials":
			for link in items:
				content.append(get_link_string(link))
		"theme_items":
			pass
	tab.set_content(content.join("\n"))


func get_link_string(link):
	if link.title == "":
		link.title = link.url
	return "[url=%s]%s[/url]" % [link.url, link.title]


func get_signal_string(sname, attribs):
	return "[cell]%s (%s)[/cell]" % [sname, get_args(attribs.args)]


func get_property_string(pname, attribs: Dictionary):
	var ps = PoolStringArray([])
	ps.append("[cell][right]%s[/right]\t[/cell][cell]%s %s[/cell]" % [get_return_type_string(attribs.type), pname, get_default_property_value(attribs)])
	return ps.join("\n")


func get_method_string(mname, items):
	var ms = PoolStringArray([])
	for item in items:
		ms.append("[cell][right]%s[/right]\t[/cell][cell]%s(%s) %s[/cell]" % [get_return_type_string(item.return_type), mname, get_args(item.args), item.qualifiers])
	return ms.join("\n")


func get_default_property_value(item: Dictionary):
	var ds = item.get("default", "")
	return "[default: %s]" % [ds] if ds.length() > 0 else ""


func get_return_type_string(type):
	return "[" + type + "]" if type != "void" else type

func get_args(args: Array):
	var astr = PoolStringArray([])
	var dict = {}
	for arg in args:
		dict[arg.index] = arg
	var keys = dict.keys()
	keys.sort()
	for key in keys:
		astr.append("%s: [%s]%s" % [dict[key].name, dict[key].type, get_default_arg_value(dict[key])])
	return astr.join(", ")


func get_default_arg_value(arg: Dictionary):
	if arg.has("default"):
		return " = " + arg["default"]
	else:
		return ""


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
							info[node_name] = []
							group_name = node_name
						"link":
							var link = {
								"title": parser.get_named_attribute_value_safe("title")
							}
							info[group_name].append(link)
							text_target = link
							text_node_name = "url"
						"methods":
							info[node_name] = {} # Methods may have the same name
							group_name = node_name
							text_node_name = "description"
						"method":
							var method_name = parser.get_named_attribute_value("name")
							var method = {
								"qualifiers": parser.get_named_attribute_value_safe("qualifiers"),
								"args": [],
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
							method_target["return_type"] = get_type(parser)
						"argument":
							add_arg(parser, method_target)
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
								"args": [],
							}
							info[group_name][member_name] = asignal
							text_target = info[group_name][member_name]
							text_mode = RAW
							method_target = asignal
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
								txt = remove_square_braces(txt)
							text_target[text_node_name] = txt
							text_target = null
	return info


func get_type(parser):
	var _type = parser.get_named_attribute_value("type")
	var _enum = parser.get_named_attribute_value_safe("enum")
	if _enum.length() > 0:
		_type = _enum
	return _type


func add_member(parser: XMLParser, info: Dictionary, group_name, keys: Array) -> String:
	var member_name = parser.get_named_attribute_value("name")
	var member = {}
	for key in keys:
		member[key] = parser.get_named_attribute_value_safe(key)
	info[group_name][member_name] = member
	return member_name


func add_arg(parser: XMLParser, method_target):
	var num_atrs = parser.get_attribute_count()
	var atrs = {}
	for idx in num_atrs:
		atrs[parser.get_attribute_name(idx)] = parser.get_attribute_value(idx)
	method_target["args"].append(atrs)


func get_node_text(txt: String):
	return txt.lstrip("\n\t ").rstrip("\n\t ").replace("\t", "")


func remove_square_braces(txt):
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
