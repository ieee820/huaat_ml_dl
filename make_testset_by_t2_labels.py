# -*- coding:utf-8 -*-


import os
import os.path


#path config
answer_file = 'E:/caffe/0917/sort01_t4_man_errors_train.txt'
dir =  "E:/train/testset4_nogif/"
root_dir = ''

#answer_file = '/data/bot_img/labels/t1_errors.txt'
#dir =  "/data/bot_img/img_0910/testset1_nogif/"
#root_dir = '/testset1_nogif/'

simbol = ' '

f = open(answer_file)
answer_dict = {}
for line in f:
    listedline = line.strip().split(' ')
    answer_dict[listedline[0]] = listedline[1]  #添加元素到dict
#print 'answer_class read ok'

#do copy
for root, dirs, files in os.walk(dir):
    for name in files:
        file_with_suffix = name
        file_no_suffix = name.split(".")[0]
        if file_no_suffix in answer_dict:
            print root_dir+file_with_suffix+simbol+answer_dict[file_no_suffix]
        #print tmpFile
