use <../../dotSCAD-3.3/src/helix_extrude.scad>

// see data in M8_Be.yaml

// control precision with fa, ...
// see https://en.wikibooks.org/wiki/OpenSCAD_User_Manual/Primitive_Solids
// cylinder:
// $fa : minimum angle (in degrees) of each fragment.
// $fs : minimum circumferential length of each fragment.
// $fn : fixed number of fragments in 360 degrees. Values of 3 or more override $fa and $fs

$fa = 1.25;
//$fs = 0.01; // min allowed value it seems
//$fn = 400;

// better to centralize data params here
odd = false;
rint = 305;
rext = 401;
z_inf = -348.5;
z_sup = 348.5;
electric_height = 2* 345.5;
dz = abs(z_sup-z_inf);

turns = [5]; // 75
pitch = [electric_height/turns[0]];
cut_width = 0.2; // instead of 0.2
color = ["red"]; 
echo(rint=rint, rext=rext, dz=dz, turns=turns, electric_height=electric_height, pitch=pitch);

all_display = false;
base_display = false; // cylinder with cooling slits
cut_display = false; // cut with cooling slits
tierods_display = false; // only tierods
coolingslits_display = false; // only coolingslits
fillet = true;

// tierods
n_tierods = 36;
d_tierods = 10;
r_tierods = 349.7;

// coolingslits (add optional fillets??)
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

module coolingslit(r, d, l, h, fillet=false){
  hc = h * 1.2;
  translate([r,0,0]){
    // add fillets option to speed up??
    if (fillet) {
      union(){
        translate([0,l/2,0]){cylinder(h=hc, r=d/2, center=true, $fn = 0, $fa = 1.25, $fs = 0.2);};
        cube([d, l, hc], center=true);
        translate([0,-l/2,0]){cylinder(h=hc, r=d/2, center=true, $fn = 0, $fa = 1.25, $fs = 0.2);};
      }
    } else {
      cube([d, l, hc], center=true);
    };
  }
}

module coolingslits(n, r, d, l, h, fillet=false){
    theta = 360/ n;
    echo("coolingslits:", theta=theta, r=r, d=d, l=l, h=h, fillet=fillet);
    for(i = [0:n-1]){
        rotate(a=i*theta, v=[0,0,1]){
	  coolingslit(r, d, l, h, fillet);
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
	  rotate(a=shift_slits[i], v=[0,0,1]){coolingslits(n_slits, r_slits[i], d_slits, l_slits, dz, fillet);};
        }
    };
  };
};

if (all_display){
  echo("display_all");
    magnet();
} else {
    if (cut_display){
      echo("cut_display");
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
	      rotate(a=shift_slits[i], v=[0,0,1]){coolingslits(n_slits, r_slits[i], d_slits, l_slits, dz, fillet);};
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
	    rotate(a=shift_slits[i], v=[0,0,1]){coolingslits(n_slits, r_slits[i], d_slits, l_slits, dz, fillet);};
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
      $fn = 100;
      for (i = [0:len(r_slits)-1]){
	rotate(a=shift_slits[i], v=[0,0,1]){coolingslits(n_slits, r_slits[i], d_slits, l_slits, dz, fillet);};
      }
    };
};

// next Open CGALlab, apply cap, apply tetra mesh, save as ascii
