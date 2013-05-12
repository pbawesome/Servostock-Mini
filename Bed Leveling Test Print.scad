//Made By Selim Tanriverdi

//adjust "layerh" to your layer height 
//adjust "layers" for how many layers you want to print
layerh = .15; //Layer Height
layers = 3;

difference()
{
cube([100,100,layers*layerh]);
translate([10,10,0]) cube([100-20,100-20,layers*layerh]);
}