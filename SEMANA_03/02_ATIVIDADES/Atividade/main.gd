extends Node2D

func putPredefinedListOnLabel():
	var list = [1, 2, 3, 4, 5]
	$Label.text = str(list)
	
func putUserContentOnLabel():
	var list = $TextEdit.text.split(' ')
	$Label.text = str(list)


func _on_fullListButton_button_up():
	putPredefinedListOnLabel()


func _on_userListButton_button_up():
	putUserContentOnLabel()
