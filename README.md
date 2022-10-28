# Visual-Saliency-Detection
Detect the Salient parts of an image to the Human eye

The project is MATLAB implmentation of Itti Koch Saliency Model. References: https://ieeexplore.ieee.org/stamp/stamp.jsp?tp=&arnumber=730558. I have presented this as my Bachelors 2nd year work at IIT(ISM) Dhanbad.

Approach:
1. Segmnentation of the Image based on the color contrast and considering each block as a Super Pixel to reduce computation (SuperPixel.m).
2. Image intensity level histogram is computed and infrequent pixel are removed thus obtaining a reduced Image.
3. Converted rgb pixels to la*b*. As La*b* is more approximate towards human eye vision and all of the Textural Information is captured in L plane.
4. Calculate the color difference between points in L plane.
5. Saliency value of high frequent color.

Presentataion: https://docs.google.com/presentation/d/15s5B0sOiTLe2GEh4b-gLIpc4653LuCRS/edit?usp=sharing&ouid=110659274553340739177&rtpof=true&sd=true
