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
rint = 39;
rext = 46.3;
z_inf = -125;
z_sup = 125;
odd = false;
dble = true;
electric_height = 2 * 109;
dz = abs(z_sup-z_inf);

cut_display=false;
base_display = false;

// helical cut
turns = [12]; //[1, 1, 1];
pitch = [electric_height/turns[0]]; // 50.7133333333333*3, 24.475*12, 50.7133333333333*3];
cut_width = 0.2; // instead of 0.2
color = ["red"]; //["red", "blue", "red"];
echo(rint=rint, rext=rext, dz=dz, turns=turns, electric_height=electric_height, pitch=pitch);

module base(r1, r2, z1, z2){
  h = abs(z2-z1);
  h1 = abs(z2-z1) * 1.2;
  // true if z1 is negative, if positive shall be z1-h/2
  translate([0,0,z1+h/2]){
    difference(){
        cylinder(h=h, r=r2, center=true);
        cylinder(h=h1, r=r1, center=true);
    };
  };
}

// helical cut (width=h)
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
    
    // if odd, shape ok
    shape_pts = [
          [0, -h/2],
          [e, -h/2],
          [e,  h/2],
          [0,  h/2]
    ];
    echo(odd=odd, shape_pts=shape_pts);


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

module magnet(){
  difference(){
    difference(){
      base(rint, rext, z_inf, z_sup);
      translate([0,0,-electric_height/2]){
	cut(rint*0.9, rext*1.1, cut_width, turns, pitch, odd);
      };
      if ( dble ) {
	rotate(180, [0,0,1]) translate([0,0,-electric_height/2]){
	  cut(rint*0.9, rext*1.1, cut_width, turns, pitch, odd);
	};
      };
    };
  };
};

echo(cut_display=cut_display);
if (cut_display){
  echo("intersection")
    color("red") translate([0,0,-electric_height/2]){
	cut(rint*0.9, rext*1.1, cut_width, turns, pitch, odd);
      };
    
    if ( dble ) {
	color("green") rotate(180, [0,0,1]) translate([0,0,-electric_height/2]){
	    cut(rint*0.9, rext*1.1, cut_width, turns, pitch, odd);
	  };
	
    };
  
} else {
  if (base_display) {
      base(rint, rext, z_inf, z_sup);
  } else {
      magnet();
  };
};

// next Open CGALlab, apply cap, apply tetra mesh, save as ascii
