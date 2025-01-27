use <dotSCAD/src/helix_extrude.scad>

// see data in M8_Be.yaml

module base(h=700, r1=305, r2=401){
  h1 = h * 1.2;
  difference(){
        cylinder(h=h, r=r2, center=true, $fnt=100);
        cylinder(h=h1, r=r1, center=true, $fnt=100);
  }
}

module cut(r1=305, r2=401, h=0.2, n=5, p=138.195){    
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
        vt_dir = "SPI_UP",
        $fnt=100
    );
}

module tierod(r=349.7, r1=5, h=700,n=32){
    translate([r,0,0])
    color( "red" )
    {
        cylinder(h=h*1.2, r=r1, center=true, $fnt=100);
    };
}

module tierods(n=32){
    theta = 360/ n;
    echo(theta);
    for(i = [0:n-1]){
        rotate(a=i*theta, v=[0,0,1]){
            tierod();
        };
    }
}

module coolingslits(r=319.25, r1=1.1, n=32){
    theta = 360/ n;
    echo(theta);
    for(i = [0:n-1]){
        rotate(a=i*theta, v=[0,0,1]){
	  tierod(r, r1);
        };
    }
}


//tierods();
//rotate(a=1.25, v=[0,0,1]){coolingslits(319.25, 1.1, 144);};
//rotate(a=0, v=[0,0,1]){coolingslits(349.7, 1.1, 144);};
//rotate(a=1.25, v=[0,0,1]){coolingslits(383.1, 1.1, 144);};

difference(){
    difference(){
        base();
        translate([0,0,-345.50]){
            cut();
        };
    };
    tierods();
};
 
