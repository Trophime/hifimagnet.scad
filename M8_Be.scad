use <./dotSCAD-3.3/src/helix_extrude.scad>

// see data in M8_Be.yaml

// control precision with fa, ...
// see https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Primitive_Solids
// cylinder:
// $fa : minimum angle (in degrees) of each fragment.
// $fs : minimum circumferential length of each fragment.
// $fn : fixed number of fragments in 360 degrees. Values of 3 or more override $fa and $fs

$fa=5;

// better to centralize data params here
rint = 305;
rext = 401;
z_inf = -348.5;
z_sup = 348.5;
electric_height = 2* 345.5;
dz = abs(z_sup-z_inf);

turns = 5; // working with 5
pitch = electric_height/turns;
cut_width = 0.2; // instead of 0.2
echo(rint=rint, rext=rext, dz=dz, turns=turns, electric_height=electric_height, pitch=pitch);

n_tierods = 36;
d_tierods = 10;
r_tierods = 349.7;

coolingslits = true;
d_slits = 1.1;
l_slits = 5.9;
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
    e = (r2 - r1)*1.2;
    shape_pts = [
        [-1,-h],
        [e, -h],
        [e, h],
        [-1, h]
    ];
    
    helix_extrude(shape_pts, 
        radius = r1, 
        levels = n, 
        level_dist = p,
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

module coolingslit(r, d, l, h){
  hc = h * 1.2;
  translate([r,0,0]){
    union(){
      translate([0,d/2,0]){cylinder(h=hc, r=d/2, center=true);};
      cube([d, l, hc], center=true);
      translate([0,-d/2,0]){cylinder(h=hc, r=d/2, center=true);};
    }
  }
}

module coolingslits(n, r, d, l, h){
    theta = 360/ n;
    echo(theta);
    for(i = [0:n-1]){
        rotate(a=i*theta, v=[0,0,1]){
	  coolingslit(r, d, l, h);
        };
    }
}


difference(){
    difference(){
        base(rint, rext, dz);
        translate([0,0,-electric_height/2]){
	  cut(rint, rext, cut_width, turns, pitch);
        };
    };
    tierods(n_tierods, r_tierods, d_tierods/2, dz);

    if (coolingslits) {
        // add cooling slits
        for (i = [0:len(r_slits)-1]){
	  rotate(a=shift_slits[i], v=[0,0,1]){coolingslits(n_slits, r_slits[i], d_slits, l_slits, dz);};
        }
    };
};
 
// next Open CGALlab, apply cap, apply tetra mesh, save as ascii
