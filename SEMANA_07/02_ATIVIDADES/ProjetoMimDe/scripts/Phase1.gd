extends Node2D

var qtd_enemies = 0
var gived_cumbuca = false
var oldman_gived_cumbuca = []

onready var player = $Player

func _ready():
	for child in self.get_children():
		if child.is_in_group("enemy"):
			child.connect("died", self, "_count_enemies")
			child.connect("give_cumbuca", self, "_get_cumbuca")
			_count_enemies(+1, child)


func _process(_delta):
	if gived_cumbuca and Input.is_action_pressed("ui_accept"):
		for oldman in oldman_gived_cumbuca:
			var old_pos = oldman.position
			var player_pos = player.position
			var distance = 50
			if (old_pos.x + distance) > player_pos.x and (old_pos.x - distance) < player_pos.x:
				if (old_pos.y + distance) > player_pos.y and (old_pos.y - distance) < player_pos.y:
					get_tree().change_scene("res://scenes/GoodEnd.tscn")


func _count_enemies(value, oldman):
	qtd_enemies += value
	$HUD/qtdContainer/qtdEnemiesLabel.bbcode_text = "INIMIGOS RESTANTES [color=#E51911]" + str(qtd_enemies) + "[/color]"
	if qtd_enemies < 1:
		get_tree().change_scene("res://scenes/BadEnd.tscn")
		
	if value < 0:
		var search_oldman =oldman_gived_cumbuca.find(oldman)
		if search_oldman:
			oldman_gived_cumbuca.remove(search_oldman)


func _get_cumbuca(oldman):
	gived_cumbuca = true
	oldman_gived_cumbuca.append(oldman)
