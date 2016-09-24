import mxnet as mx
import numpy as np
from skimage import io,transform
import glob
import argparse
import os



#prefix = './save/save'
#epoch = 5

parser = argparse.ArgumentParser()
# Required arguments: input and output files.
parser.add_argument(
"--prefix",
help="model path"
)
parser.add_argument(
"--epoch",type=int,
help="model epoch e.g:"
)
parser.add_argument(
"--path",
help="image path."
)
args = parser.parse_args()
#load model
model = mx.model.FeedForward.load(args.prefix,args.epoch,ctx=mx.gpu(),numpy_batch_size=1)
synset = [l.strip() for l in open('class_name.txt').readlines()]
mean_img = mx.nd.load('mean.bin').values()[0].asnumpy()

img_list = glob.glob(args.path+'/*')
for test_img in img_list:
	img = io.imread(test_img)
	img_ori = io.imread(test_img)
	#handel the spec img with 4 color channels
	if img_ori[0,0].size == 4:
	    img = img_ori[:,:,:-1]
	else:
	    img = img_ori
	short_edge = min(img.shape[:2])
	yy = int((img.shape[0] - short_edge)/2)
	xx = int((img.shape[1] - short_edge)/2)
	crop_img = img[yy:yy + short_edge,xx:xx + short_edge]
	resized_img = transform.resize(crop_img,(299,299))
	sample = np.asarray(resized_img)*256
	sample = np.swapaxes(sample,0,2)
	sample = np.swapaxes(sample,1,2)
	normed_img = sample - mean_img
	normed_img.resize(1,3,299,299)

	batch = normed_img
	prob = model.predict(batch)[0]
	pred = np.argsort(prob)[::-1][:2]

	top1 = pred[0]
	top2 = pred[1]
	#print(test_img," Top1: ", synset[top1],prob[top1])
	#print "%s\t%s\t%.6f\t%s\t%.6f" % (img,label01,score1,label02,score2)
	print "%s\t%s\t%.6f\t%s\t%.6f" % (test_img,synset[top1],prob[top1],synset[top2],prob[top2])

