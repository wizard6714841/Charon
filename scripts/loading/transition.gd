extends CanvasLayer

signal trans_finished

@export var animation_player : AnimationPlayer
@export var progress_bar : ProgressBar

func _ready() -> void:
	await animation_player.animation_finished
	trans_finished.emit()

func on_load_finished() -> void:
	animation_player.play_backwards("transition")

func on_progress_changed( progress : float ) -> void:
	$Panel/ProgressBar.value = progress * 100
	pass
