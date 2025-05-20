class_name TagFactory extends Object

static func import_properties(tag: Tag, properties: Dictionary) -> Tag:
	for property in properties.keys():
		tag.set(property, properties[property])
	return tag

static func import_tag(data: Dictionary) -> Tag:
	var tag_path: String = data.resource_path
	var tag: Tag = load(tag_path).new()
	var properties = data.duplicate()
	properties.erase("resource_path")
	import_properties(tag, properties)
	return tag

static func encode_tags(tags: Array[Tag]) -> Array[Dictionary]:
	var encoded_tags: Array[Dictionary]
	for tag: Tag in tags:
		encoded_tags.append(tag.export_tag())
	return encoded_tags
