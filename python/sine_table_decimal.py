import numpy as np
N = 256
A = 32767
sine = (A * np.sin(2 * np.pi * np.arange(N) / N)).astype(int)

with open("sine256.mif" , "w") as f:
    f.write("WIDTH = 16;\nDEPTH = 256;\nADDRESS_RADIX = UNS;\nDATA_RADIX = DEC;\nCONTENT BEGIN\n")
    for i, v in enumerate(sine):
        if v < 0: v = (1<<16) + v
        f.write(f"{i} : {v};\n")
    f.write("END;\n")