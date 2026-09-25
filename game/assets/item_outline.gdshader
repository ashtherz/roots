shader_type canvas_item;
render_mode blend_mix;

// Based on https://www.reddit.com/r/godot/comments/84fhuh/2d_outline_shader_finally_got_it_working/

instance uniform float outLineSize  = 4.0; // in pixels
instance uniform vec4  outLineColor = vec4(1.0, 1.0, 1.0, 1.0);

const vec2 NEIGHBOURS[8] = {
    vec2(0.0, 1.0), vec2(0.0, -1.0), vec2(1.0, 0.0), vec2(-1.0, 0.0),
    vec2(1.0, 1.0), vec2(1.0, -1.0), vec2(-1.0, 1.0), vec2(-1.0, -1.0)
};

float inside(vec2 uv)
{
    return uv == clamp(uv, vec2(0.0), vec2(1.0)) ? 1.0 : 0.0;
}

void fragment()
{
    vec4 tcol = texture(TEXTURE, UV) * inside(UV);

    if (tcol.a == 0.0)
    {
        vec2 uvStep = outLineSize * TEXTURE_PIXEL_SIZE;
        float neighbourAlpha = 0.0;
        for (int i = 0; i < 8; i++)
        {
            vec2 uv = UV + NEIGHBOURS[i] * uvStep;
            neighbourAlpha = max(neighbourAlpha, texture(TEXTURE, uv).a * inside(uv));
        }

        if (neighbourAlpha != 0.0)
            tcol = outLineColor;
    }

    COLOR = tcol;
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
