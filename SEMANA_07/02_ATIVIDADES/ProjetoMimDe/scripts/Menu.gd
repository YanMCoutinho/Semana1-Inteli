extends Control

#Aperta o botão para ir para a cena de história da fase 1
func _on_PlayButton_pressed():
	get_tree().change_scene("res://scenes/Phase1/Phase1Story.tscn")
