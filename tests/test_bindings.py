import numpy as np
from intersections2d import Intersections2d

bo = Intersections2d()

# add your polylines
'''
                 2 C
                   |
                 1 D
0                  |                  5
A------------------o------------------B
                   |
                   |
                -2 E
'''
bo.add_polyline(np.array([[0.0, 0.0], [5.0, 0.0]]))               # AB
bo.add_polyline(np.array([[2.5, 2.0], [2.5, 1.0], [2.5, -2.0]]))  # CDE

# build index
bo.finish()

# query all line segment intersections
ret = bo.intersections()
# [
#    (array([2.5, 0. ]),
#     array([0.5       , 0.33333333]),
#     array([0, 0], dtype=int32),
#     array([1, 1], dtype=int32))
# ]
print(ret)
assert len(ret) == 1
for xy, ts, label1, label2 in ret:
    # xy 是交点，即图中的 o 点坐标
    # t,s 是分位点，(0.5, 0.33)
    #        0.5  ->   o 在 AB 1/2 处
    #        0.33 ->   o 在 DE 1/3 处
    # label1 是 line segment 索引，(polyline_index, point_index)
    #        e.g. (0, 0)，polyline AB 的第一段
    # label2 是另一个条 line seg 的索引
    #        e.g. (1, 1)，polyline CDE 的第二段（DE 段）
    print(xy)
    print(ts)
    print(label1)
    print(label2)
    assert np.all(xy == [2.5, 0])
    assert np.all(ts == [0.5, 1 / 3.0])
    assert np.all(label1 == [0, 0])
    assert np.all(label2 == [1, 1])

# query intersections against provided polyline
polyline = np.array([[-6.0, -1.0], [-5.0, 1.0], [5.0, -1.0]])
ret = bo.intersections(polyline)
ret = np.array(ret)   # 还是转化成 numpy 比较好用
xy = ret[:, 0]        # 直接取出所有交点
ts = ret[:, 1]        # 所有分位点
label1 = ret[:, 2]    # 所有 label1（当前 polyline 的 label）
label2 = ret[:, 3]    # tree 中 line segs 的 label
print(ret, xy, ts, label1, label2)
assert np.all(xy[0] == [0, 0])
assert np.all(xy[1] == [2.5, -0.5])
assert np.all(ts[0] == [0.5, 0])
assert np.all(ts[1] == [0.75, 0.5])
assert np.all(label1 == [[0, 1], [0, 1]])
assert np.all(label2 == [[0, 0], [1, 1]])

polyline2 = enus = np.column_stack((polyline, np.zeros(len(polyline))))
ret2 = np.array(bo.intersections(polyline2[:, :2]))
assert str(ret) == str(ret2)
