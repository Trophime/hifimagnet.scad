module shape(v1=10, v2=5){
    difference(){
        sphere(d=v1, $fn=10);
        cylinder(d=v2, $fn=10, h=v1+1, center=True);
    }
}

shape();