extends Sprite


signal becameActive
var emmited = false
var beingActivated = 0
var activationProgress = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if bool(beingActivated):
		activationProgress += 0.5 * delta
		activationProgress = min(1, activationProgress)
		
	else:
		activationProgress -= 0.25 * delta
		activationProgress = max(0, activationProgress)
	update()
	if activationProgress == 1 and not emmited:
		emmited = true
		emit_signal("becameActive")
		
func _draw():
	if activationProgress > 0:
		var start = Vector2(-25, -15)
		var end = Vector2(25, -15)
		draw_line(start, lerp(start, end, activationProgress), Color.bisque, 2)
		draw_line(lerp(start, end, activationProgress), end, Color.darkgray, 2)
