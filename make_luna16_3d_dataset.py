__author__ = 'yangjj'

import matplotlib.pyplot as plt

import numpy as np
from random import shuffle

positive_dir = 'E:/work_temp/luna16_output/positive/20mm/'
negative_dir = 'E:/work_temp/luna16_output/negative/20mm/'
positive_txt = 'positive_list.txt'
negative_txt = 'negative_list.txt'

def load_x_train():
    list_x_train = []
    list_y_train = []
    #read pos npys
    label = 1
    filepath = positive_txt
    with open(filepath) as f:
        lines = f.read().splitlines()
        #append x_train
        for line in lines:
            temp_npy = np.load(positive_dir + line)
            list_x_train.append(temp_npy)
            list_y_train.append(label)

    #read neg npys
    label = 0
    filepath = negative_txt
    with open(filepath) as f:
        lines = f.read().splitlines()
        #append x_train
        for line in lines:
            temp_npy = np.load(negative_dir + line)
            list_x_train.append(temp_npy)
            list_y_train.append(label)

    return list_x_train,list_y_train

def shuffle_dataset(list_x_train,list_y_train):
     #do shuffle
    shuf_x_train = []
    shuf_y_train = []
    index_shuf = range(len(list_y_train))
    shuffle(index_shuf)
    for i in index_shuf:
      shuf_x_train.append(list_x_train[i])
      shuf_y_train.append(list_y_train[i])

    return shuf_x_train,shuf_y_train

def plot_cube_loop(npy_file):
    cubic_array = npy_file
    f = plt.figure(figsize=(10,10))
    for i in np.arange(6):
        sp = f.add_subplot(4,5,i+1)
        sp.imshow(cubic_array[i,:,:],cmap='gray')
    plt.show()


def make_train_test(all_x,all_y,trainset_ratio):
    threshold = int(all_y.shape[0]*trainset_ratio)
    train_x = all_x[0:threshold,:,:,:]
    train_y = all_y[0:threshold]
    test_x = all_x[threshold:-1,:,:,:]
    test_y = all_y[threshold:-1]
    return train_x,train_y,test_x,test_y

if __name__ == '__main__':
    # list_x_all,list_y_all = load_x_train()
    # shuf_x_all,shuf_y_all = shuffle_dataset(list_x_all,list_y_all)
    # x_all = np.array(shuf_x_all)
    # y_all = np.array(shuf_y_all)
    x_all = np.load('shuf_x_all.npy')
    y_all = np.load('shuf_y_all.npy')
    train_x,train_y,test_x,test_y = make_train_test(x_all,y_all,0.8)
    np.save('train_x',train_x)
    np.save('train_y',train_y)
    np.save('test_x',test_x)
    np.save('test_y',test_y)

    # plot_cube_loop(x_all[14])
    # print y_all[14]
    # np.save('shuf_x_all',x_all)
    # np.save('shuf_y_all',y_all)
