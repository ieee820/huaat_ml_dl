import numpy as np
import dicom
import glob
from matplotlib import pyplot as plt
import os
import cv2
import mxnet as mx
import pandas as pd
from sklearn import cross_validation
import xgboost as xgb


def get_extractor():
    model = mx.model.FeedForward.load('model/resnet-50', 0, ctx=mx.gpu(1), numpy_batch_size=1)
    fea_symbol = model.symbol.get_internals()["flatten0_output"]
    feature_extractor = mx.model.FeedForward(ctx=mx.gpu(1), symbol=fea_symbol, numpy_batch_size=64,
                                             arg_params=model.arg_params, aux_params=model.aux_params,
                                             allow_extra_params=True)

    return feature_extractor


def get_3d_data(path):
    slices = [dicom.read_file(path + '/' + s) for s in os.listdir(path)]
    slices.sort(key=lambda x: int(x.InstanceNumber))
    return np.stack([s.pixel_array for s in slices])


def get_data_id(path):
    sample_image = get_3d_data(path)
    sample_image[sample_image == -2000] = 0
    # f, plots = plt.subplots(4, 5, sharex='col', sharey='row', figsize=(10, 8))

    batch = []
    cnt = 0
    dx = 40
    ds = 512
    for i in range(0, sample_image.shape[0] - 3, 3):
        tmp = []
        for j in range(3):
            img = sample_image[i + j]
            img = 255.0 / np.amax(img) * img
            img = cv2.equalizeHist(img.astype(np.uint8))
            img = img[dx: ds - dx, dx: ds - dx]
            img = cv2.resize(img, (224, 224))
            tmp.append(img)

        tmp = np.array(tmp)
        batch.append(np.array(tmp))

        # if cnt < 20:
        #     plots[cnt // 5, cnt % 5].axis('off')
        #     plots[cnt // 5, cnt % 5].imshow(np.swapaxes(tmp, 0, 2))
        # cnt += 1

    # plt.show()
    batch = np.array(batch)
    return batch


def calc_features():
    net = get_extractor()
    for folder in glob.glob('/data/lung2017/stage1/*'):
        print folder.split('/')[-1]
        batch = get_data_id(folder)
        feats = net.predict(batch)
        print(feats.shape)
        np.save('npy_result/'+folder.split('/')[-1], feats)


def train_xgboost():
    df = pd.read_csv('data/stage1_labels.csv')
    print(df.head())

    x = np.array([np.mean(np.load('npy_result/%s.npy' % str(id)), axis=0) for id in df['id'].tolist()])
    y = df['cancer'].as_matrix()

    trn_x, val_x, trn_y, val_y = cross_validation.train_test_split(x, y, random_state=42, stratify=y,
                                                                   test_size=0.20)

    clf = xgb.XGBRegressor(max_depth=10,
                           n_estimators=1500,
                           min_child_weight=9,
                           learning_rate=0.05,
                           nthread=8,
                           subsample=0.80,
                           colsample_bytree=0.80,
                           seed=4242)

    clf.fit(trn_x, trn_y, eval_set=[(val_x, val_y)], verbose=True, eval_metric='logloss', early_stopping_rounds=50)
    return clf


def make_submit():
    clf = train_xgboost()

    df = pd.read_csv('data/stage1_sample_submission.csv')

    x = np.array([np.mean(np.load('npy_result/%s.npy' % str(id)), axis=0) for id in df['id'].tolist()])

    pred = clf.predict(x)

    df['cancer'] = pred
    df.to_csv('subm1.csv', index=False)
    print(df.head())


if __name__ == '__main__':
    #calc_features()
    make_submit()
