import numpy as np
import matplotlib.pyplot as plt
import argparse

from keras.datasets import mnist




#get cmd line args
parser = argparse.ArgumentParser()
# Required arguments: input and output files.
parser.add_argument("label",type=int)

args = parser.parse_args()
label = args.label

def save_2d(label):
    (X_train, y_train), (X_test, y_test) = mnist.load_data()
    l_z,l_x,l_y = X_train.shape
    #cubes = np.ndarray([10,28,28],dtype=np.uint8)
    #new_1 = np.random(28,28)
    new_all = np.ones(784)
    new_all.resize(28,28)
    j = 1
    for i in range(0, l_z):
        #print X_train[i,:,:],y_train[i]
        #if j >= 10:
            #break;
        new = X_train[i,:,:]
        if y_train[i] == label :
            new_all = np.concatenate((new_all,new),axis=0)
            j = j +1

    #reshape and save
    new_all.resize(j,28,28)
    new_mini = new_all[1:,:,:]

    np.save('/home/yangjj/minist_npy/'+str(label),new_mini)

def show_img_2d(new_mini):
    x,y,z = new_mini.shape
    for i in range(0, x):
        plt.imshow(new_mini[i], cmap='gray')
        plt.show()

def show_img_3d(new_mini):
    x,y,z = new_mini.shape
    for i in range(0, x):
        plt.imshow(new_mini[i], cmap='gray')
        plt.show()


#show_img(new_mini)

#save_2d(label)

def load_npy(label):
    load_file = np.load('/home/yangjj/minist_npy/'+str(label)+'.npy')
    #show_img(load_file)
    return load_file

def make_3d_npy(label,num_start,num_end):   #train num = 0:100 , test num = 100:120
    npy_2d_list = load_npy(label)
    npy_2d = npy_2d_list[num_start:num_end,:,:]
    npy_3d = npy_2d.reshape(-1,10,28,28)
    #npy_train = npy_3d.reshape(-1,10,1,28,28)
    print "label is %s--" % label,npy_3d.shape
    return npy_3d
    #show_img_3d(npy_3d)


def make_train_y():
    train_y = np.arange(100)
    k = 0
    for i in range(0,100,10):
        train_y[i:i+10] = k
        #print train_y
        k = k+1
    print train_y
    np.save('/home/yangjj/minist_npy/train_y.npy',train_y)


def make_test_y():
    test_y = np.arange(20)
    k = 0
    for i in range(0,20,2):
        test_y[i:i+2] = k
        #print train_y
        k = k+1
    print test_y
    np.save('/home/yangjj/minist_npy/test_y.npy',test_y)

def make_train_x():
    #create a head map 1*10*28*28
    head = np.ones(7840)
    head.resize(1,10,28,28)
    for i in range(0,10):
        if i == 0:
            train_x = np.concatenate((head,make_3d_npy(i,0,100)),axis=0)
        else:
            train_x = np.concatenate((train_x,make_3d_npy(i,0,100)),axis=0)
    #remove head
    train_x = train_x[1:]
    return train_x

def make_test_x():
    #create a head map 1*10*28*28
    head = np.ones(7840)
    head.resize(1,10,28,28)
    for i in range(0,10):
        if i == 0:
            test_x = np.concatenate((head,make_3d_npy(i,100,120)),axis=0)
        else:
            test_x = np.concatenate((test_x,make_3d_npy(i,100,120)),axis=0)
    #remove head
    test_x = test_x[1:]
    return test_x


#make_test_y()
#np.save('/home/yangjj/minist_npy/test_x.npy',make_test_x())

#np.save('/home/yangjj/minist_npy/train_x.npy',make_train_x())
#make_train_y()

def check_npy():
    test_x = np.load('/home/yangjj/minist_npy/train_x.npy')
    test_y = np.load('/home/yangjj/minist_npy/train_y.npy')
    for i in range(0,100,10):
        print test_y[i+1]
        show_img_3d(test_x[i+1])




check_npy()
#make_3d_npy(label)

#for i in range(0,10):
#    make_3d_npy(i)





