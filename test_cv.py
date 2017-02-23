import cv2
import matplotlib.pyplot as plt
import numpy as np


def conv2(X, k):
    x_row, x_col = X.shape
    k_row, k_col = k.shape
    ret_row, ret_col = x_row - k_row + 1, x_col - k_col + 1
    ret = np.empty((ret_row, ret_col))
    for y in range(ret_row):
        for x in range(ret_col):
            sub = X[y : y + k_row, x : x + k_col]
            ret[y,x] = np.sum(sub * k)
    return ret

class ConvLayer:
    def __init__(self, in_channel, out_channel, kernel_size):
        self.w = np.random.randn(in_channel, out_channel, kernel_size, kernel_size)
        self.b = np.zeros((out_channel))
    def _relu(self, x):
        x[x < 0] = 0
        return x
    def forward(self, in_data):
        # assume the first index is channel index
        in_channel, in_row, in_col = in_data.shape
        out_channel, kernel_row, kernel_col = self.w.shape[1], self.w.shape[2], self.w.shape[3]
        self.top_val = np.zeros((out_channel, in_row - kernel_row + 1, in_col - kernel_col + 1))
        for j in range(out_channel):
            for i in range(in_channel):
                self.top_val[j] += conv2(in_data[i], self.w[i, j])
            self.top_val[j] += self.b[j]
            self.top_val[j] = self._relu(self.top_val[j])
        return self.top_val


mat = cv2.imread('E:/work_temp/201701/2017-01-18_110126.png',0)
row,col = mat.shape
in_data = mat.reshape(1,row,col)
in_data = in_data.astype(np.float) / 255
plt.imshow(in_data[0], cmap='Greys_r')
plt.show()



meanConv = ConvLayer(1,1,5)
meanConv.w[0,0] = np.ones((5,5)) / (5 * 5)
mean_out = meanConv.forward(in_data)
plt.imshow(mean_out[0], cmap='Greys_r')
plt.show()
