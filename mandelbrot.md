```glsl
vec2 mult(vec2 a, vec2 b) {
    return vec2(a.x * b.x - a.y * b.y, a.x * b.y + a.y * b.x);
}

void mainImage(out vec4 fragColor, in vec2 fragCoord) {
    float scale = 500.0;
    float x = (fragCoord.x - iResolution.x / 2.0) / scale;
    float y = (fragCoord.y - iResolution.y / 2.0) / scale;
    vec2 z = vec2(0, 0);
    vec2 c = vec2(x, y);
    int i = 0;
    for (; i < 255 && length(z) < 2.; i++)
        z = mult(z, z) + c;
        
    float colour = (float(i) / 255.);
    fragColor = i == 255 ? vec4(0) : vec4(vec3(colour), 1.0);
}


```
