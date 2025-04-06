shader_type canvas_item;

uniform sampler2D SCREEN_TEXTURE : hint_screen_texture;
uniform float noise_intensity : hint_range(0.0, 1.0) = 0.05;
uniform float noise_speed : hint_range(0.0, 1.0) = 0.1;
uniform float transparency : hint_range(0.0, 1.0) = 0.5;

float random(vec2 uv) {
    return fract(sin(dot(uv, vec2(12.9898, 78.233))) * 43758.5453);
}

void fragment() {
    vec2 uv = SCREEN_UV;
    vec4 color = texture(SCREEN_TEXTURE, uv);

    // Reduzindo a velocidade do ruído
    float noise = random(uv + TIME * noise_speed) * 2.0 - 1.0;

    color.rgb += noise * noise_intensity;

    // Aplicando transparência
    color.a *= transparency;

    COLOR = color;
}
