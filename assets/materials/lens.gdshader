shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture;
uniform vec2 shift;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	vec4 mirror_col = texture(screen_texture, SCREEN_UV + (shift * SCREEN_PIXEL_SIZE));
	COLOR = mirror_col;
}