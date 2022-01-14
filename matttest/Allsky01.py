import matplotlib.pyplot as plt
import numpy as np
from PIL import Image
from pidng.core import RPICAM2DNG
filename='20211209_135940985.jpg'
d=RPICAM2DNG()
d=d.convert(filename)
#
image = Image.open(filename)
#plt.imshow(image)
#plt.show()
#image.show()
image2=np.array(image)
d2=np.array(d)
print(image2.mean())
print(np.median(image2))
#plt.plot(image2[1000,:,2])
#plt.show()
print(image2.dtype)
print(image2.shape)
print(d2.dtype)
print(d2.shape)
image_green1 = Image.open('20211209_135940985_green1.png')
d_green1=np.array(image_green1)
print(d_green1.dtype)
print(d_green1.shape)
#plt.plot(d_green1[700,:])
#plt.show()
plt.imshow(d_green1)
plt.show()
