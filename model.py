# -*- coding:utf-8 -*-
'''
 the idea of this script came from LUNA2016 champion paper.
 This model conmposed of three network,namely Archi-1(size of 10x10x6),Archi-2(size of 30x30x10),Archi-3(size of 40x40x26)

'''
import tensorflow as tf
from data_prepare import get_train_batch
import tensorflow.python.debug as tf_debug
class model(object):

    keep_prob = 0.8
    #global batch_size =200
    def __init__(self):
        print(" network begin...")

    def archi_1(self):
        with tf.name_scope("Archi-1"):
            # input size is batch_sizex20x20x6
            keep_prob = tf.placeholder(tf.float32)
            learning_rate = 0.3

            x = tf.placeholder(tf.float32, [None,6, 20,20])
            x_image = tf.reshape(x, [-1, 6,20, 20,1])

            # 5x5x3 is the kernel size of conv1,1 is the input depth,64 is the number output channel
            w_conv1 = tf.Variable(tf.random_normal([3,5,5,1,64],stddev=0.001),dtype=tf.float32,name='w_conv1')
            b_conv1 = tf.Variable(tf.constant(0.01,shape=[64]),dtype=tf.float32,name='b_conv1')
            out_conv1 = tf.nn.relu(tf.add(tf.nn.conv3d(x_image,w_conv1,strides=[1,1,1,1,1],padding='VALID'),b_conv1))
            out_conv1 = tf.nn.dropout(out_conv1,keep_prob)

            out_conv1_shape = tf.shape(out_conv1)


            # max pooling ,pooling layer has no effect on the data size
            hidden_conv1 = tf.nn.max_pool3d(out_conv1,strides=[1,1,1,1,1],ksize=[1,1,1,1,1],padding='SAME')

            # after conv1 ,the output size is batch_sizex4x16x16x64([batch_size,in_deep,width,height,output_deep])
            w_conv2 = tf.Variable(tf.random_normal([3,5, 5, 64,64], stddev=0.001), dtype=tf.float32,name='w_conv2')
            b_conv2 = tf.Variable(tf.constant(0.01, shape=[64]), dtype=tf.float32, name='b_conv2')
            out_conv2 = tf.nn.relu(tf.add(tf.nn.conv3d(hidden_conv1, w_conv2, strides=[1, 1, 1,1, 1], padding='VALID'), b_conv2))
            out_conv2 = tf.nn.dropout(out_conv2, keep_prob)

            out_conv2_shape = tf.shape(out_conv2)



            # after conv2 ,the output size is batch_sizex2x12x12x64([batch_size,in_deep,width,height,output_deep])
            w_conv3 = tf.Variable(tf.random_normal([1,5, 5, 64,64], stddev=0.001), dtype=tf.float32,
                                  name='w_conv3')
            b_conv3 = tf.Variable(tf.constant(0.01, shape=[64]), dtype=tf.float32, name='b_conv3')
            out_conv3 = tf.nn.relu(
                tf.add(tf.nn.conv3d(out_conv2, w_conv3, strides=[1, 1, 1, 1,1], padding='VALID'),b_conv3))
            out_conv3 = tf.nn.dropout(out_conv3, keep_prob)

            out_conv3_shape = tf.shape(out_conv3)
            tf.summary.scalar('out_conv3_shape', out_conv3_shape[0])


            # after conv2 ,the output size is batch_sizex2x8x8x64([batch_size,in_deep,width,height,output_deep])
            # all feature map flatten to one dimension vector,this vector will be much long
            out_conv3 = tf.reshape(out_conv3,[-1,64*8*8*2])
            w_fc1 = tf.Variable(tf.random_normal([64*8*8*2,150],stddev=0.001),name='w_fc1')
            out_fc1 = tf.nn.relu(tf.add(tf.matmul(out_conv3,w_fc1),tf.constant(0.001,shape=[150])))
            out_fc1 = tf.nn.dropout(out_fc1,keep_prob)

            out_fc1_shape = tf.shape(out_fc1)
            tf.summary.scalar('out_fc1_shape', out_fc1_shape[0])


            w_fc2 = tf.Variable(tf.random_normal([150, 2], stddev=0.001), name='w_fc2')
            out_fc2 = tf.nn.relu(tf.add(tf.matmul(out_fc1, w_fc2), tf.constant(0.001, shape=[2])))
            out_fc2 = tf.nn.dropout(out_fc2, keep_prob)
            w_fc2_print = tf.Print(w_fc2,[out_fc2],"output of fc2")
            test_print = tf.reshape(w_fc2_print,[-1,2])

            out_fc2_shape =tf.shape(out_fc2)
            tf.summary.scalar('out_fc2_shape', out_fc2_shape[0])

            # softmax layer
            real_label = tf.placeholder(tf.float32, [None, 2])
            w_sm = tf.Variable(tf.random_normal([2,2],stddev=0.001),name='w_sm')
            b_sm = tf.constant(0.001,shape=[2])
            out_sm = tf.nn.softmax(tf.add(tf.matmul(out_fc2,w_sm),b_sm))
            #cross_entropy = tf.reduce_sum(tf.nn.softmax_cross_entropy_with_logits(out_sm, real_label))
            cross_entropy = -tf.reduce_sum(real_label*tf.log(out_sm))
            loss = tf.reduce_mean(cross_entropy)

            train_step = tf.train.MomentumOptimizer(learning_rate,0.9).minimize(loss)

            correct_prediction = tf.equal(tf.argmax(out_sm,1),tf.argmax(real_label,1))
            accruacy = tf.reduce_mean(tf.cast(correct_prediction,tf.float32))

            path = '/data/LUNA2016/cubic_normalization_npy'
            highest_acc = 0.0
            highest_iterator = 1
            batch_size = 32

            saver = tf.train.Saver()  # default to save all variable
            #with tf.InteractiveSession() as sess:

            #sess = tf_debug.LocalCLIDebugWrapperSession(sess)
            merged = tf.summary.merge_all()

            #config = tf.ConfigProto(allow_soft_placement=True)
            #sess = tf.InteractiveSession(config=config)
            with tf.Session() as sess:

                sess.run(tf.global_variables_initializer())
                train_writer = tf.summary.FileWriter('./tensorboard/', sess.graph)
                for i in range(40):
                    batch_data, batch_label = get_train_batch(path, i, batch_size, 10)
                    if len(batch_data)>0:
                        # tf.cast(batch_data,tf.float32)
                        # tf.cast(batch_label,tf.float32)
                        if i % 10 == 0:
                            acc_val = sess.run(accruacy, feed_dict={x: batch_data, real_label: batch_label,keep_prob:0.7})
                            saver.save(sess, './ckpt/archi-1.ckpt', global_step=i + 1)
                            if acc_val > highest_acc:
                                highest_acc = acc_val
                                highest_iterator = i
                            print('accuracy  is %f' % acc_val)
                        _,summary = sess.run([train_step,merged],feed_dict={x: batch_data, real_label: batch_label,keep_prob:0.7})
                         #= sess.run(,feed_dict={x: batch_data, real_label: batch_label,keep_prob:0.7})
                        print("training process..",i)
                        print("loss is ",loss)
                        train_writer.add_summary(summary,i)
            print("training finshed..highest accuracy is %f,the iterator is %d " % (highest_acc, highest_iterator))

if __name__=='__main__':
    model = model()
    model.archi_1()































