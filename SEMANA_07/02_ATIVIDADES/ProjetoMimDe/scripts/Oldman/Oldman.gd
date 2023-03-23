extends KinematicBody2D

var velocity = 150
var last_v_movement_direction = 1
var last_h_movement_direction = 1
var moving_v = true
var screaming = false
var howling = false
var dead = false
var giving_cumbuca = false
var v_direction = 0
var h_direction = 0

signal died(value, oldman)
signal give_cumbuca(oldman)

var rng = RandomNumberGenerator.new()

onready var sprite = $AnimatedSprite
onready var audio_scream = $AudioScream
onready var audio_dead = $AudioDead

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

func _ready():
	rng.seed = hash(rand_seed(randi()))


func _physics_process(_delta):
	var movement = Vector2(h_direction, v_direction).normalized()

	if velocity > 100:
		velocity -= 1
	elif velocity < 100:
		velocity += 1
	
	if dead:
		if self.modulate.a > 0:
			if self.modulate.a < 0.75:
				self.modulate.a -= 0.01
			else: 
				self.modulate.a -= 0.001
		else:
			self.queue_free()

	if not screaming and not dead and not giving_cumbuca:
		change_anim()

	var __ = move_and_slide(movement * velocity)


func change_idle_anim(anim, frame):
	sprite.animation = anim
	sprite.playing = false
	sprite.frame = frame


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


func change_last_direction():
	if v_direction != 0:
		moving_v = true
		last_v_movement_direction = v_direction

	if h_direction != 0:
		moving_v = false
		last_h_movement_direction = h_direction	


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


func scare(thing_position, update_velocity): 
	if is_a_walking_anim[sprite.animation]:
		var anim = scream_anims[sprite.animation]
		var cumbuca_chances = int(rng.randi_range(0, 100))
		sprite.playing = true
		sprite.animation = anim
		
		if cumbuca_chances >= 90:
			_give_cumbuca()
		else:
			audio_scream.play(0.5)
			_run_away(thing_position, update_velocity)
			screaming = true


func _run_away(thing_position, update_velocity):
	v_direction = int(clamp((self.position.y - thing_position.y), -1, 1))
	h_direction = int(clamp((self.position.x - thing_position.x), -1, 1))
	
	change_last_direction()
	
	self.velocity += update_velocity

	$Walk.stop()
	$Run.start()


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


func _on_AnimatedSprite_animation_finished():
	if not is_a_walking_anim[sprite.animation]:
		screaming = false


func _on_Walk_timeout():
	h_direction = int(rng.randi_range(-1, 1))
	v_direction = int(rng.randi_range(-1, 1))
	
	change_last_direction()


func _on_Run_timeout():
	screaming = false
	$Walk.start()


func _on_DetectPlayer_body_entered(body):
	if body.is_in_group('player'):
		if not screaming:
			self.scare(body.position, +170)
