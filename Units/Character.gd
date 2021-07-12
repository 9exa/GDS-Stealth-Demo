extends KinematicBody2D

class_name Character

func is_class(c): return c == "Character" or .is_class(c)

onready var level = get_tree().current_scene

export var selected = false

var maxHealth = 5
var health = maxHealth
var isDead := false
signal justDied
signal justHit(vector) #when a character gets hit by a bullet

const WALKSPEED = 96

const SIGHTRANGE = 150
const SIGHTANGLE = PI/4 #how wide the character can see
#direction character is facing
export var facing := Vector2(0, 1)
var velocity := Vector2()
var basefacing : Vector2 # for looking around


signal noticedCoin(at)

#combat stuff
const bullets = preload("res://Mechanics/bullet.tscn")
const MAXSHOTCD = 0.2
const BULLETSPEED = 32*16
var shotCD = MAXSHOTCD
var drawVision = true

#for exclaimation marks
enum {NONE, QUESTION, ECLAIMATION}
func showExclaim(n):
	$Exclaims.frame = n
func setDialog(s):
	$Dialog.text = str(s)

func _onCoinDropped(at):
	if (at - position).length() < SIGHTRANGE:
		emit_signal("noticedCoin", at)

#pathfinding
var path: PoolVector2Array
var pathLines = Line2D.new()
const RANDPATHRANGE = 100

func hasPath():
	return !path.empty()
func requestPath(arg = "Random"):
	var nav = level.get_node("Navigation2D")
	var p
	match typeof(arg):
		TYPE_STRING:
			p = position + RANDPATHRANGE * polar2cartesian(randf(),2*PI*randf())
			p = nav.get_simple_path(position, p)
		TYPE_VECTOR2:
			p = nav.get_simple_path(position, arg)
	path = p
	pathLines.points = p

func moveAlongPath(delta):
	var toWalk = WALKSPEED * delta
	var endpoint = position
	var segLength = 0
	while toWalk > 0:
		if path.empty():
			break
		segLength = (path[0]-endpoint).length()
		if  segLength > toWalk:
			endpoint = endpoint + (path[0]-endpoint).normalized() * toWalk
			#move_and_collide(endpoint - position)
		else:
			endpoint = path[0]
			path.remove(0)
		toWalk -= segLength
	
	var p = path
	p.insert(0,position)
	pathLines.points = p
	if endpoint != position:
		var diff = endpoint - position
		move_and_collide(diff)
		walk(diff)
		facing = (diff)

#how alarming
func alarmInRange():
	var levers = level.get_node("Levers").get_children()
	for l in levers:
		var diff = l.global_position - global_position
		if diff.length() < SIGHTRANGE:
			return l
func activateAlarm():
	level.alarm = true
func deactivateAlarm():
	level.alarm = false

static func isBetween(a, lo, hi):
	return lo < a and a < hi

func shoot():
	if shotCD <= 0:
		var b = bullets.instance()
		level.add_child(b)
		b.velocity = facing.normalized() * BULLETSPEED
		b.global_position = global_position
		shotCD = MAXSHOTCD

func dieAnimation():
	$AnimationPlayer.stop()
	$Spritesheet.frame = 12


func canSeePlayer():
	var player = level.player
	if player != null:
		var diff = player.global_position - global_position
		$LOS.cast_to = diff
		$LOS.force_raycast_update()
		if (diff.length() < SIGHTRANGE and $LOS.get_collider() == player
			and isBetween(diff.angle() - facing.angle(), 
						-SIGHTANGLE, SIGHTANGLE)):
			return true
	return false
func playerInRange():
	return (global_position - level.player.global_position).length() <= SIGHTRANGE
func getAllSeeableEnemies():
	var out = []
	var player = level.player
	for character in get_tree().get_nodes_in_group("Enemies"):
		var diff = character.global_position - global_position
		$LOS.cast_to = diff
		$LOS.force_raycast_update()
		if ($LOS.get_collider() == character and character != player
				and diff.length() < SIGHTRANGE 
				and isBetween(diff.angle - facing.angle(), 
						-SIGHTANGLE, SIGHTANGLE)):
			out.append[character]
	return out

func canSeeDeadEnemy():
	for e in getAllSeeableEnemies():
		if "isDead" in e and e.isDead:
			return true


func facePlayer():
	if level.player != null:
		facing = level.player.global_position - global_position

func walk(vec):
	$Spritesheet.flip_h = true if vec.x < 0 else false
	var a = vec.angle()
	if -0.75*PI < a and a < -0.25 * PI:
		$AnimationPlayer.current_animation = "Walk Up"
	elif 0.25*PI < a and a < 0.75 * PI:
		$AnimationPlayer.current_animation = "Walk Down"
	else:
		$AnimationPlayer.current_animation = "Walk Right"
func idleAnimation(vec):
	if vec == Vector2(): return
	$AnimationPlayer.stop()
	var a = vec.angle()
	$Spritesheet.flip_h = true if vec.x < 0 else false
	if -0.75*PI < a and a < -0.25 * PI:
		$Spritesheet.frame = 8
	elif 0.25*PI < a and a < 0.75 * PI:
		$Spritesheet.frame = 0
	else:
		$Spritesheet.frame = 4
# Called when the node enters the scene tree for the first time.
func _ready():
	pathLines.points = path
	pathLines.default_color = Color.orange
	pathLines.width = 2
	level.call_deferred("add_child", pathLines)
	level.connect("CoinDropped", self, "_onCoinDropped")
	add_to_group("Enemies")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	update()
	shotCD -= delta
	pass

func _physicsFrame(delta):#damn you godot!
	velocity = Vector2()
	if Input.is_key_pressed(KEY_RIGHT) and selected:
		moveAlongPath(delta)
	var col = move_and_collide(velocity*delta)
func _physics_process(delta):
	_physicsFrame(delta)
func _draw():
	var a = facing.angle()
	if drawVision:
		draw_arc(Vector2(), SIGHTRANGE/2, a-SIGHTANGLE/2, a+SIGHTANGLE/2,
			10, Color(0.5,0.1,0.1,0.2), SIGHTRANGE)
	#draw_circle(Vector2(), SIGHTRANGE, Color.rebeccapurple)
func _unhandled_key_input(event):
	if level.debugmode and event.scancode == KEY_K and event.pressed:
		print(canSeePlayer())
	if level.debugmode and event.scancode == KEY_L and event.pressed:
		print(getAllSeeableEnemies())
	

func _unhandled_input(event):
	
	if event is InputEventMouseButton:
		if level.debugmode and selected:
			if event.button_index == BUTTON_LEFT and event.pressed:
				requestPath(get_global_mouse_position())
