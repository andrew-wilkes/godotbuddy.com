extends Control

var list_of_classes = []

class info:
	var brief_description = ""
	var description = ""
	var tutorials = []

func _ready():
	list_of_classes = Data.classes.keys()
	list_of_classes.sort()


func _on_ClassList_pressed():
	concat_results(list_of_classes)


func _on_NoBriefDescriptions_pressed():
	var results = PoolStringArray([])
	var regex = RegEx.new()
	regex.compile("<brief_description>.+<\\/brief_description>")
	for cname in list_of_classes:
		var xml: String = Data.classes[cname].get_string_from_ascii().replace("\n", "").replace("\t", "")
		var result = regex.search(xml)
		if result:
			pass #print(result.get_string())
		else:
			results.append(cname)
	concat_results(results)


func _on_NoDescriptions_pressed():
	var results = PoolStringArray([])
	var regex = RegEx.new()
	regex.compile("<description>.+?<\\/description>")
	for cname in list_of_classes:
		var xml: String = Data.classes[cname].get_string_from_ascii().replace("\n", "").replace("\t", "")
		var result = regex.search(xml)
		if result:
			pass #print(result.get_string())
		else:
			results.append(cname)
		pass
	concat_results(results)


func _on_Methods_pressed():
	var results = PoolStringArray([])
	var regex = RegEx.new()
	regex.compile("<method name=\"(\\w+)\">.+?<description>(.*?)<\\/description><\\/method>")
	for cname in list_of_classes:
		var xml: String = Data.classes[cname].get_string_from_ascii().replace("\n", "").replace("\t", "")
		for result in regex.search_all(xml):
			if result.get_string(2).length() == 0:
				results.append(cname + "\t" + result.get_string(1))
	concat_results(results)


func _on_Tutorials_pressed():
	var results = PoolStringArray([])
	var regex = RegEx.new()
	regex.compile("<tutorials>(.+?)<\\/tutorials>")
	for cname in list_of_classes:
		var xml: String = Data.classes[cname].get_string_from_ascii().replace("\n", "").replace("\t", "")
		var result = regex.search(xml)
		if result:
			pass
		else:
			results.append(cname)
		pass
	concat_results(results)


func concat_results(results: PoolStringArray):
	$HBox/TextBox.text = PoolStringArray(results).join("\n")


func _on_Links_pressed():
	var results = PoolStringArray([])
	var regex = RegEx.new()
	regex.compile('<link.*>(.+?)<\\/link>')
	for cname in list_of_classes:
		var xml: String = Data.classes[cname].get_string_from_ascii().replace("\n", "").replace("\t", "")
		for result in regex.search_all(xml):
			results.append(cname + "\t" + result.get_string(1))
	concat_results(results)
