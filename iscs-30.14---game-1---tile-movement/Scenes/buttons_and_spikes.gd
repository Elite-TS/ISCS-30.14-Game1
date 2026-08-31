extends TileMapLayer
var button_coordinates: Array[Vector2] = [
	Vector2(1560,-136), #red
	Vector2(1320,-104), #green
	Vector2(1288,-104) #purple
]
var bodies: Array[CharacterBody2D]
var red_spikes: Array[Vector2] = [
	Vector2(95,-9),Vector2(95,-8)
]
var green_spikes: Array[Vector2] = [
	Vector2(81,-8),Vector2(80,-6),Vector2(80,-5)
]
var purple_spikes: Array[Vector2] = [
	Vector2(81,-7),Vector2(81,-6)
]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var character = get_node("../../../Character")
	var crate_1 = get_node(("../../Lever1/Crate1"))
	var crate_2 = get_node(("../../Lever1/Crate2"))
	var crate_3 = get_node(("../../Lever1/Crate3"))
	var crate_4 = get_node(("../../Lever2/Crate4"))
	bodies = [character,crate_1,crate_2,crate_3,crate_4]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var counter = 1
	var red_button_pressed = false
	var green_button_pressed = false
	var purple_button_pressed = false
	for coord in button_coordinates:
		for body in bodies:
			if body.get_global_position().is_equal_approx(coord):
				if counter==1:
					press_red_button()
					red_button_pressed = true
				elif counter==2:
					press_green_button()
					green_button_pressed = true
				else:
					press_purple_button()
					purple_button_pressed=  true
		counter+=1
	if !red_button_pressed:
		reset_red_button()
	if !green_button_pressed:
		reset_green_button()
	if !purple_button_pressed:
		reset_purple_button()


func press_red_button():
	self.set_cell(Vector2(97,-9),3,Vector2(1,3))
	for spike in red_spikes:
		self.set_cell(spike,-1)

func reset_red_button():
	self.set_cell(Vector2(97,-9),3,Vector2(0,3))
	for spike in red_spikes:
		self.set_cell(spike,3,Vector2(2,3))

func press_green_button():
	self.set_cell(Vector2(82,-7),3,Vector2(1,2))
	for spike in green_spikes:
		self.set_cell(spike,-1)

func reset_green_button():
	self.set_cell(Vector2(82,-7),3,Vector2(0,2))
	for spike in green_spikes:
		self.set_cell(spike,3,Vector2(2,2))

func press_purple_button():
	self.set_cell(Vector2(80,-7),3,Vector2(1,1))
	for spike in purple_spikes:
		self.set_cell(spike,-1)

func reset_purple_button():
	self.set_cell(Vector2(80,-7),3,Vector2(0,1))
	for spike in purple_spikes:
		self.set_cell(spike,3,Vector2(2,1))
