extends Area2D

func _ready():
	pass

func _on_Timer_timeout():
	if self.modulate.a < 0:
		self.queue_free()
	self.modulate.a -= 0.1
	if $Light2D.color.a > 0:
		$Light2D.color.a -= 0.11
	else:
		$Light2D.color.a = 0.01


func _on_Attack_body_entered(body):
	if body.is_in_group('enemy'):
		body.die()
