extends Character


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

func playerAttacked(p):
	if p.is_class("Player"):
		p.health = 0
		p.emit_signal("justHit", velocity)

# Called when the node enters the scene tree for the first time.
func _ready():
	$DamageBox.connect("body_entered", self, "playerAttacked")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func _unhandled_key_input(event):
	if event.scancode == KEY_0:
		shoot()
