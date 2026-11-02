extends Node

signal loading_finished
signal progressing

var LoadingScene : PackedScene = preload("uid://dhj5xw50vas1q")
var SceneStatus : Array
var Load : bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	
	pass # Replace with function body.


## Lädt eine Scene mit Ladeszene. 
## Eingabe Scene: rechtsklick auf Scene -> UID kopieren, UID in "" einfügen
## Eingabe fastload(optional): 1 ist schneller, 0 kann bei ladefehlern helfen
func LoadScene( Scene : String, fastload : bool = 1 ) -> void:
	
	ResourceLoader.load_threaded_request(Scene,"", fastload)
	
	var TransitionScene = LoadingScene.instantiate()
	add_child(TransitionScene)
	
	loading_finished.connect(TransitionScene.on_load_finished)
	progressing.connect(TransitionScene.on_progress_changed)
	
	progressing.emit(0.5)
	
	await TransitionScene.trans_finished
	
	change_scene(Scene)
	
	pass

##interne Funktion 
func change_scene( Scene : String ) -> void:
	while Load:
		ResourceLoader.load_threaded_get_status(Scene,SceneStatus)
		
		progressing.emit(SceneStatus[0])
		
		if SceneStatus[0] == 1:
			
			var Szene = ResourceLoader.load_threaded_get(Scene)
			get_tree().change_scene_to_packed(Szene)
			
			loading_finished.emit()
			
			Load = false
	Load = true

## Lädt eine Scene mit Ladeszene. 
##Eingabe: rechtsklick auf Scene -> UID kopieren, UID in "" einfügen
##@deprecated
func LoadSceneTest( Scene:String ) -> void:
	
	
	ResourceLoader.load_threaded_request(Scene,"",1)
	
	while Load:
		ResourceLoader.load_threaded_get_status(Scene,SceneStatus)
		if SceneStatus[0] == 1:
			var Szene = ResourceLoader.load_threaded_get(Scene)
			get_tree().change_scene_to_packed(Szene)
			Load = false
	Load = true
	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
