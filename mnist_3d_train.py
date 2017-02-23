import numpy as np


from keras.utils import np_utils
from keras.models import Sequential
from keras.layers import Dense, Activation, Convolution2D, MaxPooling2D, Flatten
from keras.optimizers import Adam



X_train = np.load('/home/yangjj/minist_npy/train_x.npy')
X_test = np.load('/home/yangjj/minist_npy/test_x.npy')

X_train = X_train.reshape(-1,10, 1,28, 28)
X_test = X_test.reshape(-1,10, 1,28, 28)

print X_train.shape , X_test.shape







