extends Node2D

# Essa variável foi declarada, pois é chamada ao longo do código
var nome = ""
var teste = false
var valor = 0
# Foi retirado o acento na declaração e chamada dessa variável
# para que funcionasse
var numero = 0 
# Foi adicionado var para inicializar a variável
var lista = [] 

func _on_Button_pressed():
	#Coletando dados inseridos pelo usuário
	#Foi adicionado o cifrão monetário ao LineEdit para que seja chamada
	#A instância do objeto
	numero = int($LineEdit.text)
	$LineEdit.text = nome


func _on_Button2_pressed():
	#Incrementando o número inserido pelo usuário
	for i in range(10):
		#Foi retirado a letra maiúscula na inicial para chamar a var correta
		numero += i
		lista.append(numero)
	$Label.text = str(numero)


func _on_Button3_pressed():
	#Mudando o nome do usuário de acordo com os dados da lista
	#Se houver algum número ímpar o nome deve adicionar "baldo" ao final

	#Foi tirada de dentro do while porque era sempre recriada com valor 0
	var cont = 0 
	#Foi tirada de dentro do while porque era sempre recriada com valor 0
	var i = 0 

	# Foi adicionado o < i para o while não ser infinito
	# e parar depois de percorrer toda a lista
	while(len(lista) > i):
		if(lista[i]%2==1):
			cont+=1

		# Adicionado para que percorra toda a lista, item a item
		i += 1

	# Retirado de dentro do while para que apareça apenas 1 baldo
	if(cont!=0):
		nome = nome+"baldo"

	$Label2.text = nome
