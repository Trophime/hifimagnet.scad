use <../../dotSCAD-3.3/src/helix_extrude.scad>

// see data in M8_Be.yaml

// control precision with fa, ...
// see https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Primitive_Solids
// cylinder:
// $fa : minimum angle (in degrees) of each fragment.
// $fs : minimum circumferential length of each fragment.
// $fn : fixed number of fragments in 360 degrees. Values of 3 or more override $fa and $fs

$fa = 5; //1.25;
// $fn = 400;

// better to centralize data params here
odd = true;
rint = 200;
rext = 340;
z_inf = -302.99;
z_sup = 302.99;
electric_height = 2 * 298.995;
dz = abs(z_sup-z_inf);

// helical cut
turns = [1, 3, 1];
pitch = [152.145/turns[0], 293.7/turns[1], 152.145/turns[2]];
cut_width = 0.2; // instead of 0.2
color = ["red", "blue", "red"];
echo(rint=rint, rext=rext, dz=dz, turns=turns, electric_height=electric_height, pitch=pitch);

all_display = true;
base_display = false; // cylinder with cooling slits
cut_display = false; // cut with cooling slits
tierods_display = false; // only tierods
coolingslits_display = false; // only coolingslits

// tierods
n_tierods = 32;
d_tierods = 8;
r_tierods = 301.72;

// coolingslits
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

// set cut width to 2 instead of 0.2 for test
module cut_section(shape_pts, r1, n, p, odd){
  if (odd){
    helix_extrude(shape_pts, 
      radius = r1, 
      levels = n, 
      level_dist = p,
      vt_dir = "SPI_UP",
      rt_dir = "CT_CLK"		
    );
  } else {
    helix_extrude(shape_pts, 
      radius = r1, 
      levels = n, 
      level_dist = p,
      vt_dir = "SPI_UP",
      rt_dir = "CLK"		
    );
  };
}

module cut(r1, r2, h, n, p, odd=true){    
    e = (r2 - r1);
    shape_pts = [
        [0,-h],
        [e, -h],
        [e, h],
        [0, h]
    ];

    z = 0;
    tz = 0;
    dz = [for(i = [0:len(n)-1]) n[i]*p[i]];
    echo(dz=dz);
    if (odd) {
      echo("odd helical cut");
    } else {
      echo("even helical cut");
    };

    for(i = [0:len(n)-1]){
      tz = [ for (a=0, b=dz[0]; a <= i; a= a+1, b=b+(dz[a]==undef?0:dz[a])) b];
      echo(section=i, z=z, tz=tz[i]-n[i]*p[i], n=n[i], p=p[i]);
      color(color[i]){
        //translate([0,0,tz[i]-n[i]*p[i]]){
          if (odd) {
              cut_section(shape_pts, r1, n[i], p[i], odd);
          } else {
              cut_section(shape_pts, r2, n[i], p[i], odd);
          };
	  //};
      };
    };
}

module tierod(r, r1, h){
    translate([r,0,0])
    color( "red" )
    {
        cylinder(h=h*1.2, r=r1, center=true, $fa=1.25);
    };
}

module tierods(n, r, r1, h){
    theta = 360/ n;
    echo("tierods:", theta=theta, n=n, r=r, r1=r1, h=h);
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
       cylinder(h=hc, r=d/2, center=true, $fa=1.25);
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


module magnet(){
  difference() {
    difference(){
        base(rint, rext, dz);
        translate([0,0,-electric_height/2]){
	  cut(rint*0.9, rext*1.1, cut_width, turns, pitch);
        };
    };

    if (tierods_display || all_display) {
        tierods(n_tierods, r_tierods, d_tierods/2, dz);
    };

    if (coolingslits_display || all_display) {
        // add cooling slits
        for (i = [0:len(r_slits)-1]){
	  rotate(a=shift_slits[i], v=[0,0,1]){coolingslits(n_slits, r_slits[i], d_slits, dz);};
        }
    };
  };
};

if (all_display){
    echo("display_all");
    magnet();
} else {
    if (cut_display){
        echo("intersection")
        difference(){
          intersection(){
	    base(rint, rext, dz);
	    translate([0,0,-electric_height/2]){
	      cut(rint*0.9, rext*1.1, cut_width, turns, pitch);
	    };
	  };

	  if (tierods_display) {
	    echo("cut_display with tierods");
	    tierods(n_tierods, r_tierods, d_tierods/2, dz);
          };

	  if (coolingslits_display) {
	    echo("cut_display with cooling_slits");
	    // add cooling slits
	    for (i = [0:len(r_slits)-1]){
	      rotate(a=shift_slits[i], v=[0,0,1]){coolingslits(n_slits, r_slits[i], d_slits, dz);};
	    }
	  };
        };
    };
    
    if (base_display) {
      echo("base_display");
      if (coolingslits_display) {
	echo("base_display with coolingslits")
        difference() {
          base(rint, rext, dz);
          for (i = [0:len(r_slits)-1]){
	    rotate(a=shift_slits[i], v=[0,0,1]){coolingslits(n_slits, r_slits[i], d_slits, dz);};
          }
        };
      } else {
	echo("base_display only")
        base(rint, rext, dz);
      };
    };
    
    if (tierods_display) {
      echo("tierods_display");
      color("red") tierods(n_tierods, r_tierods, d_tierods/2, dz);
    };
    
    if (coolingslits_display) {
        echo("tierods_display");
        for (i = [0:len(r_slits)-1]){
	       rotate(a=shift_slits[i], v=[0,0,1]){coolingslits(n_slits, r_slits[i], d_slits, dz);};
        }
    };
};

// next Open CGALlab, apply cap, apply tetra mesh, save as ascii
