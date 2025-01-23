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

# Mesh with cgal

Use cgal (either 5.x or 6.x version)
- Start CGALlab
- load stl file
- check self-intersection using Statistics
- if self-intersection, remove caps, then save stl
- tetra mesh generation

# References

* `OpenSCAD`
* `dotSCAD`
* `cgal`