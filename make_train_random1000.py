import random

import os
import os.path


simbol = ' '
#e.g e:/train/ --don't forget the last '/'
img_path = "E:/train/"

#path config
for class_num in range(0,12):
    dir = img_path +str(class_num)
    #do search
    for root, dirs, files in os.walk(dir):
        for name in files:
            file_with_suffix = root+"/"+name

    #shuffle the file's order
    random.shuffle(files)
    train_max_idx = int(files.__len__()*0.15)

    #make train set
    for idx in range(0,train_max_idx):
        #for generate labels file
        print '/'+str(class_num)+'/'+files[idx]+ simbol + str(class_num)
        #for generate testsets
        #print root+'/'+str(class_num)+'/'+files[idx]+ simbol + str(class_num)





