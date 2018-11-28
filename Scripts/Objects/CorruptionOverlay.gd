extends CanvasLayer

export(bool) var corrupt = true
export(float) var corrupt_interval = 5

onready var player = Player
onready var cont = controller

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	if not get_tree().get_root().get_node("Node2D").get_node("CellLabel").text in controller.corrupted_cells:
		queue_free()
	
	$TimerCorrupt.stop()
	$TimerCorrupt.set_wait_time(corrupt_interval)
	$TimerCorrupt.start()

func _on_TimerCorrupt_timeout():
	if corrupt and player.state != player.NO_INPUT and player.state != player.DIALOGUE:
		cont.player_corrupt(1)