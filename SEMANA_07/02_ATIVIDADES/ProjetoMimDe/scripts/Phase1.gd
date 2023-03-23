extends Node2D

#Variáveis de controle da fase
var qtd_enemies = 0
var oldman_gived_cumbuca = []

onready var player = $Player

#Conta a quantidade de inimigos e conecta os sinais que eles emitem na fase 1
func _ready():
	for child in self.get_children():
		if child.is_in_group("enemy"):
			child.connect("died", self, "_count_enemies")
			child.connect("give_cumbuca", self, "_get_cumbuca")
			_count_enemies(+1, child)

# Verifica se algum inimigo está se rendendo e o botão de interação está pressionado. 
# Caso esteja, é verificado se o player está perto
# Caso esteja perto, é verificado se o player matou alguém ou não
# Se o player matou, ele vai para o final ruim
func _process(_delta):
	if len(oldman_gived_cumbuca) > 0 and Input.is_action_pressed("ui_accept"):
		for oldman in oldman_gived_cumbuca:
			var old_pos = oldman.position
			var player_pos = player.position
			var distance = 50
			if (old_pos.x + distance) > player_pos.x and (old_pos.x - distance) < player_pos.x:
				if (old_pos.y + distance) > player_pos.y and (old_pos.y - distance) < player_pos.y:
					if qtd_enemies >= 22:
						get_tree().change_scene("res://scenes/GoodEnd.tscn")
					else:
						get_tree().change_scene("res://scenes/BadEnd.tscn")

# Atualiza a quantidade de inimigos restantes e retira os inimigos rendidos que foram mortos
func _count_enemies(value, oldman):
	qtd_enemies += value
	$HUD/qtdContainer/qtdEnemiesLabel.bbcode_text = "INIMIGOS RESTANTES [color=#E51911]" + str(qtd_enemies) + "[/color]"
	if qtd_enemies < 1:
		get_tree().change_scene("res://scenes/BadEnd.tscn")
		
	if value < 0:
		var search_oldman =oldman_gived_cumbuca.find(oldman)
		if search_oldman:
			oldman_gived_cumbuca.remove(search_oldman)

# Adiciona o inimigo na lista de inimigos rendidos
func _get_cumbuca(oldman):
	oldman_gived_cumbuca.append(oldman)
