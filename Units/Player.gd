extends Character

const INTERACTIONRANGE = 40
const COINSPEED = 400

const coins = preload("res://Mechanics/Coin.tscn")

func is_class(c): return c == "Player" or .is_class(c)

var toInteract = null
var hasMoney := false


func checkForInteractables():
	toInteract = null
	for i in get_tree().get_nodes_in_group("Interactable"):
		if (i.global_position - global_position).length() < INTERACTIONRANGE:
			toInteract = i
			break
	#update UI
	if toInteract == null:
		$Dialog.set_text("")
	elif toInteract.is_class("Lever"):
		$Dialog.set_text("E: Pull the Lever")
	elif toInteract.is_class("Money Bag"):
		$Dialog.set_text("E: Pick up")

func throwCoin(at):
	at = at.normalized() * COINSPEED
	var c = coins.instance()
	c.position = position
	c.velocity = at
	level.add_child(c)
	c.connect("CoinDropped", level, "_onCoinDropped")
	

# Called when the node enters the scene tree for the first time.
func _ready():
	drawVision = false
	remove_from_group("Enemies")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	checkForInteractables()
	

func _physics_process(delta):
	inputMovement(delta)
	var col = move_and_collide(velocity*delta)
func inputMovement(delta):
	var disp = Vector2(0,0)
	if Input.is_key_pressed(KEY_W):
		disp += Vector2(0,-1)
	if Input.is_key_pressed(KEY_S):
		disp += Vector2(0, 1)
	if Input.is_key_pressed(KEY_A):
		disp += Vector2(-1, 0)
	if Input.is_key_pressed(KEY_D):
		disp += Vector2(1, 0)
	if disp.length_squared() > 0:
		walk(disp.normalized() * WALKSPEED)
	else:
		velocity = disp

func _unhandled_key_input(event):
	if event.scancode == KEY_E and event.pressed:
		if toInteract == null:
			pass
		elif toInteract.is_class("Lever"):
			pass
		elif toInteract.is_class("Money Bag"):
			toInteract.set_visible(false)
			toInteract.queue_free()
			toInteract = null
			hasMoney = true
			$Spritesheet/Moneybag.set_visible(true)
	if event.scancode == KEY_Q and !event.pressed and hasMoney:
		throwCoin(get_local_mouse_position())

func _draw():
	if Input.is_key_pressed(KEY_Q) and hasMoney:
		var mp = get_local_mouse_position().clamped(80)
		draw_line(Vector2(), mp, Color.yellow,3)
		draw_line(mp, mp - mp.rotated(PI/4).clamped(10), Color.yellow,3)
		draw_line(mp, mp - mp.rotated(-PI/4).clamped(10), Color.yellow,3)
