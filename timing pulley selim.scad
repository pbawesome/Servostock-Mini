$fn = 100;
eta1 = 0.1;
/////////////////////////
////Pulley Properties////
/////////////////////////
shaftDiameter = 8; 
flanges = 2; // the rims that keep the belt from going anywhere
flangeHeight = 2;
numTeeth = 36; // this value together with the pitch determines the pulley diameter
toothType = 2; // 1 = slightly rounded, 2 = oval sharp, 3 = square. For square, set the toothWith a little low.

splineToPulleyHeight = 10;


////////////////////////
/////Belt Proerties/////
////////////////////////
pitch = 5; // distance between the teeth
beltWidth = 4; // the width/height of the belt. The (vertical) size of the pulley is adapted to this.
beltThickness = 0.65; // thickness of the part excluding the notch depth!
notchDepth = 1.8; // make it slightly bigger than actual, there's an outward curvature in the inner solid part of the pulley
toothWidth = 1.4; // Teeth of the PULLEY, that is.
toothHeight = beltWidth+flangeHeight*2;

////////////////////////
////Magnet Proerties////
////////////////////////

magnetSize = 3;
magnetHeight = 10;
magnetDistance = 33;		//Distance from tip of magnet to beginning of servo spline
bearingDistance = 25;
shaftLength = magnetDistance-splineToPulleyHeight;



//  Clear between head cutout and servo head (PLA: 0.3, ABS 0.2)
SERVO_HEAD_CLEAR = 0.3; // [0.2,0.3,0.4,0.5]
/**
 *  Head / Tooth parameters
 *  Futaba 3F Standard Spline
 *  http://www.servocity.com/html/futaba_servo_splines.html
 *
 *  First array (head related) :
 *  0. Head external diameter
 *  1. Head heigth
 *  2. Head thickness
 *  3. Head screw diameter
 *
 *  Second array (tooth related) :
 *  0. Tooth count
 *  1. Tooth height
 *  2. Tooth length
 *  3. Tooth width
 */
SPLINE = [
    [5.92, 4, 1.1, 2.5],
    [25, 0.3, 0.7, 0.1]
];
/**
 *  Tooth
 *
 *    |<-w->|
 *    |_____|___
 *    /     \  ^h
 *  _/       \_v
 *   |<--l-->|
 *
 *  - tooth length (l)
 *  - tooth width (w)
 *  - tooth height (h)
 *  - height
 */
	clear = SERVO_HEAD_CLEAR;
   head = SPLINE[0];
   tooth = SPLINE[1];
   head_diameter = head[0];
   head_heigth = head[1];
   tooth_count = tooth[0];
   tooth_height = tooth[1];
   tooth_length = tooth[2];
   tooth_width = tooth[3];

module servo_head() {
   cylinder(r = head_diameter / 2, h = head_heigth + 1);
   cylinder(r = head_diameter / 2 - tooth_height + 0.03 + clear, h = head_heigth);
   for (i = [0 : tooth_count]) {
		rotate([0, 0, i * (360 / tooth_count)]) {
      	translate([0, head_diameter / 2 - tooth_height + clear, 0]) {
         	linear_extrude(height = head_heigth) {
   				polygon([[-tooth_length / 2, 0], [-tooth_width / 2, tooth_height], [tooth_width / 2, tooth_height], [tooth_length / 2,0]]);
   			}
         }
      }
   }
}

///////////////////////////////////////////////
///////////       MODULE TEETH     ////////////
///////////////////////////////////////////////

	module teeth(pitch,numTeeth,toothWidth,notchDepth,toothHeight)
	{
		// teeth are apart by the 'pitch' distance
		// this determines the outer radius of the teeth
		circumference = numTeeth*pitch;
		outerRadius = circumference/PI/2-beltThickness;
		innerRadius = circumference/PI/2-notchDepth-beltThickness;
		echo("Teeth diameter is: ", outerRadius*2);
		echo("Pulley inside of teeth radius is: ", innerRadius*2);
		
		for(i = [0:numTeeth-1])
		{
			rotate([0,0,i*360/numTeeth]) translate([innerRadius,0,0]) 
				tooth(toothWidth,notchDepth, toothHeight,toothType);
		}
	}

///////////////////////////////////////////////
///////////       MODULE TOOTH     ////////////
///////////////////////////////////////////////



	module tooth(toothWidth,notchDepth, toothHeight,toothType)
	{
		if(toothType == 1)
		{
			union()
			{
				translate([notchDepth*0.25,0,0]) 
					cube(size = [notchDepth,toothWidth,toothHeight],center = true);
		  		translate([notchDepth*0.75,0,0]) scale([notchDepth/4, toothWidth/2, 1]) 
					cylinder(h = toothHeight, r = 1, center=true);
			}
		}
		if(toothType == 2)
			scale([notchDepth, toothWidth/2, 1]) cylinder(h = toothHeight, r = 1, center=true);

		if(toothType == 3)
		{
			union()
			{
				translate([notchDepth*0.5-1,0,0]) cube(size = [notchDepth+2,toothWidth,toothHeight],center = true);
		  		//scale([notchDepth/4, toothWidth/2, 1]) cylinder(h = toothHeight, r = 1, center=true);
			}
		}
	}



///////////////////////////////////////////////
///////////       MODULE PULLEY     ///////////
///////////////////////////////////////////////

module pulley(){
	circumference = numTeeth*pitch;
	outerRadius = circumference/PI/2-beltThickness;
	innerRadius = circumference/PI/2-notchDepth-beltThickness;
	union(){
		//solid part of gear
		translate([0,0,head_heigth+splineToPulleyHeight])
			cylinder(h = toothHeight, r = innerRadius, center =true);

		//teeth part of gear
			translate([0,0,head_heigth+splineToPulleyHeight])
				teeth(pitch,numTeeth,toothWidth,notchDepth,toothHeight);

		//top flange
		translate([0,0,head_heigth+splineToPulleyHeight+toothHeight/2])
			cylinder(h = 1, r1=outerRadius,r2=outerRadius+1);
		translate([0,0,head_heigth+splineToPulleyHeight+toothHeight/4])
			cylinder(h = flangeHeight+1, r2=outerRadius,r1=innerRadius);
		translate([0,0,head_heigth+splineToPulleyHeight+toothHeight/2+flangeHeight/2])
			cylinder(h = 1, r=outerRadius+1);

		//bottom flange
		translate([0,0,0])
			cylinder(h = splineToPulleyHeight, r=outerRadius+1);

		shaft();
		}
}

///////////////////////////////////////////////
///////////       MODULE SHAFT     ////////////
///////////////////////////////////////////////

module shaft(){
	difference(){
		union(){
			//Main Shaft
			translate([0,0,splineToPulleyHeight])
				cylinder(r = shaftDiameter/2, h = shaftLength, center = false);
			//Bearing Stop
			translate([0,0,splineToPulleyHeight])
				cylinder(r = shaftDiameter, h = bearingDistance-splineToPulleyHeight, center = false);
		}
		//Magnet Cutout
		translate([-magnetSize/2, -magnetSize/2, magnetDistance-magnetHeight+eta1])
			cube([magnetSize,magnetSize,magnetHeight]);
	
	}

}
echo(toothHeight);

module servo_pulley(){

	difference(){
		pulley();
		translate([0,0,-eta1])
			servo_head();
	}




}
servo_pulley();