extends Node2D

#Carrega os áudios da narração da história
var phrase1_audio = preload("res://assets/Sounds/History/Scene1.wav")
var phrase2_audio = preload("res://assets/Sounds/History/Scene2.wav")
var phrase3_audio = preload("res://assets/Sounds/History/Scene3.wav")

onready var history = $History

# Seta todas as falas, audios e animações que devem aparecer
onready var phrases: Array = [
	{
		"phrases": "[color=#B1C8F1]Toda noite ele passa na praça pedindo farinha na cumbuca\nPede pede pede que só a p@@@@. enche o saco esse bicho pidão... \n\nEis aqui o relato[/color]",
		"scene": $Scene1,
		"audio": phrase1_audio,
	},
	{
		"phrases": "- [color=#FF0D41]Mim dê![/color]\n- [color=#C1D4F3]Sai pra lá pidão![/color]",
		"scene": $Scene2,
		"audio": phrase2_audio,
	},
	{
		"phrases": "- [color=#FF0D41]Peço as coisas o tempo todo, mas só me dão[/color]\n\n - [color=#FF0100]DECEPÇÃO[/color]",
		"scene": $Scene3,
		"audio": phrase3_audio,
	},
]
#Contador para controlar em qual fala está
var count = 0

func _ready():
	_change_text()

#Substitui a fala conforme o número do contador. Se o contador for maior ou igual a quantidade de falas
# Passa para a próxima cena (Tutorial)
func _change_text():
	if count < len(phrases):
		$History.bbcode_text = phrases[count]["phrases"]
		$Scene1.hide()
		$Scene2.hide()
		$Scene3.hide()
		$AudioHistory.playing = false
		$AudioHistory.stream = phrases[count]["audio"]
		$AudioHistory.playing = true
		phrases[count]["scene"].show()
	else:
		get_tree().change_scene("res://scenes/Phase1/Phase1Tutorial.tscn")

#Quando o áudio acaba, passa para a próxima fala
func _on_AudioHistory_finished():
	count += 1
	_change_text()

#Vai para o tutorial
func _on_skipButton_pressed():
	get_tree().change_scene("res://scenes/Phase1/Phase1Tutorial.tscn")
