RSRC                    Shader            ��������                                                  resource_local_to_scene    resource_name    code    script           local://Shader_xrjhj �          Shader          y   shader_type canvas_item;

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    COLOR = vec4(1, 1, 1, color.a);
}       RSRC