use <../../dotSCAD-3.3/src/polyline_join.scad>

use <../../dotSCAD-3.3/src/shape_square.scad>
use <../../dotSCAD-3.3/src/ring_extrude.scad>


$fa = 5;
$fn = 100;

r = [19.3, 30.7];
z = [0, 20];
r_slit = [24.2, 25.1];
n = 6;
angle = 46;
BPside = true;
fillets = true;

module base(r, e, z_inf, z_sup, angle=360, factor=1){
  h = factor * abs(z_sup-z_inf)/2;
  echo("base:", r=r, e=e,  z_inf=z_inf, z_sup=z_sup, h=h, factor=factor, angle=angle);
  rshape_pts = [
    [0, -h],
    [0, h],
    [e, h],
    [e, -h]
  ];

  ring_extrude(rshape_pts, r, angle);
}

module hole(r, e, z_inf, z_sup, angle=40, factor=1.1, fillet=false){
  echo("hole:", r=r, e=e, z_inf=z_inf, z_sup=z_sup, angle=angle, factor=factor, fillet=fillet);
    
  // make ring hole from 0 to angle, then rotate 
  if (fillet){
      dz = factor * abs(z_sup-z_inf);
      union(){
       rotate(-angle/2, [0,0,1]) {base(r, e, z_inf, z_sup, angle, factor);};
       translate([(r+e/2) * cos(angle/2), (r+e/2) * sin(angle/2), 0]) {cylinder(dz, e/2, e/2, center=true);};
       translate([(r+e/2) * cos(-angle/2), (r+e/2) * sin(-angle/2), 0]) {cylinder(dz, e/2, e/2, center=true);};
      };
  } else {
      base(r, e, z_inf, z_sup, angle, factor);
  };
};

module holes(n, r, e, z_inf, z_sup, angle, fillet){
  theta = 360/ n;
  echo(theta);
  for(i = [0:n-1]){
    rotate(a=i*theta, v=[0,0,1]){
      hole(r, e, z_inf, z_sup, angle=angle, fillet=fillet);
    };
  }
};

// eventually rotate ring
color("red") difference(){
  base(r[0], r[1]-r[0], z[0], z[1], factor=1);
  holes(n, r_slit[0], r_slit[1]-r_slit[0], z[0], z[1], angle, fillet=fillets);
};
