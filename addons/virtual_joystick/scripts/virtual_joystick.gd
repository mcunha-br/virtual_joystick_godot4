@tool
extends Node2D

signal analogic_chage(move: Vector2)
signal analogic_just_pressed
signal analogic_released

@export var normalized: bool = true
@export var zero_at_touch: bool = false

@export var border: Texture2D:
	set(value):
		border = value
		_draw()
		
@export var stick: Texture2D:
	set(value):
		stick = value
		_draw()

@export var stick_pressed: Texture2D

var joystick = Sprite2D.new()
var touch = TouchScreenButton.new()
var radius := Vector2(32, 32)
var boundary := 64
var ongoing_drag := -1
var return_accel := 20
var threshold := 10
var is_pressed = false
@onready var default_global_position = global_position


func _draw() -> void:	
	if get_child_count() == 0:
		add_child(joystick)
		
	if joystick.get_child_count() == 0:
		joystick.add_child(touch)	
		
	joystick.texture = border if is_instance_valid(border) else preload("res://addons/virtual_joystick/sprites/joystick.png")
	touch.texture_normal = stick if is_instance_valid(stick) else preload("res://addons/virtual_joystick/sprites/stick.png")


func _ready() -> void:	
	touch.released.connect(func(): emit_signal("analogic_released"))
	touch.position = -radius
	
	if stick_pressed == null:
		stick_pressed = preload("res://addons/virtual_joystick/sprites/stick_pressed.png")
	

func _process(delta: float) -> void:
	if ongoing_drag == -1:
		var pos_difference = (Vector2.ZERO - radius) - touch.position
		touch.position += pos_difference * return_accel * delta * 2
		

func _input(event: InputEvent) -> void:
	if event is InputEventScreenDrag or ( event is InputEventScreenTouch and event.is_pressed()):
		var event_dist_from_center = (event.position - global_position).length()

		if event_dist_from_center <= boundary * global_scale.x or event.get_index() == ongoing_drag:
			if !is_pressed:
				is_pressed = true
				emit_signal("analogic_just_pressed")
				
				touch.texture_normal = stick_pressed
				
				if zero_at_touch:
					global_position = event.position
			
			touch.global_position = event.position - radius * global_scale
			
			if get_button_pos().length() > boundary:
				touch.position = get_button_pos().normalized() * boundary - radius

			ongoing_drag = event.get_index()
			if normalized:
				emit_signal("analogic_chage", get_button_pos().normalized())
			else:
				emit_signal("analogic_chage", get_button_pos().normalized() * min (get_button_pos().length()/boundary, 1))
							


	if event is InputEventScreenTouch and not event.is_pressed() and event.get_index() == ongoing_drag:
		ongoing_drag = -1
		emit_signal("analogic_chage", Vector2.ZERO)
		global_position = default_global_position
		is_pressed = false
		touch.texture_normal = stick if is_instance_valid(stick) else preload("res://addons/virtual_joystick/sprites/stick.png")
		

func get_button_pos() -> Vector2:
	return touch.position + radius
	
func get_value() -> Vector2:
	if get_button_pos().length() > threshold:
		return get_button_pos().normalized()
		
	return Vector2.ZERO

