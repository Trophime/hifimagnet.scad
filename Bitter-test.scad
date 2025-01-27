use <../../dotSCAD-3.3/src/helix_extrude.scad>

$fnt = 100;
$fa = 1;
$s = 0.4;

module base(h=700, r1=305, r2=401){
    h1 = h * 1.2;
    difference(){
        cylinder(h=h, r=r2, center=true);
        cylinder(h=h1, r=r1, center=true);
    }
}

// create helical cut with p: patch and n: turns
module cut(r1=305, r2=401, eps=0.2, n=10, p=69.0975){    
    e = (r2 - r1)*1.2;
    shape_pts = [
        [-1,-eps],
        [e, -eps],
        [e, eps],
        [-1, eps]
    ];
    
    helix_extrude(shape_pts, 
        radius = r1, 
        levels = n, 
        level_dist = p,
        vt_dir = "SPI_UP",
        $fnt=100
    );
}

module tierod(r=349.7, r1=4, h=700){
    translate([r,0,0])
    color( "red" )
    {
        cylinder(h=h*1.2, r=r1, center=true);
    };
}

module tierods(r=349.7, r1=4, h=700, n=36){
    theta = 360/n;
    for(i = [0:n-1]){
        rotate(a=i*theta, v=[0,0,1]){
	  tierod(r, r1, h);
        };
    }
}

module cslit(stlfile, r=104.3, h=700){
    dh = h / 2.;
    linear_extrude(height = h, center = true, convexity = 10, twist = 0) {
        translate([r, 0, -dh]){
            import(stlfile, convexity=3);
        }
    }
}

module rslit(r= 104.3, l=5.9, e=0.2, h=700){
    rslit = e/2;
    de = l/2;
    union(){
        translate([r, 0, 0]){cube([l,e,h],true);};
        translate([r, de, 0]){cylinder(r = r_slit, h=h, center=true);};
        translate([r, -de, 0]){cylinder(r = r_slit, h=h, center=true);};
    }
}

module rslits(r=319.25, l=2, e=0.2, h=700, n=144){
    theta = 360/ n;
    for(i = [0:n-1]){
        rotate(a=i*theta, v=[0,0,1]){
            tierod(r, r1, h);
        };
    }
}
module slits(r=319.25, r1=2, h=700, n=144){
    theta = 360/ n;
    for(i = [0:n-1]){
        rotate(a=i*theta, v=[0,0,1]){
            tierod(r, r1, h);
        };
    }
}

r1 = 305;
r2 = 401;
h = 800;
eps = 0.2;
half = 345.5;
turns = 2; // 75;
pitch = 2*half/turns; //9.213333333333333;
z0 = -half; //-turns*pitch/2; // -345.5;

rtierods = 4;
ntierods = 36;

rslits = 1.05;
nslits = 144;

// see yaml file for details on the geometry
alpha = 360/nslits/2;
//base(h, r1, r2);
translate([0,0,z0]){cut(r1=r1, r2=r2, eps=eps, n=turns, p=pitch);};
//tierods(r=349.7, r1=rtierods, h=h, n=ntierods);
//rotate(a=360/nslits/2,v=[0,0,1]){slits(319.25, r1=rslits, h=h, n=nslits);};
//slits(349.7, r1=rslits, h=h, n=nslits);
//rotate(a=360/nslits/2,v=[0,0,1]){slits(383.1, r1=rslits, h=h, n=nslits);};

/* difference(){ */
/*     difference(){ */
/*         difference(){ */
/*             difference(){ */
/*                 difference(){ */
/* 		  base(h, r1, r2); */
/*                     translate([0,0,z0]){cut(r1=r1, r2=r2, eps=eps, n=turns, p=pitch);}; */
/*                 }; */
/*                 tierods(r=349.7, r1=rtierods, h=h, n=ntierods); */
/*             }; */
/*             rotate(a=360/(nslits/2)/2,v=[0,0,1]){slits(319.25, r1=4*rslits, h=h, n=nslits/2);}; */
/*         }; */
/*         slits(349.7, r1=2*rslits, h=h, n=nslits/2); */
/*     }; */
/*     rotate(a=360/(nslits/4)/2,v=[0,0,1]){slits(383.7, r1=4*rslits, h=h, n=nslits/4);}; */
/* }; */
 
