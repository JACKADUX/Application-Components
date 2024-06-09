# 用于向下传递信息
class_name UpdateMessage extends BaseMessage

#---------------------------------------------------------------------------------------------------
class Update extends UpdateMessage: 
	var data
	func _to_string():
		return "Update"

		
		
		
		
		
		
		
		
		
		
