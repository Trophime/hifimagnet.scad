use <../../dotSCAD-3.3/src/helix_extrude.scad>

// see data in M8_Be.yaml

// control precision with fa, ...
// see https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Primitive_Solids
// cylinder:
// $fa : minimum angle (in degrees) of each fragment.
// $fs : minimum circumferential length of each fragment.
// $fn : fixed number of fragments in 360 degrees. Values of 3 or more override $fa and $fs

$fa=5;

// better to centralize data params here
rint = 200;
rext = 340;
z_inf = -302.99;
z_sup = 302.99;
electric_height = 2 * 298.995;
dz = abs(z_sup-z_inf);

// helical cut
turns = [3, 12, 3];
pitch = [152.145/turns[0], 293.7, 152.145/turns[2]];
cut_width = 0.2; // instead of 0.2
color = ["red", "blue", "red"];
echo(rint=rint, rext=rext, dz=dz, turns=turns, electric_height=electric_height, pitch=pitch);

n_tierods = 32;
d_tierods = 8;
r_tierods = 301.72;

coolingslits = true;
d_slits = 2.1;
n_slits = 128;
r_slits = [208.95, 217.82, 227.02, 236.56, 246.45, 258.71, 267.38, 278.39, 289.84, 301.72, 314.06, 326.86];
shift_slits = [360/n_slits/2, 0., 360/n_slits/2, 0, 360/n_slits/2, 0, 360/n_slits/2, 0, 360/n_slits/2, 0, 360/n_slits/2, 0];

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

// helical cut (width=h)
module cut(r1, r2, h, n, p){    
    e = (r2 - r1)*1.2;
    shape_pts = [
        [-1,-h/2],
        [e, -h/2],
        [e, h/2],
        [-1, h/2]
    ];

    z = 0;
    tz = 0;
    dz = [for(i = [0:len(n)-1]) n[i]*p[i]];
    echo(dz=dz);
    for(i = [0:len(n)-1]){
      tz = [ for (a=0, b=dz[0]; a <= i; a= a+1, b=b+(dz[a]==undef?0:dz[a])) b];
      echo(section=i, z=z, tz=tz[i]-n[i]*p[i], n=n[i], p=p[i]);
      color(color[i]){
	translate([0,0,tz[i]-n[i]*p[i]]){
	  helix_extrude(shape_pts, 
	    radius = r1, 
            levels = n[i], 
            level_dist = p[i],
            vt_dir = "SPI_UP"
          );
        };
      };
    }
}


module tierod(r, r1, h){
    translate([r,0,0])
    color( "yellow" )
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

module coolingslit(r, d, h){
  hc = h * 1.2;
  color("green")
  {
    translate([r,0,0]){
       cylinder(h=hc, r=d/2, center=true);
    }
  };
}

module coolingslits(n, r, d, h){
    theta = 360/ n;
    echo(theta);
    for(i = [0:n-1]){
        rotate(a=i*theta, v=[0,0,1]){
	  coolingslit(r, d, h);
        };
    }
}

 
difference(){
    difference(){
        base(rint, rext, dz);
        translate([0,0,-electric_height/2]){
	  cut(rint*0.9, rext*1.1, cut_width, turns, pitch);
        };
    };
    tierods(n_tierods, r_tierods, d_tierods/2, dz);

    if (coolingslits) {
        // add cooling slits
        for (i = [0:len(r_slits)-1]){
	  rotate(a=shift_slits[i], v=[0,0,1]){coolingslits(n_slits, r_slits[i], d_slits, dz);};
        }
    };
};

// next Open CGALlab, apply cap, apply tetra mesh, save as ascii
