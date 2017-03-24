#import shapes_3d
import numpy as np
#from keras.preprocessing.image import ImageDataGenerator
from keras.models import Sequential
from keras.layers.core import Dense, Dropout, Activation, Flatten
from keras.layers.convolutional import Convolution3D, MaxPooling3D
from keras.optimizers import SGD, RMSprop
from keras.utils import np_utils, generic_utils
from keras.callbacks import ModelCheckpoint
from keras.callbacks import TensorBoard
from keras.models import model_from_json
import luna16_config




def make_predict_datasets():
    list_x_train = []
    #read pos npys
    filepath = luna16_config.positive_txt
    with open(filepath) as f:
        lines = f.read().splitlines()
        #append x_train
        for line in lines:
            temp_npy = np.load(luna16_config.positive_dir + line)
            list_x_train.append(temp_npy)
            #list_y_train.append(label)
    return np.array(list_x_train)

def predict_by_one(cube):
    # load json and create model
    json_file = open('model.json', 'r')
    loaded_model_json = json_file.read()
    json_file.close()
    loaded_model = model_from_json(loaded_model_json)
    # load weights into new model
    loaded_model.load_weights("model.hdf5")
    print("Loaded model from disk")
    sgd = SGD(lr=0.01, decay=1e-6, momentum=0.9, nesterov=True)
    loaded_model.compile(loss='categorical_crossentropy', optimizer=sgd,metrics=['accuracy'])
    x = cube.reshape(-1,1,6,20,20)
    print(x.shape)
    result = loaded_model.predict(x,batch_size=10, verbose=0)
    # print(result.shape)
    # show result
    for i in result:
        print(i[0],i[1])
    return result

if __name__ == '__main__':
    # load json and create model
    json_file = open('model.json', 'r')
    loaded_model_json = json_file.read()
    json_file.close()
    loaded_model = model_from_json(loaded_model_json)
    # load weights into new model
    loaded_model.load_weights("model.hdf5")
    print("Loaded model from disk")
    sgd = SGD(lr=0.01, decay=1e-6, momentum=0.9, nesterov=True)
    loaded_model.compile(loss='categorical_crossentropy', optimizer=sgd,metrics=['accuracy'])
    predict_datasets = make_predict_datasets()
    x = predict_datasets.reshape(-1,1,6,20,20)
    print(x.shape)
    result = loaded_model.predict(x,batch_size=10, verbose=0)
    # print(result.shape)
    # show result
    for i in result:
        print(i[0],i[1])

