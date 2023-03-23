extends Node2D

var qtd_enemies = 0

func _ready():
	for child in self.get_children():
		if child.is_in_group("enemy"):
			child.connect("died", self, "_count_enemies")
			_count_enemies(+1)
			
func _count_enemies(change):
	qtd_enemies += change
	$HUD/qtdContainer/qtdEnemiesLabel.bbcode_text = "INIMIGOS RESTANTES [color=#E51911]" + str(qtd_enemies) + "[/color]"
	if qtd_enemies < 1:
		get_tree().change_scene("res://scenes/End.tscn")
