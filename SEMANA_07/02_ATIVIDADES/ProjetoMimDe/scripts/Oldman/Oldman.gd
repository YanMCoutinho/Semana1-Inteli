extends KinematicBody2D

# Variaveis de estado
var velocity = 150
var last_v_movement_direction = 1
var last_h_movement_direction = 1
var v_direction = 0
var h_direction = 0

# Variaveis de controle de estado
var moving_v = true
var screaming = false
var howling = false
var dead = false
var giving_cumbuca = false

#Inicializa os sinais
signal died(value, oldman)
signal give_cumbuca(oldman)

#Inicializa o randomizador
var rng = RandomNumberGenerator.new()

onready var sprite = $AnimatedSprite
onready var audio_scream = $AudioScream
onready var audio_dead = $AudioDead

#Dicionarios usados para controlar melhor as animações
const is_a_walking_anim: Dictionary = {
	"side_walk": true,
	"up_walk": true,
	"down_walk": true,
	
	"side_scream": false,
	"up_scream": false,
	"down_scream": false,
	
	"side_dead": false,
	"up_dead": false,
	"down_dead": false,
	
	"give_cumbuca": false,
}

const scream_anims: Dictionary = {
	"side_walk": "side_scream",
	"up_walk": "up_scream",
	"down_walk": "down_scream",
	
	"side_dead": "side_scream",
	"up_dead": "up_scream",
	"down_dead": "down_scream",
	
	"give_cumbuca": "down_dead",
}

const dead_anims: Dictionary = {
	"side_walk": "side_dead",
	"up_walk": "up_dead",
	"down_walk": "down_dead",

	"side_scream": "side_dead",
	"up_scream": "up_dead",
	"down_scream": "down_dead",
	
	"give_cumbuca": "down_dead",
}

var anims: Dictionary = {
	"v_direction": {
		"-1": "up_walk",
		 "1": "down_walk",
	},
	"h_direction": {
		"-1": "side_walk",
		 "1": "side_walk",
	},
}

#Faz com que o randomizador seja único para cada instância
func _ready():
	rng.seed = hash(rand_seed(randi()))


func _physics_process(_delta):
	var movement = Vector2(h_direction, v_direction).normalized()
	
	#Faz ele acelerar ou desacelerar até a velocidade padrão
	if velocity > 100:
		velocity -= 1
	elif velocity < 100:
		velocity += 1
	
	#Se ele estiver morto, ele vai desaparecendo até seu node ser deletado
	if dead:
		if self.modulate.a > 0:
			if self.modulate.a < 0.75:
				self.modulate.a -= 0.01
			else: 
				self.modulate.a -= 0.001
		else:
			self.queue_free()

	#Se ele não está morto, gritando e não está rendido. Ele troca de animação
	if not screaming and not dead and not giving_cumbuca:
		change_anim()

	#Movimenta o personagem
	var __ = move_and_slide(movement * velocity)

#Função para fazer com que o animated sprite fique parado
func change_idle_anim(anim, frame):
	sprite.animation = anim
	sprite.playing = false
	sprite.frame = frame

#Muda a animação conforme a direção andada ou parada
func change_anim():			
	if v_direction != 0:
		sprite.animation = anims["v_direction"][str(last_v_movement_direction)]
		sprite.playing = true
	else:
		var flip_h = true if last_h_movement_direction == 1 else false
		
		if h_direction != 0:
			sprite.playing = true
			sprite.animation = anims["h_direction"]['1']
			sprite.flip_h = flip_h
		else:
			if v_direction == 0 and moving_v:
				change_idle_anim(anims["v_direction"][str(last_v_movement_direction)], 1)
			else:
				change_idle_anim(anims["h_direction"][str(last_h_movement_direction)], 1)

#Atualiza as ultimas direções andadas
func change_last_direction():
	if v_direction != 0:
		moving_v = true
		last_v_movement_direction = v_direction

	if h_direction != 0:
		moving_v = false
		last_h_movement_direction = h_direction	

#Mata o npc, fazendo ele enviar o sinal e parar de se mexer
func die(): 
	if not dead:
		emit_signal("died", -1, self)
		$Walk.stop()
		$Run.stop()
		$CumbucaTexture.hide()
		$ComputerKeyEnter.hide()
		dead = true
		audio_dead.play(19)
		h_direction = 0
		v_direction = 0
		change_idle_anim(dead_anims[sprite.animation], 0)

#Assusta o NPC, fazendo ele ocorrer para os lados opostos do que aquilo que a assustou
#Ele pode correr mais rápido ou mais devagar. Caso o lobo uive, ele correrá devagar
#Caso seja ele que tenha visto o lobo, ele correrá mais rápido
#Se ele correr mais devagar, roda a chance dele se render
func scare(thing_position, update_velocity): 
	if is_a_walking_anim[sprite.animation]:
		var anim = scream_anims[sprite.animation]
		var cumbuca_chances = int(rng.randi_range(0, 100))
		sprite.playing = true
		sprite.animation = anim
		
		if cumbuca_chances >= 97 and update_velocity < 0:
			_give_cumbuca()
		else:
			audio_scream.play(0.5)
			_run_away(thing_position, update_velocity)
			screaming = true

# Faz ele correr para o lado oposto de algo com uma variação de velocidade
func _run_away(thing_position, update_velocity):
	v_direction = int(clamp((self.position.y - thing_position.y), -1, 1))
	h_direction = int(clamp((self.position.x - thing_position.x), -1, 1))
	
	change_last_direction()
	
	self.velocity += update_velocity

	$Walk.stop()
	$Run.start()

# Faz ele se render e ficar parado
func _give_cumbuca(): 
	sprite.animation = "give_cumbuca"
	giving_cumbuca = true
	$Walk.stop()
	$Run.stop()
	$CumbucaTexture.show()
	$ComputerKeyEnter.show()
	h_direction = 0
	v_direction = 0
	emit_signal("give_cumbuca", self)

#Controlas as mudanças de estado conforme o fim das animações
func _on_AnimatedSprite_animation_finished():
	if not is_a_walking_anim[sprite.animation]:
		screaming = false

# Faz ele andar de tempos em tempos
func _on_Walk_timeout():
	h_direction = int(rng.randi_range(-1, 1))
	v_direction = int(rng.randi_range(-1, 1))
	
	change_last_direction()

# Faz ele parar de correr após o timer tocar
func _on_Run_timeout():
	screaming = false
	$Walk.start()

#Caso o Player entre na sua área 2D, ele irá correr do Player
func _on_DetectPlayer_body_entered(body):
	if body.is_in_group('player'):
		if not screaming:
			self.scare(body.position, +170)
