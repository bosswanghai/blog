# python绘图

### matplotlib
Matplotlib 可能是 Python 2D-绘图领域使用最广泛的套件，它提供了一整套和matlab相似的命令API，十分适合交互式地进行制图

### 使用

```

import matplotlib.pyplot as plt

plt.bar(left = 0,height = 1)
plt.plot([1,2,3,4])  # 划线函数
plt.ylabel('some numbers')    #为y轴加注释
plt.show()

```

划线函数Plot

```
plot()还可以接受x，y成对的参数，还有一个可选的参数是表示线的标记和颜色，plot函数默认画线是蓝色实线，即字符串'b-'，你可以选择自己喜欢的标记和颜色。

import matplotlib.pyplot as plt
plt.plot([1,2,3,4], [1,4,9,16], 'ro')
plt.axis([0, 6, 0, 20])
plt.show()

文／JasonDing（简书作者）
原文链接：http://www.jianshu.com/p/ee8bb1bd0019
著作权归作者所有，转载请联系作者获得授权，并标注“简书作者”。
```

## pygal

pygal is a dynamic SVG charting library written in python

### doc

[官方文档](http://www.pygal.org/en/stable/)

### 使用
```
import pygal                                                       # First import pygal
bar_chart = pygal.Bar()                                            # Then create a bar graph object
bar_chart.add('Fibonacci', [0, 1, 1, 2, 3, 5, 8, 13, 21, 34, 55])  # Add some values
bar_chart.render_to_file('bar_chart.svg')                          # Save the svg to a file

```
