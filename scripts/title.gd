extends Control

@onready var splashScreen = $SplashScreen as TextureRect
@onready var titleScreen = $TitleScreen as VBoxContainer
@onready var optionsScreen = $OptionsScreen as VBoxContainer
@onready var creditsScreen = $CreditsScreen as VBoxContainer

const splashes = ["res://assets/images/Teri Games.png"]

func playSplashScreen(splash: String) -> void:
	splashScreen.texture = load(splash)
	$AnimationPlayer.play("splash fade in")
	await get_tree().create_timer(5).timeout
	$AnimationPlayer.play("splash fade out")
	await get_tree().create_timer(2).timeout

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	optionsScreen.visible = false
	creditsScreen.visible = false
	splashScreen.visible = true
	titleScreen.visible = false
	for splash in splashes:
		print("Loading splash ", splash)
		await playSplashScreen(splash)
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

func _on_back_button_from_options_pressed() -> void:
	optionsScreen.visible = false
	titleScreen.visible = true
	creditsScreen.visible = false

func _on_back_button_from_credits_pressed() -> void:
	optionsScreen.visible = false
	titleScreen.visible = true
	creditsScreen.visible = false
