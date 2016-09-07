import numpy as np
import sys
import time
import logging
import caffe
import glob
import argparse
import os

def main(argv):
	#get argvs
	caffe_root = '/opt/caffe/'
	#image_path = '/opt/cat/*'
	#log_path = '/opt/out.log'
	parser = argparse.ArgumentParser()
        # Required arguments: input and output files.
        parser.add_argument(
        "image_path",
        help="Input image, directory, or npy."
        )
        parser.add_argument(
        "log_path",
        help="Output npy filename."
        )
    	args = parser.parse_args()
    	#set vars from argvs
    	image_path = args.image_path
    	log_path = args.log_path
    	#program begin...
	caffe.set_mode_cpu()
	print 'caffe load.. ',caffe
	#model def
	model_def = caffe_root + 'models/bvlc_reference_caffenet/deploy.prototxt'
	model_weights = caffe_root + 'models/bvlc_reference_caffenet/bvlc_reference_caffenet.caffemodel'
	#net created
	net = caffe.Net(model_def,model_weights,caffe.TEST)
	#images mean created
	mu = np.load(caffe_root + 'python/caffe/imagenet/ilsvrc_2012_mean.npy')
	mu = mu.mean(1).mean(1)
	print 'mean-subtracted values:', zip('BGR', mu)

	#prepare transformer obj
	transformer = caffe.io.Transformer({'data': net.blobs['data'].data.shape})
	transformer.set_transpose('data', (2,0,1))
	transformer.set_mean('data', mu)
	transformer.set_raw_scale('data', 255)
	transformer.set_channel_swap('data', (2,1,0))
	#apply to net
	net.blobs['data'].reshape(50,3,227,227)

	#read label file
	labels_file = caffe_root + 'data/ilsvrc12/synset_words.txt'
	labels = np.loadtxt(labels_file, str, delimiter='\t')


	#init logging

	logging.basicConfig(filename = log_path,
	                            filemode='a',
	                            format='%(message)s',
	                            datefmt='%H:%M:%S',
	                            level=logging.DEBUG)
	#begin
	logging.info(time.asctime(time.localtime(time.time())))
	#predict images
	print 'img_path: '+ args.image_path
	img_list = glob.glob(args.image_path+'/*')
	for img in img_list:
		print img
		image = caffe.io.load_image(img)
		transformed_image = transformer.preprocess('data', image)
		net.blobs['data'].data[...] = transformed_image
		output = net.forward()
		output_prob = output['prob'][0]
		print 'output label:', labels[output_prob.argmax()],output_prob[output_prob.argmax()]
	    	logging.info(img + '\t'+ labels[output_prob.argmax()] + '\t' + str(round(output_prob[output_prob.argmax()],3)))
	#end
	logging.info(time.asctime(time.localtime(time.time())))

#main func
if __name__ == '__main__':
    main(sys.argv)
