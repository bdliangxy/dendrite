Dendrite
=====

Fork "Dendrite" to create a new MOOSE-based application.

For more information see: [https://mooseframework.inl.gov/getting_started/new_users.html#create-an-app](https://mooseframework.inl.gov/getting_started/new_users.html#create-an-app)

在浙江大学洪子健老师的MOOSE模拟锂枝晶的开源代码基础上做修改，引用论文：
> ACS Energy Lett. 2018, 3, 7, 1737–1743

**输入文件在problems中，main表示洪老师的原模型，公式不做修改**

main中更新内容：更新MOOSE语法，添加自适应时间步长和网格格划分，调整求解器，增加模型收敛性
