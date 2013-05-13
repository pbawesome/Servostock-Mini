// By Erik de Bruijn <reprap@erikdebruijn.nl>
// License: GPLv2 or later
//
// Goal: the goal of this parametric model is to generate a high quality custom timing pulley that is printable without support material.
// NOTE: The diameter of the gear parts are determined by the belt's pitch and number of teeth on a pully.

// //////////////////////////////
// USER PARAMETERS
// //////////////////////////////

eta1 = 0.01;

magnetSize = 2;
magnetHeight = 5;



// Pulley properties
shaftLength = 40;
shaftDiameter = 8; // the shaft at the center, will be subtracted from the pulley. Better be too small than too wide.
hubDiameter = 22; // if the hub or timing pulley is big enough to fit a nut, this will be embedded.
hubHeight = 8; // the hub is the thick cylinder connected to the pulley to allow a set screw to go through or as a collar for a nut.
flanges = 2; // the rims that keep the belt from going anywhere
hubSetScewDiameter = 0; // use either a set screw or nut on a shaft. Set to 0 to not use a set screw.
numTeeth = 20; // this value together with the pitch determines the pulley diameter
toothType = 2; // 1 = slightly rounded, 2 = oval sharp, 3 = square. For square, set the toothWith a little low.

// Belt properties:
pitch = 5; // distance between the teeth
beltWidth = 4; // the width/height of the belt. The (vertical) size of the pulley is adapted to this.
beltThickness = 0.65; // thickness of the part excluding the notch depth!
notchDepth = 1.8; // make it slightly bigger than actual, there's an outward curvature in the inner solid part of the pulley
toothWidth = 1.4; // Teeth of the PULLEY, that is.

// //////////////////////////////
// OpenSCAD SCRIPT
// //////////////////////////////

PI = 3.15159265;
$fs=0.2; // def 1, 0.2 is high res
$fa=3;//def 12, 3 is very nice

pulleyDiameter = pitch*numTeeth/PI;

if(hubSetScewDiameter >= 1) // set screw, no nut
{
	timingPulley( pitch,beltWidth,beltThickness,notchDepth,numTeeth,flanges, shaftDiameter,hubDiameter,hubHeight,hubSetScewDiameter);
}

if(1) // use a nut
{
if(pulleyDiameter >= hubDiameter) // no hub needed
{
	difference()
	{
		timingPulley(
			pitch,beltWidth,beltThickness,notchDepth,numTeeth,flanges,shaftDiameter,hubDiameter,0,hubSetScewDiameter
		);
		translate([0,0,-6]) nut(8,8);
	}
}
if(pulleyDiameter < hubDiameter)
{
	difference()
	{
		timingPulley(
			pitch,beltWidth,beltThickness,notchDepth,numTeeth,flanges,shaftDiameter,hubDiameter,hubHeight,hubSetScewDiameter
		);
		translate([0,0,8]) nut(8,12);
	}
}
}



module timingPulley(
	pitch, beltWidth, beltThickness, notchDepth, numTeeth, flanges, shaftDiameter, hubDiameter, hubHeight, hubSetScewDiameter
) {
	totalHeight = beltWidth + flanges + hubHeight;


		union()
		{
			timingGear(pitch,beltWidth,beltThickness,numTeeth,notchDepth,flanges);
			hub(hubDiameter,hubHeight,hubSetScewDiameter);
		}
	

	module shaft(shaftHeight, shaftDiameter)
	{
		cylinder(h = shaftHeight, r = shaftDiameter/2, center =true);
	}


	module timingGear(pitch,beltWidth,beltThickness,numTeeth,notchDepth,flanges)
	{
		flangeHeight = 0;
		//if(flanges==1)
		{
			flangeHeight = 2;
		}
		
		toothHeight = beltWidth+flangeHeight*2;
		circumference = numTeeth*pitch;
		outerRadius = circumference/PI/2-beltThickness;
		innerRadius = circumference/PI/2-notchDepth-beltThickness;

		union()
		{
			//solid part of gear
			translate([0,0,-toothHeight]) cylinder(h = toothHeight, r = innerRadius, center =false);
			//teeth part of gear
			translate([0,0,-toothHeight/2]) teeth(pitch,numTeeth,toothWidth,notchDepth,toothHeight);
	
			// flanges:
				//top flange
				translate([0,0,0]) cylinder(h = 1, r1=outerRadius,r2=outerRadius+1);
				#translate([0,0,-flangeHeight]) cylinder(h = flangeHeight+1, r2=outerRadius,r1=innerRadius);
				#translate([0,0,1]) cylinder(h = 1, r=outerRadius+1);
		
				//bottom flange
				#translate([0,0,-toothHeight-flangeHeight/2]) cylinder(h = 1, r=outerRadius+1);
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
				#translate([notchDepth*0.5-1,0,0]) cube(size = [notchDepth+2,toothWidth,toothHeight],center = true);
		  		//scale([notchDepth/4, toothWidth/2, 1]) cylinder(h = toothHeight, r = 1, center=true);
			}
		}
	}
}

























