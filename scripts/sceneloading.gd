extends Node

var LoadingScene : PackedScene
var SceneStatus : Array
var Load : bool = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Lädt eine Scene ohne Ladeszene. Eingabe: "scenes//name_der_szene.tscn"
func LoadScene( Scene:String ) -> void:
	
	ResourceLoader.load_threaded_request(Scene)

	while Load:
		ResourceLoader.load_threaded_get_status(Scene,SceneStatus)
		print(SceneStatus[0])
		if SceneStatus[0] == 1:
			var Szene = ResourceLoader.load_threaded_get(Scene)
			get_tree().change_scene_to_packed(Szene)
			Load = false
	Load = true
	
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
