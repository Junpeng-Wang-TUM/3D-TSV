# 3D-TSV

The 3D Trajectory-based Stress Visualizer (3D-TSV), a visual analysis tool for the exploration of the principal stress
directions in 3D solids under load.

This repository was created for the paper:
@article{wang20223d,
  title={3D-TSV: The 3D trajectory-based stress visualizer},
  author={Wang, Junpeng and Neuhauser, Christoph and Wu, Jun and Gao, Xifeng and Westermann, R{\"u}diger},
  journal={Advances in Engineering Software},
  volume={170},
  pages={103144},
  year={2022},
  doi={10.1016/j.advengsoft.2022.103144},
  publisher={Elsevier}
}



## 1. Functionality

- Visualizing a stress tensor field simulated on a hexahedral mesh via trajectories;
- Creating a space-filling and evenly-spaced set of Principal Stress Lines (PSLs) in a 3D stress field with 
  an automatic seeding strategy, where, as many as possible intersections among different types of PSLs (major, medium, 
  and minor) are advocated;
- Providing a nested hierarchical PSL representation that is used to control focus and context via varying PSL density;


## 2. Input Format

This program works with stress fields simulated on hexahedral meshes, which can be Cartesian or unstructured meshes.
The input data set includes the external Cartesian stress field, corresponding simulation mesh, and the boundary
conditions (if necessary). 

### Note

In the input file, the stress tensor at each vertex is arranged in the following order.

```
<<Sigma_xx, Sigma_yy, Sigma_zz, Sigma_yz, Sigma_zx, Sigma_xy>>
```

Stress fields simulated on Cartesian meshes use input files with the extension `.carti`, where, instead of storing the
vertex coordinates and the element vertices explicitly, we only store the element indices of the Cartesian mesh, e.g.,
given a Cartesian mesh derived from volume data "V", only the non-empty voxels are stored via the MatLab built-in
function `find(V)`. Input files of stress fields simulated on unstructured hexahedral meshes use the extension
`.stress`. For details on the exact format, please refer to the input interface defined in
`./backend/ImportStressFields.m` and the exemplary associated data sets in `./data`.


## 3. How to Use

## 3.1 Frontend+Backend

Please run the command below to fetch the frontend submodule.

```sh
git submodule update --init --recursive
```

More information on how to compile and run the frontend can be found in `./frontend/README.md`.
Sample meshes for use with the frontend can be found in the folder `./data/`.

For Windows users, a pre-compiled version of the frontend is available here:
https://github.com/chrismile/LineVis/releases/tag/v2022-02-03

Under `frontend/Data/LineDataSets/mesh.json`, available simulation meshes can be specified.
For example, when using the sample meshes of 3D-TSV, the following file content can be specified:

```json
{
  "meshes": [
    { "name": "Cantilever", "filename": "../../../data/stress/ADES-2022/cantilever3D.carti" },
    { "name": "Kitten", "filename": "../../../data/stress/ADES-2022/kitten.stress" }
  ]
}
```

Additionally, the user can also open arbitrary simulation meshes (in `.carti` or `.stress` format) and
principal stress line (PSL) data sets using a file explorer via "File > Open Dataset..." (or using Ctrl+O).
`.carti` and `.stress` files will then be opened in the stress line tracing dialog.

When starting the frontend, please select "Stress Line Tracer" in the menu "File > Datasets" to open the line tracing
menu. When the 3D-TSV script `./apps/TSV3D_server.m` is running in the background, the frontend will then communicate
with the 3D-TSV backed over TCP/IP using ZeroMQ.

[![3D-TSV System Overview (Video)](https://img.youtube.com/vi/h7BzP7Jg_-o/maxresdefault.jpg)](https://youtu.be/h7BzP7Jg_-o)

## 3.2 Backend Only

To facilitate initial tests of the users, this package can also work in a MatLab-only environment, where
`./apps/TSV3D_script.m` serves as a configuration file to control the input and `./backend/DrawPSLs.m` provides the
visualization options. Besides the script `./apps/TSV3D_script.m`, we also provide a slim GUI `./apps/TSV3D_GUI.m`, 
which can enable the interaction between the user and 3D-TSV.

[![Guidelines for Using 3D-TSV Solely in MatLab (Video)](https://img.youtube.com/vi/99Jn938ZoVk/maxresdefault.jpg)](https://youtu.be/99Jn938ZoVk)

## 3.3 Frontend Only

The 3D-TSV frontend module can also work solely to render the PSL data generated by some external PSL seeding approach,
e.g., the existing evenly-spaced seeding. In this case, one just needs to export the PSL data under the required format
(see `./data/README-PSLdataFormat.txt`).

[![3D-TSV External PSL File Loading (Video)](https://img.youtube.com/vi/zafBOAt9Xvs/maxresdefault.jpg)](https://youtu.be/zafBOAt9Xvs)


## 4. Run

Go to directory `./apps` to select the application you want to use.

- `./apps/TSV3D_server.m` can be used in conjunction with `./frontend` to get the PSL tracing backend and a frontend
  with many different advanced visualization options.
- `./apps/TSV3D_script.m` and `./apps/TSV3D_GUI.m` can be used in a MatLab-only mode providing a slim frontend with a
  reduced feature set.


## 5. Data sets

More stress field data sets are provided on the following file share:
https://syncandshare.lrz.de/getlink/fi4W4EGjZSzMzCvxkEf9L3Aw/


## 6. Adaptation to Common FEA Tools

To facilitate the use of ANSYS and ABAQUS in conjunction with 3D-TSV, we briefly explore how to adapt the stress
simulation results by ANSYS or ABAQUS to 3D-TSV, i.e., how to extract the required information from the two software
packages and export it in the required format (`.stress`) for import in 3D-TSV.

## 6.1 ANSYS Mechanical APDL user

We provide a script written in APDL (`./backend/Ansys2TSV3D.mac`), which can automatically extract the required 
information from the ANSYS environment and write it into the required format for 3D-TSV.

[![3D-TSV Guidelines for ANSYS Mechanical APDL User (Video)](https://img.youtube.com/vi/Yri_B7m3AWU/maxresdefault.jpg)](https://youtu.be/Yri_B7m3AWU)
The corresponding stress data can be founded in the directory 'demo_data_Ansys (Please Unzip it).zip' 

## 6.2 ABAQUS user

We suggest a manual and slightly time-consuming way to export the data for 3D-TSV, where the mesh information can be
found from the input  file (`.inp`) of ABAQUS, and the stress data can be acquired from the result file (`.rpt`), which
the user also needs to output explicitly. The demo files can be founded in the directory './data/Abaqus2TSV (Please Unzip it).zip' 

NOTE: The stress tensor in ABAQUS is arranged in the order Sigma_xx, Sigma_yy, Sigma_zz, Sigma_xy, Sigma_xz, Sigma_yz
by default, which is slightly different to the required input format, so one needs to re-arrange the data order
beforehand.

## 6.3 PERMAS user (https://www.intes.de)

Similar to Item 6.2, the PERMAS user can also use "3D-TSV" for stress visualization once they extract the mesh and stress data from the PERMAS 
output files and adapt them into the required format by "3D-TSV". It's worth mentioning that the stress result is written in ".post" file by default,
the mesh data can be found from the normal data file (".dat"). One can reach the demo files in the directory './data/PERMAS2TSV (Please Unzip it).zip'

In case of huge finite element models the ".hdf" (see the attached demo file) format might be better because it's a binary format. 
PERMAS users might use the enhanced Python interpreter pyINTES to access those files via h5py. https://www.h5py.org/
Another possibility is to use https://vitables.org/ or https://www.hdfgroup.org/downloads/hdfview/

NOTE: In the input file ".stress", the Cartesian stress at each vertex is arranged in the order: 
<<Sigma_xx, Sigma_yy, Sigma_zz, Sigma_yz, Sigma_zx, Sigma_xy>>
