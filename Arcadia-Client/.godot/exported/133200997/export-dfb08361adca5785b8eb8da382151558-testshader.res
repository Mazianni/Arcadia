RSRC                    VisualShader            ��������                                            >      resource_local_to_scene    resource_name    output_port_for_preview    default_input_values    expanded_output_ports 	   constant    script    type 	   function 
   condition    input_name    op_type 	   operator    code    graph_offset    mode    modes/blend    flags/skip_vertex_transform    flags/unshaded    flags/light_only    nodes/vertex/0/position    nodes/vertex/connections    nodes/fragment/0/position    nodes/fragment/7/node    nodes/fragment/7/position    nodes/fragment/8/node    nodes/fragment/8/position    nodes/fragment/9/node    nodes/fragment/9/position    nodes/fragment/10/node    nodes/fragment/10/position    nodes/fragment/11/node    nodes/fragment/11/position    nodes/fragment/14/node    nodes/fragment/14/position    nodes/fragment/15/node    nodes/fragment/15/position    nodes/fragment/16/node    nodes/fragment/16/position    nodes/fragment/17/node    nodes/fragment/17/position    nodes/fragment/18/node    nodes/fragment/18/position    nodes/fragment/19/node    nodes/fragment/19/position    nodes/fragment/connections    nodes/light/0/position    nodes/light/connections    nodes/start/0/position    nodes/start/connections    nodes/process/0/position    nodes/process/connections    nodes/collide/0/position    nodes/collide/connections    nodes/start_custom/0/position    nodes/start_custom/connections     nodes/process_custom/0/position !   nodes/process_custom/connections    nodes/sky/0/position    nodes/sky/connections    nodes/fog/0/position    nodes/fog/connections        +   local://VisualShaderNodeVec2Constant_d8pv4 �      +   local://VisualShaderNodeVec2Constant_t8cqb 	      &   local://VisualShaderNodeCompare_mw4fl Z	      &   local://VisualShaderNodeCompare_neuar �	      $   local://VisualShaderNodeInput_4br5v �	      &   local://VisualShaderNodeCompare_eou22 
      &   local://VisualShaderNodeCompare_73p6s ?
      "   local://VisualShaderNodeMix_pjret s
      "   local://VisualShaderNodeMix_sg5vy �
      "   local://VisualShaderNodeMix_sl7sj �
      &   local://VisualShaderNodeFloatOp_djmwx �
         local://VisualShader_nmvof ?         VisualShaderNodeVec2Constant       
   ���=             VisualShaderNodeVec2Constant       
   fff?             VisualShaderNodeCompare                      VisualShaderNodeCompare                      VisualShaderNodeInput                    
         uv          VisualShaderNodeCompare                      VisualShaderNodeCompare                      VisualShaderNodeMix             VisualShaderNodeMix             VisualShaderNodeMix             VisualShaderNodeFloatOp                                      �@                  VisualShader          �  shader_type canvas_item;
render_mode blend_mix;




void fragment() {
// Input:11
	vec2 n_out11p0 = UV;
	float n_out11p1 = n_out11p0.r;
	float n_out11p2 = n_out11p0.g;


// Vector2Constant:7
	vec2 n_out7p0 = vec2(0.100000, 0.000000);


// Compare:9
	bool n_out9p0 = n_out11p1 <= n_out7p0.x;


// Vector2Constant:8
	vec2 n_out8p0 = vec2(0.900000, 0.000000);


// Compare:10
	bool n_out10p0 = n_out11p1 >= n_out8p0.x;


// Mix:17
	float n_in17p2 = 0.50000;
	float n_out17p0 = mix((n_out9p0 ? 1.0 : 0.0), (n_out10p0 ? 1.0 : 0.0), n_in17p2);


// Compare:15
	bool n_out15p0 = n_out11p2 <= n_out7p0.x;


// Compare:14
	bool n_out14p0 = n_out11p2 >= n_out8p0.x;


// Mix:16
	float n_in16p2 = 0.50000;
	float n_out16p0 = mix((n_out15p0 ? 1.0 : 0.0), (n_out14p0 ? 1.0 : 0.0), n_in16p2);


// Mix:18
	float n_in18p2 = 0.50000;
	float n_out18p0 = mix(n_out17p0, n_out16p0, n_in18p2);


// FloatOp:19
	float n_in19p1 = 4.00000;
	float n_out19p0 = n_out18p0 * n_in19p1;


// Output:0
	COLOR.a = n_out19p0;


}
                       
    ��D  ��                
     p�  \�               
     p�  ��               
     �B  ��               
     �B   �                
     p�    !            "   
     �B  �C#            $   
     �B  C%            &   
     �C   C'            (   
     �C   �)         	   *   
     D   �+         
   ,   
     HD   �-       @          	             
                                      
             	                                  
             	                                                                                                     RSRC