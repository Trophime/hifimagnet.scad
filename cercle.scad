use <dotSCAD/src/polyline_join.scad>

radius = 10;
thickness = 4;

points = [
    for(a = [0:360]) 
        radius * [cos(a), sin(a)]
];
polyline_join(points)
    circle(thickness / 2, $fn = 24);
