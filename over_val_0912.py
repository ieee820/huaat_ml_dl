import random

import os
import os.path

simbol = ' '

f_train = open("./train.txt", "wb")
f_test = open("./test.txt", "wb")
img_root = "E:/train/"
#img_root = "/data/bot_img/img_0910/"
#set train num and test num
train_num = 1000
test_num = 1000
#f_train.write("hello\n")
#f_train.close()
#fo.write( "www.runoob.com!\nVery good site!\n");

#path config
for class_num in range(0,12):
    dir = img_root+str(class_num)

    #do search
    for root, dirs, files in os.walk(dir):
        for name in files:
            file_with_suffix = root+"/"+name

    #shuffle the file's order
    random.shuffle(files)
    #train_max_idx = train_num
    #f_train.write("--train set--")
    #f_train.write(str(train_max_idx))
    #f_train.write('\n')
    #make train set
    for idx in range(0,train_num):
        line = '/'+str(class_num)+'/'+files[idx]+ simbol + str(class_num)
        f_train.writelines(line)
        f_train.write('\n')

    #make test set
    #f_test.write("--test set--")
    #f_test.write(str(train_max_idx))
    #f_test.write('\n')
    for idx in range(train_num,(train_num+test_num)):
        line = '/'+str(class_num)+'/'+files[idx]+ simbol + str(class_num)
        f_test.writelines(line)
        f_test.write('\n')

f_train.close()
f_test.close()


