extends StaticBody2D

# class member variables go here, for example:
# var a = 2
# var b = "textvar"

func _ready():
	if controller.flag["dungeon2_complete"] == 1:
		$Sprite.play("closed")
		$Transition.queue_free()
		get_tree().get_root().get_node("Node2D").get_node("NPCGallaro").queue_free()

#func _process(delta):
#	# Called every frame. Delta is time since last frame.
#	# Update game logic here.
#	pass
