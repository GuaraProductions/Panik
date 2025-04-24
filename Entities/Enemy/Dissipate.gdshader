shader_type spatial;
render_mode unshaded, cull_disabled;

uniform sampler2D main_tex;
uniform sampler2D noise_tex;
uniform float glitch_strength : hint_range(0.0, 1.0) = 0.3;
uniform float dissolve_threshold : hint_range(0.0, 1.0) = 0.5;
uniform float time_scale : hint_range(0.1, 10.0) = 1.0;
uniform vec4 tint_color = vec4(1.0);

uniform vec2 uv_scale = vec2(1.0, 1.0); // Add this line

void fragment() {
    vec2 uv = UV * uv_scale; // Apply scale here

    float t = TIME * time_scale;

    float noise_value = texture(noise_tex, uv + vec2(0.0, t * 0.1)).r;

    if (noise_value < dissolve_threshold) {
        discard;
    }

    vec2 glitch_offset = vec2(
        sin(uv.y * 100.0 + t * 20.0) * 0.01,
        cos(uv.x * 100.0 + t * 25.0) * 0.01
    ) * glitch_strength;

    uv += glitch_offset;

    vec4 col;
    col.r = texture(main_tex, uv + glitch_offset * 0.5).r;
    col.g = texture(main_tex, uv).g;
    col.b = texture(main_tex, uv - glitch_offset * 0.5).b;
    col.a = texture(main_tex, uv).a;

    ALBEDO = col.rgb * tint_color.rgb;
    ALPHA = col.a;
}