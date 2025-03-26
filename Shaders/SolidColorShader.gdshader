shader_type canvas_item;

uniform bool swapColorEnabled;
uniform vec3 swapColorMain: source_color;
uniform vec3 swapColorAlt: source_color;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	// Called for every pixel the material is visible on.
	if(swapColorEnabled){
		if ((COLOR.r + COLOR.g + COLOR.b)/3.0 > 0.5){
			COLOR.rgb = swapColorMain;
		}
		else{
			COLOR.rgb = swapColorAlt;
		}
	}
}

//void light() {
	// Called for every pixel for every light affecting the material.
	// Uncomment to replace the default light processing function with this one.
//}