/**
 *  Parametric servo arm generator for OpenScad
 *  Générateur de palonnier de servo pour OpenScad
 *
 *  Copyright (c) 2012 Charles Rincheval.  All rights reserved.
 *
 *  This library is free software; you can redistribute it and/or
 *  modify it under the terms of the GNU Lesser General Public
 *  License as published by the Free Software Foundation; either
 *  version 2.1 of the License, or (at your option) any later version.
 *
 *  This library is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
 *  Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public
 *  License along with this library; if not, write to the Free Software
 *  Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA  02110-1301  USA
 *
 *  Last update :
 *  https://github.com/hugokernel/OpenSCAD_ServoArms
 *
 *  http://www.digitalspirit.org/
 */

arm_length = 20;

arm_count = 4; // [1,2,3,4,5,6,7,8]

//  Clear between arm head and servo head (PLA: 0.3, ABS 0.2)
SERVO_HEAD_CLEAR = 0.2; // [0.2,0.3,0.4,0.5]

$fn = 40 / 1;

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
FUTABA_3F_SPLINE = [
    [5.92, 4, 1.1, 2.5],
    [25, 0.3, 0.7, 0.1]
];

module servo_futaba_3f(length, count) {
    servo_arm(FUTABA_3F_SPLINE, [length, count]);
}

/**
 *  If you want to support a new servo, juste add a new spline definition array
 *  and a module named like servo_XXX_YYY where XXX is servo brand and YYY is the
 *  connection type (3f) or the servo type (s3003)
 */

module servo_standard(length, count) {
    servo_futaba_3f(length, count);
}

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
 *
 */
module servo_head_tooth(length, width, height, head_height) {
    linear_extrude(height = head_height) {
        polygon([[-length / 2, 0], [-width / 2, height], [width / 2, height], [length / 2,0]]);
    }
}

/**
 *  Servo head
 */
module servo_head(params, clear = SERVO_HEAD_CLEAR) {

    head = params[0];
    tooth = params[1];

    head_diameter = head[0];
    head_heigth = head[1];

    tooth_count = tooth[0];
    tooth_height = tooth[1];
    tooth_length = tooth[2];
    tooth_width = tooth[3];

    cylinder(r = head_diameter / 2, h = head_heigth + 1);

    cylinder(r = head_diameter / 2 - tooth_height + 0.03 + clear, h = head_heigth);

    for (i = [0 : tooth_count]) {
        rotate([0, 0, i * (360 / tooth_count)]) {
            translate([0, head_diameter / 2 - tooth_height + clear, 0]) {
                servo_head_tooth(tooth_length, tooth_width, tooth_height, head_heigth);
            }
        }
    }
}

/**
 *  Servo hold
 *  - Head / Tooth parameters
 *  - Arms params (length and count)
 */
module servo_arm(params, arms) {

    head = params[0];
    tooth = params[1];

    head_diameter = head[0];
    head_heigth = head[1];
    head_thickness = head[2];
    head_screw_diameter = head[3];

    tooth_length = tooth[2];
    tooth_width = tooth[3];

    arm_length = arms[0];
    arm_count = arms[1];

    /**
     *  Servo arm
     *  - length is from center to last hole
     */
    module arm(tooth_length, tooth_width, head_height, head_heigth, hole_count = 1) {

        arm_screw_diameter = 2;

        difference() {
            union() {
                cylinder(r = tooth_width / 2, h = head_heigth);

                linear_extrude(height = head_heigth) {
                    polygon([
                        [-tooth_width / 2, 0], [-tooth_width / 3, tooth_length],
                        [tooth_width / 3, tooth_length], [tooth_width / 2, 0]
                    ]);
                }

                translate([0, tooth_length, 0]) {
                    cylinder(r = tooth_width / 3, h = head_heigth);
                }

                if (tooth_length >= 12) {
                    translate([-head_heigth / 2 + 2, 3.8, -4]) {
                        rotate([90, 0, 0]) {
                            rotate([0, -90, 0]) {
                                linear_extrude(height = head_heigth) {
                                    polygon([
                                        [-tooth_length / 1.7, 4], [0, 4], [0, - head_height + 5],
                                        [-2, - head_height + 5]
                                    ]);
                                }
                            }
                        }
                    }
                }
            }

            // Hole
            for (i = [0 : hole_count - 1]) {
                //translate([0, length - (length / hole_count * i), -1]) {
                translate([0, tooth_length - (4 * i), -1]) {
                    cylinder(r = arm_screw_diameter / 2, h = 10);
                }
            }
        }
    }

    difference() {
        translate([0, 0, 0.1]) {
            cylinder(r = head_diameter / 2 + head_thickness, h = head_heigth + 1);
        }

        cylinder(r = head_screw_diameter / 2, h = 10);

        servo_head(params);
    }



    
}

/*
module demo() {
	

	difference(){
		union(){
		translate([0,0,-shaftLength/2])
			cylinder(r = 18.5, h = 10);
			shaft(40,shaftDiameter);	
		}

		translate([0,0,-shaftLength/2])
			cylinder(r = shaftDiameter/2, h = 10);
	}
		translate([0,0,-shaftLength/2-0.1])
			rotate([0, 0, 0])
        		servo_standard(arm_length, arm_count);
		difference(){
			translate([0,0,shaftHeight])
				cylinder(r = shaftDiameter/2, h = 20);
			#translate([-magnetSize/2,-magnetSize/2,shaftLength/2-magnetHeight+eta1])
				cube([magnetSize, magnetSize, magnetHeight]);
	}

}

demo();
*/
