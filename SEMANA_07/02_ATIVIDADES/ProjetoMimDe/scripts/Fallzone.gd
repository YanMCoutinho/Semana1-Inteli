extends Area2D


func _ready():
	pass


func _on_Fallzone_body_entered(body):
	get_tree().reload_current_scene()
