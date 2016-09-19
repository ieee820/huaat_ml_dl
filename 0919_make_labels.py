# -*- coding:utf-8 -*-

#import numpy as np
import sys
#import time
#import os
#import os.path
import glob
import argparse
import os

def main(argv):
	#answer_file = '/data/bot_img/labels/t1_errors.txt'
	#dir =  "/data/bot_img/img_0910/testset1_nogif/"
	#root_dir = '/testset1_nogif/'

	simbol = ' '


    # Required arguments: input and output files.
	parser = argparse.ArgumentParser()
    parser.add_argument(
    "answer_file",
    help="Input image, directory, or npy."
    )
    parser.add_argument(
    "dir",
    help="Input image, directory, or npy."
    )
    args = parser.parse_args()
	answer_file = args.answer_file
    image_path = args.image_path
	root_dir = ''

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

		
		
#main func
if __name__ == '__main__':
    main(sys.argv)