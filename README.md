# 3D-TSV
The 3D Trajectory-based Stress Visualizer (3D-TSV), a visual analysis tool for the exploration 
of the principal stress directions in 3D solids under load.

This repository was created for the paper "The 3D Trajectory-based Stress Visualizer" 
	by Junpeng Wang, Christoph Neuhauser, Jun Wu, Xifeng Gao and Rüdiger Westermann, 
which was submitted to IEEE VIS 2021.

# 1. Functionality
Creating a space-filling and evenly spaced set of Principal Stress Lines (PSLs) in a 3D stress field with an automatic seeding strategy
Providing a nested hierarchical PSL representation that is used to controlfocus and context via varying PSL density

# 2. Data set
This program works with the stress field simulated by hexahedral mesh, which can be Carteisan mesh or unstructured mesh.
 
The input data set includes the external Cartesian stress field and its corresponding simulation mesh. 

The standard "vtk DataFile Version 3.0" is used for the unstructured mesh, and the Cartesian stress data and its corresponding 
boundary conditions are appended at the end of the mesh data. For the Cartesian mesh, we also borrow the file format ".vtk", 
but a different way is used there to describe the mesh, in order to save the processing time in file IO. Detailed
implementation can be found in '\src\ImportStressFields.m'.

The output data includes the PSL-related information and the stress field silhouette written in form of a quad mesh, which works
with the 3D line cluster renderer "" by Christoph Neuhauser.

More data sets can be found from https://syncandshare.lrz.de/getlink/fiF6ChRDyPyKhtw3aCgQU1aG/3D-TSV-Data

# 3. run
Go to 'TSV3D_script.m' or 'TSV3D_GUI.m'