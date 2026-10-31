extends Node

# Использование preload() — это "железобетонный" способ заставить Godot 
# включить сцены в экспорт. Анализатор зависимостей видит preload() 
# и автоматически упаковывает файл в .pck архив.
#
# ВАЖНО: Если путь написан неверно (ошибка в регистре букв или имени), 
# Godot выдаст ошибку ПРЯМО ЗДЕСЬ, в редакторе. Это хорошо: так мы 
# сразу узнаем, как файл называется на самом деле!

const SCENE_MAIN_LEVEL = preload("res://Scenes/main.tscn")
const SCENE_AUTHORS = preload("res://Scenes/authors_scene.tscn")
const SCENE_MAIN_MENU = preload("res://Scenes/main_menu.tscn")
