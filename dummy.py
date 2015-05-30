import time
from smooth import *
import matplotlib.pyplot as plt
import numpy

a=[100,100,100,120,120,120,140,140,140,500,500,500,900,900,900]
a=numpy.array(a)
v=smooth(a,window_len=3,window='flat')
print v
plt.plot(v)
plt.plot(a)

plt.pause(10)
exit()