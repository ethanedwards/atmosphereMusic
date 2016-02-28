print_off()
load("IIR")
load("MBANDEDWG")
srand() /* srand with no seed will use system clock for seed */

ampPres = maketable("line", 1000, 0,0, 1,1, 4,1, 5,0)
wavePres = maketable("wave", 2000, 1)
fadeup = maketable("line", 1000, 0,0, 1, 1)
fadedown = maketable("line", 1000, 0,1, 1, 0)

melpitches = {7.00, 7.02, 7.05, 7.07, 7.10, 8.00, 8.07}