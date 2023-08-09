extends CanvasModulate

@onready var star_particles : ColorRect = $"../ColorRect"
@onready var sky_sprite : Sprite2D = $"../ParallaxLayer/Sprite2D"
@onready var delay_timer : Timer = $"../Timer"
const NIGHT_COLOR : Color = Color("354364")
const DAY_COLOR : Color = Color("ffffff")
const TIME_SCALE = 0.05
var time = 0
var cycle : bool = true

func _process(delta):
	if delay_timer.time_left:
		return
	time += delta * TIME_SCALE
	self.color = NIGHT_COLOR.lerp(DAY_COLOR, abs(sin(time)))
	star_particles.self_modulate.a = lerp(1, 0, abs(sin(time)))
	sky_sprite.self_modulate.a = lerp(0, 1, abs(sin(time)))
	if time >= PI/2 && cycle==false:
		delay_timer.start(30)
		time = PI/2
		cycle = true
	if time >= PI:
		delay_timer.start(30)
		time = 0
		cycle = false
	
