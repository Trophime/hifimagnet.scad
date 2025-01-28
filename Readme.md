# Pre-Requisites

* dotSCAD module:
** download and install
** update scad script to account for the correct dotSCAD path

see: https://github.com/JustinSDK/dotSCAD/releases

# `Hifimagnet OpenSCAD` scripts

This directory contains `openscad` script to generate CAD for Bitter.

To build Bitter STL in batch mode, use:

```
openscad M8_Be.scad --export-format binstl -o tutu.stl
openscad M8_Be.scad -o tutu.off
```

```
openscad -Dcoolingslits_display=true M8_Be.scad -o M8_Be-wo-tierods.off
openscad -Dtierods_display=true M8_Be.scad -o M8_Be-tierods.off
openscad -Dcut_display=true M8_Be.scad -o M8_Be-cut-5t.off
openscad -Dbase_display=true M8_Be.scad -o M8_Be-cut-5t.off
openscad -Dall_display=true M8_Be.scad -o M8_Be-5t.off
```

add -Dfillet=true to get fillets on "elongated" cooling slits
for "round" cooling slits see M9_Bi.scad

```
openscad H1.scad -o H1.off: le cylindre moins les decoupes
openscad -Dcut_display=true H1.scad -o H1cut.off: les decoupes pour H1
openscad -Dbase_display=true H1.scad -o H1base.off: le cylindre sans decoupe
openscad ring_H2H3.scad -o ring_H2H3.off: bague de connection entre H2 et H3
```

pour avoir une vue de l'insert:
```
openscad insert.scad [-o insert.off]
```

# Mesh with cgal

Use cgal (either 5.x or 6.x version)
- Start demo/Lab/CGALlab or demo/Polyhedron/Polyhedron_3
- load stl file
- check self-intersection using Statistics
- if self-intersection, remove caps, then save stl
- tetra mesh generation

# References

* `OpenSCAD`


# Mesh with cgal

Use cgal (either 5.x or 6.x version)
- Start demo/Lab/CGALlab or demo/Polyhedron/Polyhedron_3
- load stl file
- check self-intersection using Statistics
- if self-intersection, remove caps, then save stl
- tetra mesh generation

# References

* `OpenSCAD`
* `dotSCAD`
* `cgal`

# TIPS

rotate(a=180, v=[0,1,0]) { ... }
