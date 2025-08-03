Dendrite
=====

# 基本信息

Fork "Dendrite" to create a new MOOSE-based application.

For more information see: [https://mooseframework.inl.gov/getting_started/new_users.html#create-an-app](https://mooseframework.inl.gov/getting_started/new_users.html#create-an-app)

在浙江大学洪子健老师的MOOSE模拟锂枝晶的开源代码基础上做修改，引用论文：
> ACS Energy Lett. 2018, 3, 7, 1737–1743

**输入文件在problems文件夹中，大部分的改动在这里。要使用该模型，需要安装MOOSE，新建名为dendrite的application，在problems文件夹中选择合适的输入文件，详情参考洪老师的![protocol论文](https://www.sciencedirect.com/science/article/pii/S2666166722005937?via%3Dihub)**

# original版本

论文支持文件中的源码

# solver-adjust版本

**洪老师的原模型，只做求解调试，公式不做修改**

更改：

更新MOOSE语法，添加自适应时间步长和网格格划分，调整求解器，增加模型收敛性

# enhenced_ani版本

**在solver-adjust版本基础上，修改公式，几何，网格，求解器等**

更改：

1. 将求解域裁剪一半，加密网格，初始值设置为半径为5的半圆。
2. 在原模型基础上，自由能系数由常数变成具备各向异性的参数ε^2
   > [!NOTE]
   > 增加各向异性理论上应该是增加二次枝晶的生成，但是结果没见到二次枝晶，收敛性却提高了，我也不知道原因。
4. 求解器改用ilu

该版本的平均时间步长是0.05s左右，比其他两个收敛效果都好一些，以下分别为使用该模型计算的35s内序变量，$ Li^+ $浓度场与电场分布图
![序变量](https://github.com/bdliangxy/dendrite/blob/main/problems/enhenced_ani/%E5%BA%8F%E5%8F%98%E9%87%8F.gif)
![浓度场](https://github.com/bdliangxy/dendrite/blob/main/problems/enhenced_ani/%E6%B5%93%E5%BA%A6.gif)
![电场](https://github.com/bdliangxy/dendrite/blob/main/problems/enhenced_ani/%E7%94%B5%E5%9C%BA.gif)

# 改进建议
本人时间精力有限，只有一台笔记本，这个模型的非线性程度比较高，求解一次花很久，以上gif是我算了一天一夜得到的。如果你有高算力服务器，调整起来比我更方便
以下提供一些建议
1. 模型大部公式使用的是parsed形式，这会导致运算较慢。一般来说运算速度上普通kernel>ADkernel>parsed公式，但是普通kernel要手动写雅可比矩阵，难度较高，容易出错。可以尝试将公式包装成ADkernel，可自动添加雅可比矩阵。
2. conduction和migration两个kernel本质上是相同的，可做删减，MOOSE内有类似的kernel名为heatconduction修改时可以参考。
3. 相场法对网格比较敏感，在算力允许下，尽量使用较细的网格，根据MOOSE官方相场法的界面中要包含4到5个网格，界面的计算公式为sqrt(8*kappa/W)，kappa为各向异性系数，W为势垒高度。
4. 参考资料中说使用jit时，可以优化parsed公式的编译效率，但实际该模型中开启jit后收敛性下降，所以求解时jit是关掉的，有懂的朋友可以研究一下。
