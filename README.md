# 3D-TSV
The 3D Trajectory-based Stress Visualizer (3D-TSV), a visual analysis tool for the exploration 
of the principal stress directions in 3D solids under load.

This repository was created for the paper "The 3D Trajectory-based Stress Visualizer" 
	by Junpeng Wang, Christoph Neuhauser, Jun Wu, Xifeng Gao and Rüdiger Westermann, 
which was submitted to IEEE Transactions on Visualization and Computer Graphics, and also available in arXiv

# 1. Functionality
	---	Creating a space-filling and evenly spaced set of Principal Stress Lines (PSLs) in a 3D stress field with an automatic seeding strategy
	--- Providing a nested hierarchical PSL representation that is used to control focus and context via varying PSL density

# 2. Input
This program works with the stress field simulated by hexahedral mesh, which can be Carteisan mesh or unstructured mesh.
 
The input data set includes the external Cartesian stress field and its corresponding simulation mesh. 

The standard "vtk DataFile Version 3.0" is used for the unstructured mesh, and the Cartesian stress data and its corresponding 
boundary conditions are appended at the end of the mesh data. For the Cartesian mesh, we also borrow the file format ".vtk", 
but a different way is used there to describe the mesh in order to save the processing time in file IO. Detailed
implementation can be found in './src./ImportStressFields.m'.

# 3. Use
	---	The perfect strategy of using this tool is as the paper describes, i.e., combining it with the the 3D line cluster 
		renderer "LineVis" (https://github.com/chrismile/LineVis) by Christoph Neuhauser.
	--- To facilitate the initial tests of the users, this package can also be used solely, where 'TSV3D_script.m' serves as
		a configuration file to control the input, './src/DrawPSLs.m' provides the visualization options.

# 4. Run
Go to 'TSV3D_script.m'

# 5. Data sets
More stress field data sets can be found from https://syncandshare.lrz.de/getlink/fiPjBXgwXXvbky55uDQP39j7/stress%20fields
