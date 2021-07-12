extends Node2D


var score = 0
var alarm = false setget setAlarm
var atime = 0.0


onready var player = $Player
onready var selectedUnit = player
var debugmode := false
const enforcerScene = preload("res://Units/Enforcer.tscn")

signal CoinDropped(at)

func _onCoinDropped(at):
	emit_signal("CoinDropped", at)

func setAlarm(a):
	if !alarm and a:
		spawnEnforcers()
	alarm = a

func spawnEnforcers():
	var e
	for n in $Doors.get_children():
		e = enforcerScene.instance()
		e.position = n.position + Vector2(0, 30)
		add_child(e)

func playerHealthChanged(_none):
	var prop = float(player.health) / player.maxHealth
	$"UI/Health Bar".material.set_shader_param("prop", prop)

func playerAtExit(p):
	if "hasMoney" in p and p.hasMoney:
		winScreen()

func winScreen():
	$UI/PauseScreen.set_visible(true)
	$UI/PauseScreen/winlose.set_visible(true)
	$UI/PauseScreen/winlose.frame = 1
	$UI/PauseScreen/PauseText.set_text("You actually did it?! \n No more pizzas for GDS")
func loseScreen():
	yield(get_tree().create_timer(3), "timeout")
	$UI/PauseScreen.set_visible(true)
	$UI/PauseScreen/winlose.set_visible(true)
	$UI/PauseScreen/PauseText.set_text("Ya LOST! \n Like the LOSER you are!")
func updateUI():
	
	$UI/Score.set_text(str(score))

func processAlarm(delta):
	atime += delta
	$"UI/Alarm Rect".color = Color(0.8+0.2*sin(atime), 0.3+0.3*sin(2.4*atime+3),
			 0, 0.3*sin(0.5*atime*PI))
# Called when the node enters the scene tree for the first time.
func _ready():
	#debugmode = true
	$ExitZone.connect("body_entered", self, "playerAtExit")
	player.connect("justDied", self, "loseScreen")
	player.connect("justHit", self, "playerHealthChanged")
	playerHealthChanged(null)
	updateUI()
	pass # Replace with function body.
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if alarm:
		processAlarm(delta)
	updateUI()
func _unhandled_key_input(event):
	if event.scancode == KEY_ENTER:
		setAlarm(true)
	if event.scancode == KEY_QUOTELEFT:
		debugmode = true
	if event.scancode == KEY_ESCAPE:
		get_tree().call_deferred("reload_current_scene")
	if event.scancode == KEY_P:
		get_tree().paused = !get_tree().paused
#func _unhandled_input(event):
#	if event is InputEventMouseButton and debugmode:
#		if event.button_index == BUTTON_LEFT and event.pressed:
#			var path = $Navigation2D.get_simple_path(player.global_position,
#					get_global_mouse_position())
#			$Line2D.points = path
#			dot = get_global_mouse_position()
#			update()
#var dot =null
#func _draw():
#
#	if dot != null:
#		print(dot)
#		draw_circle(dot,1, Color.red)
func _to_string():
	return "the Level"
