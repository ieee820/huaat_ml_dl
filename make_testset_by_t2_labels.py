# -*- coding:utf-8 -*-


import os
import os.path


#path config
answer_file = 'E:/caffe/0912/t2_real_labels.csv'
dir =  "E:/train/testset2_nogif/"
simbol = ' '
root_dir = '/testset2_nogif/'

f = open(answer_file)
answer_dict = {}
for line in f:
    listedline = line.strip().split('\t')
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
