extends KinematicBody2D

# Variáveis de Estado
var velocity = 200
var last_v_movement_direction = 1
var last_h_movement_direction = 1
var v_direction = 0
var h_direction = 0

#Variaveis de controle de estado
var moving_v = true
var attacking = false
var howling = false

#Carrega o ataque que será instanciado
var attack_preload = load("res://scenes/Player/Attack.tscn")

#Guarda os inimigos que estõo dentro da área do uivo
var enemies = []

onready var sprite = $AnimatedSprite

#Dicionários para trabalhar com a mudança de estado mais facilmente
#A ideia é saber qual animação cada ação tem dependendo da posição dela
#E E verificar se x animação é x ação
const is_a_walking_anim: Dictionary = {
	"side_attack": false,
	"up_attack": false,
	"down_attack": false,

	"side_walk": true,
	"up_walk": true,
	"down_walk": true,
	
	"side_howl": false,
	"up_howl": false,
	"down_howl": false,
}

const is_a_howling_anim: Dictionary = {
	"side_attack": false,
	"up_attack": false,
	"down_attack": false,

	"side_walk": false,
	"up_walk": false,
	"down_walk": false,
	
	"side_howl": true,
	"up_howl": true,
	"down_howl": true,
}

const howl_anims: Dictionary = {
	"side_walk": "side_howl",
	"up_walk": "up_howl",
	"down_walk": "down_howl",	
}

const is_an_attack_anim: Dictionary = {
	"side_attack": true,
	"up_attack": true,
	"down_attack": true,

	"side_walk": false,
	"up_walk": false,
	"down_walk": false,
	
	"side_howl": false,
	"up_howl": false,
	"down_howl": false,
}

const attack_position: Dictionary = {
	"side_walk": {
		-1: {
			"position": Vector2(-1, 0),
			"anim": "side_attack",
			"rotation": -90,
		},
		 1: {
			"position": Vector2(1, 0),
			"anim": "side_attack",
			"rotation": 90,
		},
	},
	"up_walk": {
		-1: {
			"position": Vector2(0, -1),
			"anim": "up_attack",
			"rotation": 0,
		},
		1: {
			"position": Vector2(0, -1),
			"anim": "up_attack",
			"rotation": 0,
		}, 
	},
	"down_walk": {
		-1: {
			"position": Vector2(0, 1),
			"anim": "down_attack",
			"rotation": -180,
		},
		1: {
			"position": Vector2(0, 1),
			"anim": "down_attack",
			"rotation": -180,
		},
	},
}

const anims: Dictionary = {
	"v_direction": {
		-1: "up_walk",
		1: "down_walk",
	},
	"h_direction": {
		-1: "side_walk",
		 1: "side_walk",
	},
}

#Computa os inputs para fazer a movimentação
func _input(_event):
	var down_press = int(Input.is_action_pressed("ui_down"))
	var up_press = int(Input.is_action_pressed("ui_up"))
	var right_press = int(Input.is_action_pressed("ui_right"))
	var left_press = int(Input.is_action_pressed("ui_left"))
	
	v_direction = down_press - up_press
	h_direction = right_press - left_press
	
	if v_direction != 0:
		moving_v = true
		last_v_movement_direction = v_direction

	if h_direction != 0:
		moving_v = false
		last_h_movement_direction = h_direction	

#Faz a movimentação do personagem e permite que ele ataque ou uive caso já não esteja fazendo isso
func _physics_process(_delta):
	var movement = Vector2(h_direction, v_direction).normalized()

	if not attacking and not howling:
		if Input.is_action_pressed("attack"):
			attack()
		elif Input.is_action_pressed("howl"):
			howl()
		else:
			change_anim()

	movement.normalized()
	var __ = move_and_slide(movement * velocity)

#Pega um frame do AnimatedSprite e pausa nele para fazer um sprite parado
func change_idle_anim(anim, frame):
	sprite.animation = anim
	sprite.playing = false
	sprite.frame = frame

#Muda de animação dependendo da direção que está sendo andada
func change_anim():			
	if v_direction != 0:
		sprite.animation = anims["v_direction"][last_v_movement_direction]
		sprite.playing = true
	else:
		var flip_h = true if last_h_movement_direction == 1 else false
		
		if h_direction != 0:
			sprite.playing = true
			sprite.animation = anims["h_direction"][1]
			sprite.flip_h = flip_h
		else:
			if Input.get_action_strength("move_v") == 0 and moving_v:
				change_idle_anim(anims["v_direction"][last_v_movement_direction], 1)
			elif Input.get_action_strength("move_h") == 0:
				change_idle_anim(anims["h_direction"][last_h_movement_direction], 1)

# Instancia a cena de ataque na direção em que o lobo está olhando e roda a animação de ataque
func attack():
	if is_a_walking_anim[sprite.animation]:
		var new_pos = 0
		var new_rotation = 0
		var anim = attack_position[sprite.animation][last_v_movement_direction]["anim"]
		var attack_scene = attack_preload.instance()
		var size = ($CollisionShape2D.shape.extents / 2)
		size.x += 25
		size.y += 25

		if moving_v:
			new_pos = attack_position[sprite.animation][last_v_movement_direction]["position"]
			new_rotation = attack_position[sprite.animation][last_v_movement_direction]["rotation"]
		else:
			new_pos  = attack_position[sprite.animation][last_h_movement_direction]["position"]
			new_rotation = attack_position[sprite.animation][last_h_movement_direction]["rotation"]
		
		attack_scene.position += new_pos * size
		attack_scene.rotation_degrees = new_rotation
		
		attacking = true
		
		sprite.playing = true
		sprite.animation = anim
		
		self.delay_add_child(attack_scene, 0.37)

#Faz com que o lobo uive e dê lentidão aos inimigos assustados
func howl(): 
	sprite.playing = true
	if is_a_walking_anim[sprite.animation]:
		var anim = howl_anims[sprite.animation]
		sprite.animation = anim
		howling = true
		$AudioHowl.play(0.7)
		for enemy in enemies:
			enemy.scare(self.position, -99)

#Adiciona um node filho com um tempo de delay dado
func delay_add_child(child, time):
	yield(get_tree().create_timer(time), "timeout")
	self.add_child(child)

#Controla os estados de acordo com os fins das animações
func _on_AnimatedSprite_animation_finished():
	if is_an_attack_anim[sprite.animation]:
		attacking = false
	if is_a_howling_anim[sprite.animation]:
		howling = false

#Caso um inimigo entre na área 2D, é adicionado a lista de inimigo
func _on_Area2D_body_entered(body):
	if body.is_in_group('enemy'):
		enemies.append(body)

#Caso um inimigo saia da área 2D, é removido da lista de inimigo
func _on_Area2D_body_exited(body):
	if body.is_in_group('enemy'):if body.is_in_group('enemy'):
		enemies.remove(enemies.find(body))
