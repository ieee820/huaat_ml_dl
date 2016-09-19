# -*- coding:utf-8 -*-
'''
gif图片转换为 jpg

'''
from PIL import Image
import os
import os.path
import argparse
import sys

def main(argv):
    parser = argparse.ArgumentParser()
    parser.add_argument(
    "dir",
    help="Input image, directory, or npy."
    )
    args = parser.parse_args()
    dir = args.dir
    #dir = "/data/bot_img/temp/gif_temp/"
    for root, dirs, files in os.walk(dir):
    	i = 0
    	for name in files:
            tmpFile = root+"/"+name
            if not tmpFile.endswith(".jpg"):
                im = Image.open(tmpFile)
                im = im.convert('RGB')
                newroot =root
                #newroot = newroot.replace("gif_temp", "gif_temp")
                targetFile = newroot + "/" + name.split(".")[0] + ".jpg"
                im.save(targetFile, "jpeg")  # 保存图像为png格式
                i = i+1
        if i%2==0:
            print("picture transfer %d"%i)


#main func
if __name__ == '__main__':
    main(sys.argv)
