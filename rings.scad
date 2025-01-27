use <../../dotSCAD-3.3/src/polyline_join.scad>

use <../../dotSCAD-3.3/src/shape_square.scad>
use <../../dotSCAD-3.3/src/ring_extrude.scad>


$fa = 5;
$fn = 100;

module base(){
  rshape_pts = [
    [0, -5],
    [0, 5],
    [10, 5],
    [10, -5]
  ];
  ring_extrude(rshape_pts, radius = 5);
}

module hole(){
  radius_hole = 8;
  thickness_hole = 2;
  shape_pts = [
    [0, -10],
    [0, 10],
    [2, 10],
    [2, -10]
  ];

  // make ring hole from 0 to 45, then rotate 
  union(){
    rotate(-20, [0,0,1]) {ring_extrude(shape_pts, radius = radius_hole, angle = 40);};
    translate([(radius_hole+2/2) * cos(20), (radius_hole+2/2) * sin(20), 0]) {cylinder(25, 2/2, 2/2, center=true);};
    translate([(radius_hole+2/2) * cos(-20), (radius_hole+2/2) * sin(-20), 0]) {cylinder(25, 2/2, 2/2, center=true);};
  };
};

color("red") difference(){
  base();
  hole();
};

color("blue") hole();
