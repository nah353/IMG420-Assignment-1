extends CanvasLayer

# Notifies `Main` node that the button has been pressed
signal start_game
signal upgrade_selected(choice: int)

@export var health_ui_scene: PackedScene
@onready var health_container: BoxContainer = $Lives
@onready var xp_bar: ProgressBar = $ExperienceBar
@onready var xp_level: Label = $ExperienceLabel

@onready var upgrade_menu = $UpgradeMenu
@onready var button1 = $UpgradeMenu/UpgradeButton1
@onready var button2 = $UpgradeMenu/UpgradeButton2
@onready var button3 = $UpgradeMenu/UpgradeButton3

var current_lives := 0

func _ready():
	# Hide the upgrade menu initially
	upgrade_menu.visible = false

	# Connect buttons to emit the upgrade_selected signal
	button1.pressed.connect(func(): _on_upgrade_pressed(1))
	button2.pressed.connect(func(): _on_upgrade_pressed(2))
	button3.pressed.connect(func(): _on_upgrade_pressed(3))
	
func show_upgrade_menu():
	upgrade_menu.visible = true
	get_tree().paused = true
	
func _on_upgrade_pressed(choice: int):
	# Hide menu and unpause
	upgrade_menu.visible = false
	get_tree().paused = false
	upgrade_selected.emit(choice)

func show_message(text):
	$Message.text = text
	$Message.show()
	$MessageTimer.start()
	
func show_game_over():
	show_message("Game Over")
	# Wait until the MessageTimer has counted down.
	await $MessageTimer.timeout

	$Message.show()
	# Make a one-shot timer and wait for it to finish.
	await get_tree().create_timer(0.5).timeout
	$StartButton.text = "Restart"
	$StartButton.show()
	
func update_timer(total_seconds: int) -> void:
	var minutes: int = total_seconds / 60
	var seconds: int = total_seconds % 60
	$TimerLabel.text = "%d:%02d" % [minutes, seconds]
	
func _on_start_button_pressed():
	$StartButton.hide()
	start_game.emit()

func _on_message_timer_timeout():
	$Message.hide()
	
func update_health(lives: int) -> void:
	for child in health_container.get_children():
		child.queue_free()
	
	for i in range(lives):
		var life_icon = health_ui_scene.instantiate()
		health_container.add_child(life_icon)
		
	current_lives = lives

func update_score(xp: int) -> void:
	$ScoreLabel.text = str(xp)
	
func init_experience(initial_level: int, max_xp: int) -> void:
	xp_bar.min_value = 0
	xp_bar.max_value = max_xp
	xp_bar.value = 0
	xp_level.text = "%d" % initial_level
	
func update_experience(xp: int, level: int, max_xp: int) -> void:
	xp_level.text = "%d" % level
	xp_bar.max_value = max_xp
	xp = clamp(xp, 0, int(xp_bar.max_value))
	get_tree().create_tween().tween_property(xp_bar, "value", xp, 0.25)
