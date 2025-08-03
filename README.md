Dendrite
=====

# 基本信息

Fork "Dendrite" to create a new MOOSE-based application.

For more information see: [https://mooseframework.inl.gov/getting_started/new_users.html#create-an-app](https://mooseframework.inl.gov/getting_started/new_users.html#create-an-app)

在浙江大学洪子健老师的MOOSE模拟锂枝晶的开源代码基础上做修改，引用论文：
> ACS Energy Lett. 2018, 3, 7, 1737–1743

**输入文件在problems文件夹中，大部分的改动在这里**

# original版本

论文支持文件中的源码

# solver-adjust版本

**洪老师的原模型，只做求解调试，公式不做修改**

更改：更新MOOSE语法，添加自适应时间步长和网格格划分，调整求解器，增加模型收敛性

# enhenced_ani版本

**在solver-adjust版本基础上，修改公式，几何，网格，求解器等**

更改：将求解域裁剪一半，加密网格，初始值设置为半径为5的半圆。

在原模型基础上，自由能系数由常数$ kappa $变成具备各向异性的$ epsilon^2 $

求解器改用ilu

该版本的平均时间步长是0.05s左右，比其他两个收敛效果都好一些，以下分别为使用该模型计算的序变量，$ Li^+ $浓度场与电场分布图
![序变量](https://github.com/bdliangxy/dendrite/blob/main/problems/enhenced_ani/%E5%BA%8F%E5%8F%98%E9%87%8F.gif)
![浓度场](https://github.com/bdliangxy/dendrite/blob/main/problems/enhenced_ani/%E6%B5%93%E5%BA%A6.gif)
![电场](https://github.com/bdliangxy/dendrite/blob/main/problems/enhenced_ani/%E7%94%B5%E5%9C%BA.gif)


