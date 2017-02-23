import numpy as np
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d import Axes3D

x = np.linspace(-10,10,100)
y = np.linspace(-10,10,100)
X, Y = np.meshgrid(x,y)
X_f = X.flatten()
Y_f = Y.flatten()
data = zip(X_f, Y_f)

def draw3D(X, Y, Z, angle):
    fig = plt.figure(figsize=(15,7))
    ax = Axes3D(fig)
    ax.view_init(angle[0], angle[1])
    ax.plot_surface(X,Y,Z,rstride=1, cstride=1, cmap='rainbow')
    plt.imshow

class FC:
    def __init__(self, in_num, out_num, lr = 0.01):
        self._in_num = in_num
        self._out_num = out_num
        self.w = np.random.randn(out_num, in_num) * 10
        self.b = np.zeros(out_num)
        self.lr = lr
    def _sigmoid(self, in_data):
        return 1 / (1 + np.exp(-in_data))
    def forward(self, in_data):
        self.topVal = self._sigmoid(np.dot(self.w, in_data) + self.b)
        self.bottomVal = in_data
        return self.topVal

sigmoid = 1 / (1 + np.exp(-x))
plt.plot(x,sigmoid)
plt.imshow
plt.show()


tanh = (np.exp(x) - np.exp(-x)) / (np.exp(x) + np.exp(-x))
plt.plot(x,tanh)
plt.imshow

fc = FC(2, 10)
fc2 = FC(10, 20)
fc3 = FC(20, 40)
fc4 = FC(40, 80)
fc5 = FC(80, 1)

Z1 = np.array([fc.forward(d) for d in data])
Z2 = np.array([fc2.forward(d) for d in Z1])
Z3 = np.array([fc3.forward(d) for d in Z2])
Z4 = np.array([fc4.forward(d) for d in Z3])
Z5 = np.array([fc5.forward(d) for d in Z4])
Z5 = Z5.reshape((100,100))

draw3D(X, Y, Z5,(75,80))