extends RichTextLabel

class_name RichContent

export(Color) var code_color = Color(255, 155, 0)

func set_content(txt: String):
	txt = add_links(txt)
	bbcode_text = txt.c_unescape() \
	.replace("codeblock]", "code]") \
	.replace("[code]", "[code][color=#" + code_color.to_html(false) + "]") \
	.replace("[/code]", "[/color][/code]")


func add_links(txt: String):
	var regex = RegEx.new()
	regex.compile("\\[([A-Z]\\w+|bool|float|int|(\\w+ (\\w+)))\\]")
	for result in regex.search_all(txt):
		var url = result.get_string(1)
		var link_text = url
		var goto = result.get_string(2)
		if goto.length() > 0:
			url = goto
			link_text = result.get_string(3)
		var link = "[url=%s]%s[/url]" % [url, link_text]
		var target = result.get_string(0)
		txt = txt.replace(target, link)
	return txt
