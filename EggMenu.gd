extends Control


signal egg_option_selected(option)
@onready var incubate_button: Button = $HBoxContainer/IncubateButton
@onready var eat_button: Button = $HBoxContainer/EatButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	incubate_button.connect("pressed",_on_incubate_pressed)
	eat_button.connect("pressed", _on_eat_pressed)


func _on_incubate_pressed():
	emit_signal("egg_option_selected", "Incubate")
	queue_free()
	
func _on_eat_pressed():
	emit_signal("egg_option_selected", "Eat")
	queue_free()
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
