extends Panel

@onready var button: Button = $Button

@onready var soundCheckButton: CheckButton = $"../CheckButton"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	soundCheckButton.pressed.connect(toggleSound)
	SignalManager.win_game.connect(onWinScreen)
	button.pressed.connect(onReplay)

func onReplay():
	SignalManager.restart_game.emit()

func onWinScreen():
	self.visible = true

var is_muted = false

func toggleSound():
	is_muted = !is_muted
	var bus_idx = AudioServer.get_bus_index("Master")
	AudioServer.set_bus_mute(bus_idx, is_muted)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
