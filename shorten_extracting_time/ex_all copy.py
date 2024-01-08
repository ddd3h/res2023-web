import h5py
import os
import numpy as np
import LINE

LINE.notify("Start")

filenames_list = os.listdir("/home/nishihama/data/TNG50-1/output/snapdir_099/")
skip_num = [ int(_file.replace("snap_099.","").replace(".hdf5","")) for _file in filenames_list  ]
skip_num = []

basePath = "/home/nishihama/data/TNG50-1/output/snapdir_099/"
done =[]
skipped =[]

for i in skip_num:
    try:
        with h5py.File( basePath + f"snap_099.{i}.hdf5", "r") as f:
            x, y, z = np.array(f["PartType0"]["Coordinates"]).T
            vx, vy, vz = np.array(f["PartType0"]["Velocities"]).T
            m = np.array(f["PartType0"]["Masses"])
            
            np.savez(
                f"/home/nishihama/test_halo/AllOfData_CMVonly/CMVonly_099.{i}.npz",
                x=x,
                y=y,
                z=z,
                vx=vx,
                vy=vy,
                vz=vz,
                m=m,
            )
        print(f"Done     : {i}")
        done.append(i)
    except:
        print(f"Skipped  : {i}")
        skipped.append(i)

print("All Done!")
LINE.notify(f"All Done by anna\n\n skipped: {skipped}\n\n done: {done}")