extends TextureProgressBar



func _process(_delta: float) -> void:
	
	texture_progress = Sceneloading.SceneStatus[0] * 100
	


func _on_tree_entered() -> void:
	
	set_process(true)
	
	pass # Replace with function body.


func _on_tree_exited() -> void:
	
	set_process(false)
	
	pass # Replace with function body.
