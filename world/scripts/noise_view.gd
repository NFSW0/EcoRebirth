extends Control

var noise = null
var noise_texture = null
var noise_sprite = null
var noise_image = null

@onready var cellular_distance_function = $CellularDistanceFunction
@onready var cellular_jitter = $CellularJitter
@onready var cellular_return_type = $CellularReturnType
@onready var domain_warp_enabled = $DomainWarpEnabled
@onready var domain_warp_type = $DomainWarpType
@onready var domain_warp_frequency = $DomainWarpFrequency
@onready var domain_warp_amplitude = $DomainWarpAmplitude
@onready var domain_warp_fractal_type = $DomainWarpFractalType
@onready var domain_warp_fractal_gain = $DomainWarpFractalGain
@onready var domain_warp_fractal_lacunarity = $DomainWarpFractalLacunarity
@onready var domain_warp_fractal_octaves = $DomainWarpFractalOctaves
@onready var fractal_type = $FractalType
@onready var fractal_octaves = $FractalOctaves
@onready var fractal_lacunarity = $FractalLacunarity
@onready var fractal_gain = $FractalGain
@onready var fractal_ping_pong_strength = $FractalPingPongStrength
@onready var fractal_weighted_strength = $FractalWeightedStrength
@onready var noise_type = $NoiseType
@onready var frequency = $Frequency
@onready var offset_x = $OffsetX
@onready var offset_y = $OffsetY
@onready var offset_z = $OffsetZ
@onready var my_seed = $Seed

func _ready():
	noise = FastNoiseLite.new()
	update_noise()
	noise_texture = ImageTexture.new()
	noise_texture.create_from_image(noise_image)
	noise_sprite = Sprite2D.new()
	noise_sprite.texture = noise_texture
	add_child(noise_sprite)
	cellular_distance_function.connect("item_selected", update_noise)
	cellular_jitter.connect("value_changed", update_noise)
	cellular_return_type.connect("item_selected", update_noise)
	domain_warp_enabled.connect("toggled", update_noise)
	domain_warp_type.connect("item_selected", update_noise)
	domain_warp_frequency.connect("value_changed", update_noise)
	domain_warp_amplitude.connect("value_changed", update_noise)
	domain_warp_fractal_type.connect("item_selected", update_noise)
	domain_warp_fractal_gain.connect("value_changed", update_noise)
	domain_warp_fractal_lacunarity.connect("value_changed", update_noise)
	domain_warp_fractal_octaves.connect("value_changed", update_noise)
	fractal_type.connect("item_selected", update_noise)
	fractal_octaves.connect("value_changed", update_noise)
	fractal_lacunarity.connect("value_changed", update_noise)
	fractal_gain.connect("value_changed", update_noise)
	fractal_ping_pong_strength.connect("value_changed", update_noise)
	fractal_weighted_strength.connect("value_changed", update_noise)
	noise_type.connect("item_selected", update_noise)
	frequency.connect("value_changed", update_noise)
	offset_x.connect("value_changed", update_noise)
	offset_y.connect("value_changed", update_noise)
	offset_z.connect("value_changed", update_noise)
	my_seed.connect("value_changed", update_noise)

func update_noise():
	noise.set_cellular_distance_function(cellular_distance_function.get_selected_id())
	noise.set_cellular_jitter(cellular_jitter.value)
	noise.set_cellular_return_type(cellular_return_type.get_selected_id())
	noise.set_domain_warp_enabled(domain_warp_enabled.is_pressed())
	noise.set_domain_warp_type(domain_warp_type.get_selected_id())
	noise.set_domain_warp_frequency(domain_warp_frequency.value)
	noise.set_domain_warp_amplitude(domain_warp_amplitude.value)
	noise.set_domain_warp_fractal_type(domain_warp_fractal_type.get_selected_id())
	noise.set_domain_warp_fractal_gain(domain_warp_fractal_gain.value)
	noise.set_domain_warp_fractal_lacunarity(domain_warp_fractal_lacunarity.value)
	noise.set_domain_warp_fractal_octaves(domain_warp_fractal_octaves.value)
	noise.set_fractal_type(fractal_type.get_selected_id())
	noise.set_fractal_octaves(fractal_octaves.value)
	noise.set_fractal_lacunarity(fractal_lacunarity.value)
	noise.set_fractal_gain(fractal_gain.value)
	noise.set_fractal_ping_pong_strength(fractal_ping_pong_strength.value)
	noise.set_fractal_weighted_strength(fractal_weighted_strength.value)
	noise.set_noise_type(noise_type.get_selected_id())
	noise.set_frequency(frequency.value)
	noise.set_offset(offset_x.value, offset_y.value, offset_z.value)
	noise.set_seed(my_seed.value)
	noise_image = generate_noise_image()
	noise_texture.create_from_image(noise_image)
	noise_sprite.texture = noise_texture

func generate_noise_image() -> Image:
	var height = 256
	var width = 256
	var image = Image.create(width, height, false, Image.FORMAT_RGBA8)
	for y in range(height):
		for x in range(width):
			var noise_value = noise.get_noise_3d(x, y, 0)
			var color = Color(noise_value, noise_value, noise_value)
			image.set_pixel(x, y, color)
	return image
