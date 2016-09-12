# -*- coding:utf-8 -*-
'''
gif图片转换为 jpg
'''
from PIL import Image
import os
import os.path
dir = "E:\\testset2_gif"
for root, dirs, files in os.walk(dir):
    for name in files:
        tmpFile = root+"/"+name
        targetFile = root+"/"+name.split(".")[0]+".png"
        im = Image.open(tmpFile)
        im = im.convert('RGB')
        im.save(targetFile, "png")  # 保存图像为png格式
        print "picture transfer success!",tmpFile