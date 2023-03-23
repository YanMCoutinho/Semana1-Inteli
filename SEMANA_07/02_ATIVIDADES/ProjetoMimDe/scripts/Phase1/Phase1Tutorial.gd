extends Node2D

#QUando apertar o botão, vai para a fase 01
func _on_Button_pressed():
	get_tree().change_scene("res://scenes/Phase1/Phase1.tscn")
