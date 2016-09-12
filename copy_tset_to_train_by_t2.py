# -*- coding:utf-8 -*-


import os
import os.path
import numpy as np

#path config
#answer_file = 'E:/caffe/0912/t2_real_labels.csv'
#dir = "E:/train/testset2_nogif"
#train_img_path = 'E:/train/'
answer_file = '/data/bot_img/t2_real_labels.csv'
dir = "/data/bot_img/train/testset2_nogif/"
train_img_path = '/data/bot_img/train/'

f = open(answer_file)
answer_dict = {}
for line in f:
    listedline = line.strip().split('\t')
    answer_dict[listedline[0]] = listedline[1]  #添加元素到dict
#print 'answer_class read ok'

#do copy
for root, dirs, files in os.walk(dir):
    for name in files:
        file_with_suffix = root+"/"+name
        file_no_suffix = name.split(".")[0]
        if file_no_suffix in answer_dict:
            print 'cp',file_with_suffix,train_img_path+answer_dict[file_no_suffix]+'/'
        #print tmpFile
