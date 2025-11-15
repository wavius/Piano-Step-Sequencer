import numpy as np

N = 256
A = 4095 / 2      

sine = (A * np.sin(2*np.pi*np.arange(N)/N) + A).astype(int)

with open(f"sine{N}.mif", "w") as f:
    f.write(f"WIDTH = 12;\n")
    f.write(f"DEPTH = {N};\n")
    f.write("ADDRESS_RADIX = UNS;\n")
    f.write("DATA_RADIX = DEC;\n")
    f.write("CONTENT BEGIN\n")

    for i, v in enumerate(sine):
        f.write(f"{i} : {v};\n")

    f.write("END;\n")

print(f"Generated sine{N}.mif with {N} samples.")