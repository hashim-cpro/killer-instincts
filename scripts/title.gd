extends Control

@onready var splashScreen = $TextureRect
@onready var titleScreen = $TitleScreen
@onready var optionsScreen = $OptionsScreen
@onready var creditsScreen = $CreditsScreen

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	splashScreen.visible = true
	titleScreen.visible = false
	$AnimationPlayer.play("terigames splash fade in")
	await get_tree().create_timer(5).timeout
	$AnimationPlayer.play("terigames splash fade out")
	await get_tree().create_timer(3).timeout
	splashScreen.visible = false
	titleScreen.visible = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta: float) -> void:
	#pass

func _on_play_button_pressed() -> void:
	get_tree().change_scene_to_file("res://scenes/game.tscn")

func _on_options_button_pressed() -> void:
	optionsScreen.visible = true
	titleScreen.visible = false
	creditsScreen.visible = false

func _on_credits_button_pressed() -> void:
	optionsScreen.visible = false
	titleScreen.visible = false
	creditsScreen.visible = false
