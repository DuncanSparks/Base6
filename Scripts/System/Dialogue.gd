extends CanvasLayer

var box_x = 0
var box_y = 0
var box_width = 10
var box_height = 10
var ww = 5
var hh = 5

var stage = 0

var text = []
var text_page = 0
var length = 0
onready var page_length = len(text[0].replace(' ', ''))

var text_roll = false
var t = -1.0
var sound = -1.0

var target = null

var buffer = false

# Object node references
onready var dbox = $Box
onready var DText = $DText
onready var SoundType = $SoundType

func _ready():
	dbox.set_position(Vector2(box_x, box_y))
	DText.set_position(Vector2(box_x + 6, box_y + 6))
	DText.set_end(Vector2(box_x + box_width - 6, box_y + box_height - 6))
	$Sound1.play(0)

func _physics_process(delta):
	if stage == 0: # Expand H
		ww = clamp(ww + controller.convert_to_seconds((box_width / 20), delta),5,box_width)
		if ww >= box_width:
			$Sound2.play(0)
			stage = 1
	if stage == 1: # Expand V
		hh = clamp(hh + controller.convert_to_seconds((box_height / 20), delta),5,box_height)
		if hh >= box_height:
			$TimerStart.start()
			stage = 2
	if stage == 2 and text_roll: # Text rolling
		roll_text(delta)
	if stage == 3: # Contract V
		hh = clamp(hh - controller.convert_to_seconds((box_height / 18), delta),5,box_height)
		if hh <= 5:
			$Sound2.play(0)
			stage = 4
	if stage == 4: # Contract H
		ww = clamp(ww - controller.convert_to_seconds((box_width / 18), delta),5,box_width)
		if ww <= 5:
			on_destroy()
			queue_free()
	
	dbox.set_size(Vector2(ww, hh))
	DText.set_text(text[text_page]) # Get the current page of text we're on
	DText.set_visible_characters(length) # Set the visible text to however long it has progressed
	
func roll_text(delta):
	# Godot labels ignore spaces when counting visible characters
	# So we need to delete all the spaces when we calculate the length of a string.
	if length < page_length:
		t += controller.convert_to_seconds(1, delta)
		sound += controller.convert_to_seconds(1, delta)
		
		if sound > 6: # Type sound timer
			sound = 0
			SoundType.set_pitch_scale(rand_range(0.9,1.1))
			SoundType.play(0)
		
		if t > 3: # Text progress timer
			t = 0
			length += 1
		
		if Input.is_action_just_pressed("ui_accept") and not buffer: # Show all text
			advance_text()
	else:
		if Input.is_action_just_pressed("ui_accept") and not buffer: # Go to next page of text
			advance_page()
	
func advance_text():
	length = page_length
	buffer = true
	$TimerBuffer.start()
	
func advance_page():
	length = 0
	if text_page + 1 < len(text):
		text_page += 1
		page_length = len(text[text_page].replace(' ', ''))
	else:
		$Sound1.play(0)
		stage = 3
		
func on_destroy():
	length = 0
	if target.is_in_group("NPC"):
		target.get_node("Sprite").set_animation("down")
		if target.dialogue_key != "null" and target.auto_advance_set:
		 	controller.flag[target.dialogue_key] = clamp(controller.flag[target.dialogue_key] + 1,0,target.auto_advance_limit)
	Player.state = Player.WALK
	
	# CAW!!
	if target.get_name() == "NPCFountainPlaque":
		audioplayer.get_node("SoundCrow").play(0)
		var fountainparts = get_tree().get_root().get_node("Node2D").get_node("Fountain").get_node("PartsCaw")
		fountainparts.set_emitting(true)
		
	# Items after boss 1
	if target.get_name() == "BossCore":
		Player.get_node("SoundPotion").play(0)
		Player.get_node("PartsPotion").set_emitting(true)
		controller.player_health = 10
		get_tree().get_root().get_node("Node2D").get_node("ItemKeystonePiece2").enable = true
		get_tree().get_root().get_node("Node2D").get_node("ItemBow").enable = true
		
	# Start/After boss 2
	if target.get_name() == "SesdinIntro":
		if target.after:
			get_tree().get_root().get_node("Node2D").get_node("SesdinIntro").get_node("TimerEndBoss").start()
		else:
			get_tree().get_root().get_node("Node2D").get_node("SesdinIntro").get_node("TimerTeleport").start()

func _on_TimerStart_timeout():
	text_roll = true

func _on_TimerBuffer_timeout():
	buffer = false
