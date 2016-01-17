$input v_pos, v_view, v_normal, v_color0, v_texcoord0


#include "./common/common.sh"

uniform vec4 cameraPostion;


vec3 lightPosition = vec3(-4.0, 5.0, .0);

SAMPLER2D(s_planet_texture, 0);
SAMPLER2D(s_planet_texture_day, 1);
void main()
{
	vec3 normal = normalize(v_normal);
	vec3 viewDirection = -normalize(v_view);
	vec3 vertexPosition = v_pos;

	vec3 lightDirection = normalize(lightPosition - vertexPosition);
	//viewDirection = normalize(viewDirection - vertexPosition);

	//apply lamberts cosine law
	vec4 col = vec4(0.3,0.7, 0.4, 1.0);
	vec4 ambient = vec4(0.01,0.01,0.01,1.0);
	col = col * max(dot(normal, lightDirection), 0.0);


	//rim shader
	float rim = 1.0 - dot(viewDirection, normal);
	rim+=0.1;
	//take into account light direction
	float rimLight = dot(lightDirection, normal);
	float f_rim = pow(rim, 8.0);
	f_rim *= (rimLight*2);
	f_rim +=  0.5* rimLight * rim;
	f_rim += 0.05;
	//speculards
	vec3 reflectVec = normalize(-reflect(lightDirection, normal));
	float spec = 0.1* pow(max(dot(reflectVec, viewDirection), 0.0), 9.0);
	vec4 tex = texture2D(s_planet_texture, v_texcoord0.xy);

	//attenuation
	float lightDistance = length(lightPosition);
	float attenuation = 1.0;
	
    vec4 texDay = toLinearAccurate(texture2D(s_planet_texture_day, v_texcoord0.xy/1.1));
	//vec4 texDay = texture2D(s_planet_texture_day, v_texcoord0.xy);
	texDay = texDay * max(dot(normal, lightDirection), 0.0);
	tex = tex * max(dot(normal, lightDirection), 0.0);
	vec4 finalColor = texDay;
	
	gl_FragColor =ambient + attenuation*(finalColor+ spec) + f_rim * vec4(0.3,0.6,1.0,1.0);
	

	//gl_FragColor = toGammaAccurate(attenuation*(finalColor + spec));
	//gl_FragColor = vec4(pow(attenuation*(finalColor.xyz + spec), vec3_splat(1.0/2.2)), 1.0);
	//gl_FragColor += f_rim * vec4(0.3, 0.6, 1.0, 1.0);
	gl_FragColor.w = 1.0;

	//ogl_FragColor = texture2D(s_planet_texture, v_texcoord0.xy);

}
