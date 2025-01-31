save_base = false;

if (save_base){
    color("green") difference() {
        cube(size = [10,10,5], center = true);
        cylinder(h = 10, d=4, center=true, $fn=100);
    }
} else {

    color("red") translate([-2.5,-2.5,2.5]) cube(size = [5,5,15], center =false);
};
