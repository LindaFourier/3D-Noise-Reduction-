# 3D-Noise-Reduction-
3D Noise Reduction 
This is a 3DNR algorithm based on tracking

一个基于跟踪的3DNR

主要思路是运动块不是直接进行时域降噪，而是搜寻到上一帧的位置然后使用这个位置上的图像块来进行时域降噪

DR_3D_KCF为主体程序
DR_3D和DR_3D_3frame为简化版本，即直接时域降噪，运动块直接中值滤波

引用的跟踪算法为KCF：
Original KCF tracking framework:
"High-Speed Tracking with Kernelized Correlation Filters", TPAMI, 2015,
J. F. Henriques, R. Caseiro, P. Martins and J. Batista.
