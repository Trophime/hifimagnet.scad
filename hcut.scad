use <./dotSCAD-3.3/src/helix_extrude.scad>

// see data in M8_Be.yaml

// control precision with fa, ...
// see https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Primitive_Solids
// cylinder:
// $fa : minimum angle (in degrees) of each fragment.
// $fs : minimum circumferential length of each fragment.
// $fn : fixed number of fragments in 360 degrees. Values of 3 or more override $fa and $fs

$fa=5;
$fn=100;

// better to centralize data params here
rint = 305;
rext = 401;
z_inf = -348.5;
z_sup = 348.5;
electric_height = 2* 345.5;
dz = abs(z_sup-z_inf);

turns = 10; // working with 5
pitch = electric_height/turns;
cut_width = 1; // instead of 0.2
echo(rint=rint, rext=rext, dz=dz, turns=turns, electric_height=electric_height, pitch=pitch);

cut_display = true;
tierods_display = true;
n_tierods = 36;
d_tierods = 10;
r_tierods = 349.7;

coolingslits_display = true;
d_slits = 5;
n_slits = 144;
r_slits = [319.25, 349.7, 381.1];
shift_slits = [360/n_slits/2, 0., 360/n_slits/2];

for (i = [0:len(r_slits)-1]){
    echo(i=i, r=r_slits[i], shift_angle=shift_slits[i]);
}

module base(r1, r2, h){
  h1 = h * 1.2;
  difference(){
        cylinder(h=h, r=r2, center=true);
        cylinder(h=h1, r=r1, center=true);
  }
}

// set cut width to 2 instead of 0.2 for test
module cut(r1, r2, h, n, p){
  factor = 1;
    e = (r2 - r1)*1.2;
    shape_pts = [
        [-1,-factor*h],
        [e, -factor*h],
        [e,  factor*h],
        [-1, factor*h],
    ];

    helix_extrude(shape_pts, 
          radius = r1, 
          levels = n, 
          level_dist = p,
	  scale = [1.,1, 1/factor],
          vt_dir = "SPI_UP"
    );
}

module tierod(r, r1, h){
    translate([r,0,0])
    color( "red" )
    {
        cylinder(h=h*1.2, r=r1, center=true);
    };
}

module tierods(n, r, r1, h){
    theta = 360/ n;
    echo(theta);
    for(i = [0:n-1]){
        rotate(a=i*theta, v=[0,0,1]){
	       tierod(r, r1, h);
        };
    }
}

module coolingslits(n, r, r1, h){
    theta = 360/ n;
    echo(theta);
    for(i = [0:n-1]){
        rotate(a=i*theta, v=[0,0,1]){
	       tierod(r, r1, h);
        };
    }
}

module magnet(){
  difference(){
    difference(){
        base(rint, rext, dz);
        translate([0,0,-electric_height/2]){
	  cut(rint, rext, cut_width, turns, pitch);
        };
    };
    if (tierods_display) {
       tierods(n_tierods, r_tierods, d_tierods/2, dz);
    };

    if (coolingslits_display) {
        // add cooling slits
        for (i = [0:len(r_slits)-1]){
            rotate(a=shift_slits[i], v=[0,0,1]){coolingslits(n_slits, r_slits[i], d_slits/2, dz);};
        }
    };
  };
}


if (cut_display){
  color("red") intersection(){
    translate([0,0,-electric_height/2]){
	  cut(rint, rext, cut_width, turns, pitch);
    };
    magnet();
  }
  
} else {
  magnet();
};
  
// next Open CGALlab, apply cap, apply tetra mesh, save as ascii
