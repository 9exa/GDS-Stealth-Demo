extends KinematicBody2D


const GRAVITY = 98
const THROWSPEED = 300

var velocity := Vector2()
var height = 12
var vertVel = 25
var t = 0
var anstage = 0

signal CoinDropped(at)

# Called when the node enters the scene tree for the first time.
func _ready():
	if velocity != Vector2():
		velocity = velocity.normalized() * THROWSPEED


func _physics_process(delta):
	t += delta
	if height < 0:
		height = 0
		emit_signal("CoinDropped", global_position)
	elif height> 0:
		var col = move_and_collide(velocity*delta)
		if col != null:
			velocity = velocity.bounce(col.normal)
			
		#handle falling
		vertVel -= GRAVITY * delta
		height += vertVel * delta
		#Animation
		if fmod(t, 0.2):
			t = 0
			anstage += 1
			$Sprites.frame = [0, 1, 2, 3, 2, 1][anstage % 6]
			
	$Sprites.position.y = -height
	
	if t > 5:
		queue_free()
	
