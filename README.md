# 3D-TSV
The 3D Trajectory-based Stress Visualizer (3D-TSV), a visual analysis tool for the exploration 
of the principal stress directions in 3D solids under load.

This repository was created for the paper "3D-TSV: The 3D Trajectory-based Stress Visualizer" 
	by Junpeng Wang, Christoph Neuhauser, Jun Wu, Xifeng Gao and Rüdiger Westermann, 
which was submitted to the journal "Advances in Engineering Software", and also available in arXiv (2112.09202)

# 1. Functionality
	--- Visualizing the stress tensor field simulated on hexahedral mesh via trajectory;
	---	Creating a space-filling and evenly-spaced set of Principal Stress Lines (PSLs) in a 3D stress field with 
		an automatic seeding strategy, where, as many as intersections among different types of PSLs (major, medium, 
		and minor) are advocated;
	--- Providing a nested hierarchical PSL representation that is used to control focus and context via varying PSL density;

# 2. Input
This program works with the stress field simulated by hexahedral mesh, which can be Carteisan mesh or unstructured mesh. The 
input data set includes the external Cartesian stress field, corresponding simulation mesh, and the boundary conditions (if necessary). 

"========================================NOTE========================================"
In the input file, the stress tensor at each vertex is arranged in the order: 
	<<Sigma_xx, Sigma_yy, Sigma_zz, Sigma_yz, Sigma_zx, Sigma_xy>>
One needs to be CAREFUL while importing the external stress data into the 3D-TSV.

The input file of the stress field simulated on the Cartesian mesh is with the dedicated extension ".carti", the one on the 
unstructured hexahedral mesh is with the dedicated extension ".stress". For details, one is referred to go to the the 
associated data sets, and the input interface "./src./ImportStressFields.m".

# 3. Use
	---	The ideal strategy of using this tool is as the paper describes, i.e., combining it with the the 3D line cluster 
		renderer "LineVis" (https://github.com/chrismile/LineVis) by Christoph Neuhauser.
	--- To facilitate the initial tests of the users, this package can work in MatLab environment solely, 
		where 'TSV3D_script.m' serves as a configuration file to control the input, './src/DrawPSLs.m' provides 
		the visualization options. Besides the script 'TSV3D_script.m', we also provide a slim GUI "TSV3D_GUI.m", which can
		enable the interaction between the user and 3D-TSV.

# 4. Run
Go to 'TSV3D_script.m' or 'TSV3D_script.m'

# 5. Data sets
More stress field data sets can be found from	https://syncandshare.lrz.de/getlink/fi4W4EGjZSzMzCvxkEf9L3Aw/
	
# 6. Adaptation to Common FEA Tools
To facilitate the users of ANSYS and ABAQUS, we briefly explore how to adapt the stress simulation results by ANSYS or ABAQUS 
to our 3D-TSV, i.e., how to extract the required information from the two software and write it into the dedicated 
format (.stress) for running 3D-TSV.
# 6.1 ANSYS Mechanical APDL user
We provide a script written by APDL ("./src/Ansys2TSV3D.mac"), which can automatically extract the required 
information from ANSYS environment and write it into the required format for 3D-TSV.
# 6.2 ABAQUS user
We suggest a manual and slightly troublesome way to do so, where the mesh information can be found from the input 
file (".inp") of ABAQUS, and the stress data can be acquired from the result file (".prt"), which also needs the user 
to output on purpose. 
(NOTE: the stress tensor in ABAQUS is arranged in the order Sigma_xx, Sigma_yy, Sigma_zz, Sigma_xy, Sigma_xz, Sigma_zy by default,
which is slightly different to the required input format, one needs to re-arrange it.)
