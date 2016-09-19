# -*- coding:utf-8 -*-
'''
gif图片转换为 jpg
'''
from PIL import Image
import os
import os.path
import glob
import argparse
import sys

#dir = "E:/train/testset4_gif/"

def main(argv):
	parser = argparse.ArgumentParser()
    parser.add_argument(
    "dir",
    help="Input image, directory, or npy."
    )
	args = parser.parse_args()
	dir = args.dir
	
	for root, dirs, files in os.walk(dir):
		for name in files:
			tmpFile = root+"/"+name
			targetFile = root+"/"+name.split(".")[0]+".png"
			im = Image.open(tmpFile)
			im = im.convert('RGB')
			im.save(targetFile, "png")
			print "picture transfer success!",tmpFile
		
#main func
if __name__ == '__main__':
    main(sys.argv)