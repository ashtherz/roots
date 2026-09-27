shader_type canvas_item;

instance uniform vec4 silhouetteColor = vec4(1.0, 1.0, 0.8, 0.15);

float inside(vec2 uv)
{
    return uv == clamp(uv, vec2(0.0), vec2(1.0)) ? 1.0 : 0.0;
}

void fragment()
{
    vec4 tcol = texture(TEXTURE, UV) * inside(UV);

    if (tcol.a != 0.0)
    {
		tcol = silhouetteColor;
	}
	COLOR = tcol;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
