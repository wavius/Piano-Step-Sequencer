import numpy as np
N = 256
A = 32767
sine = (A * np.sin(2 * np.pi * np.arange(N) / N)).astype(int)

with open("sine256.hex", "w") as f:
    for v in sine:
        if v < 0:
            v = (1 << 16) + v
        f.write(f"{v:04X}\n")  # write 4-digit uppercase hex