import numpy as np
import sys
import time
#import logging
import caffe
import glob
import argparse
import os


def main(argv):
    #input e.g : python caffe_main_test_top2_scores.py ./test_dir/ ./0908.log
    #get argvs
    caffe_root = '/home/sjkxb/Downloads/tools/caffe-master/'
    model_path = '/data/bot_img/model_0919/'
    parser = argparse.ArgumentParser()
    # Required arguments: input and output files.
    parser.add_argument(
    "image_path",
    help="Input image, directory."
    )
    parser.add_argument(
    "model_name",
    help="model name e.g:snap_googlenet0920_iter_250000.caffemodel."
    )
    args = parser.parse_args()
    #set vars from argvs
    image_path = args.image_path
    model_name = args.model_name
    #program begin...
    #caffe.set_mode_cpu()
    caffe.set_device(0)  # if we have multiple GPUs, pick the first one
    caffe.set_mode_gpu()
    print 'caffe load.. ',caffe
    #model def
    model_def = model_path + 'googlenetdeploy.prototxt'
    model_weights = model_path + model_name
    #net created
    net = caffe.Net(model_def,model_weights,caffe.TEST)
    #images mean created
    mu = np.load(model_path + 'mean.0919.npy')
    mu = mu.mean(1).mean(1)
    print 'mean-subtracted values:', zip('BGR', mu)

    #prepare transformer obj
    transformer = caffe.io.Transformer({'data': net.blobs['data'].data.shape})
    transformer.set_transpose('data', (2,0,1))
    transformer.set_mean('data', mu)
    transformer.set_raw_scale('data', 255)
    transformer.set_channel_swap('data', (2,1,0))
    #apply to net
    net.blobs['data'].reshape(50,3,224,224)

    #read label file
    labels_file =  model_path + 'class_name.txt'
    labels = np.loadtxt(labels_file, str, delimiter='\t')


    #init logging

    #logging.basicConfig(filename = log_path,
    #                            filemode='a',
    #                            format='%(message)s',
    #                            datefmt='%H:%M:%S',
    #                            level=logging.DEBUG)
    #begin
    print time.asctime(time.localtime(time.time()))
    #predict images
    print 'img_path: '+ args.image_path
    img_list = glob.glob(args.image_path+'/*')
    for img in img_list:
        #print img
        image = caffe.io.load_image(img)
        transformed_image = transformer.preprocess('data', image)
        net.blobs['data'].data[...] = transformed_image
        output = net.forward()
        output_prob = output['prob'][0]
        top_inds = output_prob.argsort()[::-1][:2]
        #pdb.set_trace()
        #print img+'\t'+labels[top_inds[0]]+'\t'+str(round(output_prob[top_inds[0]],4))+'\t'+labels[top_inds[1]]+'\t'+str(round(output_prob[top_inds[1]],4))
        label01 = labels[top_inds[0]]
		label02 = labels[top_inds[1]]
        score1 = output_prob[top_inds[0]]
        score2 = output_prob[top_inds[1]]
        print "%s\t%s\t%.6f\t%s\t%.6f" % (img,label01,score1,label02,score2)
        #print img,'\t',aa
        #logging.info(img + '\t'+ labels[top_inds[0]] + '\t' + str(round(output_prob[top_inds[0]],3)) + '\t'+ labels[top_inds[1]] + '\t' + str(round(output_prob[top_inds[1]],3)))
    #end
    print time.asctime(time.localtime(time.time()))

#main func
if __name__ == '__main__':
    main(sys.argv)


