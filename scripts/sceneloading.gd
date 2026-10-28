extends Node

var LoadingScene : PackedScene = preload("uid://e64ursa2s12v")
var SceneStatus : Array
var Load : bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	
	pass # Replace with function body.


## Lädt eine Scene ohne Ladeszene. 
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


##Vermutlich besser die Finger weg lassen (macht viele Rechnungen)
func Stupid() -> void:
	var peter = 0.003
	var start_time = Time.get_ticks_msec()
	while Time.get_ticks_msec() - start_time < 2000: # blocks for 2 seconds
		peter = peter * peter + 1 + 12/peter
		peter = peter * peter + 1 + 12
		peter = peter * peter + 1 + 12
		peter = peter * peter + 1 + 12
		peter = peter * peter + 1 + 12
		peter = peter * peter + 1 + 12
		peter = peter * peter + 1 + 12
	pass
pass

## Lädt eine Scene mit Ladeszene. 
##Eingabe: rechtsklick auf Scene -> UID kopieren, UID in "" einfügen
func LoadScene( Scene:String ) -> void:
	
	
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
