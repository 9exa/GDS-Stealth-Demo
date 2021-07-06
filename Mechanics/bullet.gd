extends KinematicBody2D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var velocity := Vector2()

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass
func  _physics_process(delta):
	var col = move_and_collide(velocity * delta)
	if col != null:
		var c = col.collider
		if c.is_class("Player"):
			c.health -= 1
			c.emit_signal("justHit", velocity)
		queue_free()
	rotation += delta * PI * 6
