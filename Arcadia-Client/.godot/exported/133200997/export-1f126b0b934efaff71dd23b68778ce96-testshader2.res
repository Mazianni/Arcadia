RSRC                    VisualShader            ��������                                            ?      resource_local_to_scene    resource_name    output_port_for_preview    default_input_values    expanded_output_ports    op_type    script    input_name 	   operator 	   function    code    graph_offset    mode    modes/blend    flags/skip_vertex_transform    flags/unshaded    flags/light_only    nodes/vertex/0/position    nodes/vertex/connections    nodes/fragment/0/position    nodes/fragment/2/node    nodes/fragment/2/position    nodes/fragment/3/node    nodes/fragment/3/position    nodes/fragment/4/node    nodes/fragment/4/position    nodes/fragment/5/node    nodes/fragment/5/position    nodes/fragment/6/node    nodes/fragment/6/position    nodes/fragment/7/node    nodes/fragment/7/position    nodes/fragment/8/node    nodes/fragment/8/position    nodes/fragment/9/node    nodes/fragment/9/position    nodes/fragment/10/node    nodes/fragment/10/position    nodes/fragment/11/node    nodes/fragment/11/position    nodes/fragment/12/node    nodes/fragment/12/position    nodes/fragment/13/node    nodes/fragment/13/position    nodes/fragment/14/node    nodes/fragment/14/position    nodes/fragment/connections    nodes/light/0/position    nodes/light/connections    nodes/start/0/position    nodes/start/connections    nodes/process/0/position    nodes/process/connections    nodes/collide/0/position    nodes/collide/connections    nodes/start_custom/0/position    nodes/start_custom/connections     nodes/process_custom/0/position !   nodes/process_custom/connections    nodes/sky/0/position    nodes/sky/connections    nodes/fog/0/position    nodes/fog/connections        -   local://VisualShaderNodeVectorDistance_7r6do �	      $   local://VisualShaderNodeInput_6m82l 
      +   local://VisualShaderNodeUVPolarCoord_01d5i B
      '   local://VisualShaderNodeVectorOp_6crc0 �
      '   local://VisualShaderNodeVectorOp_c78vn $      &   local://VisualShaderNodeFloatOp_xyp0i �      (   local://VisualShaderNodeFloatFunc_ys82l �      $   local://VisualShaderNodeInput_rpem5 /      &   local://VisualShaderNodeFloatOp_bh0ff f      (   local://VisualShaderNodeFloatFunc_x8vmk �      &   local://VisualShaderNodeFloatOp_4ldud �      $   local://VisualShaderNodeClamp_flm0u 0      *   local://VisualShaderNodeRandomRange_yxgpt �         local://VisualShader_3ucjv �         VisualShaderNodeVectorDistance                    
                 
      ?   ?                   VisualShaderNodeInput             uv          VisualShaderNodeUVPolarCoord                   
      ?   ?           �?                      VisualShaderNodeVectorOp                    
                 
                                       VisualShaderNodeVectorOp                    
                 
   ���>���>                            VisualShaderNodeFloatOp                                      �@                  VisualShaderNodeFloatFunc    	                   VisualShaderNodeInput             time          VisualShaderNodeFloatOp                      VisualShaderNodeFloatFunc    	                  VisualShaderNodeFloatOp                                       ?                  VisualShaderNodeClamp                                 )   �������?           �?         VisualShaderNodeRandomRange             VisualShader     
      P  shader_type canvas_item;
render_mode blend_mix;





// 3D Noise with friendly permission by Inigo Quilez
vec3 hash_noise_range( vec3 p ) {
	p *= mat3(vec3(127.1, 311.7, -53.7), vec3(269.5, 183.3, 77.1), vec3(-301.7, 27.3, 215.3));
	return 2.0 * fract(fract(p)*4375.55) -1.;
}


void fragment() {
// Input:3
	vec2 n_out3p0 = UV;


// Distance:2
	vec2 n_in2p1 = vec2(0.50000, 0.50000);
	float n_out2p0 = distance(n_out3p0, n_in2p1);


	vec2 n_out4p0;
// UVPolarCoord:4
	vec2 n_in4p1 = vec2(0.50000, 0.50000);
	float n_in4p2 = 1.00000;
	float n_in4p3 = 0.00000;
	{
		vec2 __dir = UV - n_in4p1;
		float __radius = length(__dir) * 2.0;
		float __angle = atan(__dir.y, __dir.x) * 1.0 / (PI * 2.0);
		n_out4p0 = mod(vec2(__radius * n_in4p2, __angle * n_in4p3), 1.0);
	}


// VectorOp:5
	vec2 n_out5p0 = vec2(n_out2p0) * n_out4p0;


// VectorOp:6
	vec2 n_in6p1 = vec2(0.30000, 0.30000);
	vec2 n_out6p0 = n_out5p0 - n_in6p1;


// FloatOp:7
	float n_in7p1 = 4.00000;
	float n_out7p0 = n_out6p0.x * n_in7p1;


// Input:9
	float n_out9p0 = TIME;


// RandomRange:14
	vec3 n_in14p0 = vec3(1.00000, 1.00000, 1.00000);
	float n_in14p1 = 0.00000;
	float n_in14p2 = 1.00000;
	float n_out14p0 = mix(n_in14p1, n_in14p2, hash_noise_range(n_in14p0).x);


// FloatOp:12
	float n_out12p0 = n_out9p0 * n_out14p0;


// FloatFunc:8
	float n_out8p0 = sin(n_out12p0);


// FloatFunc:11
	float n_out11p0 = abs(n_out8p0);


// Clamp:13
	float n_in13p1 = 0.40000;
	float n_in13p2 = 1.00000;
	float n_out13p0 = clamp(n_out11p0, n_in13p1, n_in13p2);


// FloatOp:10
	float n_out10p0 = n_out7p0 * n_out13p0;


// Output:0
	COLOR.a = n_out10p0;


}
                       
     �D  C                
     ��   B               
     %�  �A               
     ��  \C               
     p�  pB               
     �B   B               
     �C   B             !   
     �B  �C"            #   
     ��  D$            %   
      D  C&         	   '   
     �C  �C(         
   )   
     ��  D*            +   
     D  �C,            -   
     ��  *D.       4                                                          	                                                              
             
                                   
                    RSRC