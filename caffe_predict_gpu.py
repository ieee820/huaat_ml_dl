import numpy as np
import sys
caffe_root = '/opt/caffe/'
import caffe
image_path = '/opt/cat/*'
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
import logging
logging.basicConfig(filename='/opt/caffe.log',
                            filemode='a',
                            format='%(message)s',
                            datefmt='%H:%M:%S',
                            level=logging.DEBUG)

#predict images
import glob
img_list = glob.glob(image_path)
for img in img_list:
	print img
	image = caffe.io.load_image(img)
	transformed_image = transformer.preprocess('data', image)
	net.blobs['data'].data[...] = transformed_image
	output = net.forward()
	output_prob = output['prob'][0]
	print 'output label:', labels[output_prob.argmax()],output_prob[output_prob.argmax()]
        logging.info(img + '\t'+ labels[output_prob.argmax()] + '\t' + str(round(output_prob[output_prob.argmax()],3)))
