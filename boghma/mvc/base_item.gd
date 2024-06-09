class_name BaseItem extends UniformData

var title:String=""

#---------------------------------------------------------------------------------------------------
func set_title(value:String):
	title = value
	
#---------------------------------------------------------------------------------------------------
func get_title():
	return title

#---------------------------------------------------------------------------------------------------
func remove():
	get_parent().remove_child(self)

#---------------------------------------------------------------------------------------------------
func deserialization(value:Dictionary):
	set_title(value.get("title", ""))
	
#---------------------------------------------------------------------------------------------------
func serialization() -> Dictionary:
	var pid = null
	if get_parent():
		pid = get_parent().get_id()
		
	return {
		"id":get_id(),
		"type":get_type(),
		"pid":pid,
		"title":title
	}
	
		
#===================================================================================================
class GroupItem extends BaseItem:pass

