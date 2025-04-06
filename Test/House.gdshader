shader_type spatial;
render_mode unshaded;

uniform sampler2D albedo_texture;
uniform float brightness : hint_range(0.0, 2.0) = 1.0; // Allows dimming & boosting

void fragment() {
    vec3 tex_color = texture(albedo_texture, UV).rgb;
    vec3 final_color = mix(vec3(0.0), tex_color, brightness); // Blends with black
    
    ALBEDO = final_color;  
}