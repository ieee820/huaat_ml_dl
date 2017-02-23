# -*- coding:utf-8 -*-
'''
 LUNA2016 data prepare
'''

import SimpleITK as sitk
import numpy as np
import csv
from glob import glob
import pandas as pd
import os
import matplotlib
import matplotlib.pyplot as plt
import traceback


def get_filename(file_list, case):
    for f in file_list:
        if case in f:
            return(f)

def extract_cubic_from_mhd(dcim_path,annatation_file,plot_output_path,normalization_output_path):
    '''
      @param: dcim_path :                 the path contains all mhd file
      @param: annatation_file:            the annatation csv file,contains every nodules' coordinate
      @param: plot_output_path:           the save path of extracted cubic of size 20x20x6,30x30x10,40x40x26 npy file(plot ),every nodule end up withs three size
      @param:normalization_output_path:   the save path of extracted cubic of size 20x20x6,30x30x10,40x40x26 npy file(after normalization)
    '''
    file_list=glob(dcim_path+"*.mhd")
    # The locations of the nodes
    df_node = pd.read_csv(annatation_file)
    df_node["file"] = df_node["seriesuid"].map(lambda file_name: get_filename(file_list, file_name))
    df_node = df_node.dropna()

    for img_file in file_list:
        mini_df = df_node[df_node["file"]==img_file] #get all nodules associate with file
        file_name = str(img_file).split("/")[-1]
        if mini_df.shape[0]>0: # some files may not have a nodule--skipping those
            # load the data once
            itk_img = sitk.ReadImage(img_file)
            img_array = sitk.GetArrayFromImage(itk_img) # indexes are z,y,x (notice the ordering)
            num_z, height, width = img_array.shape        #heightXwidth constitute the transverse plane
            origin = np.array(itk_img.GetOrigin())      # x,y,z  Origin in world coordinates (mm)
            spacing = np.array(itk_img.GetSpacing())    # spacing of voxels in world coor. (mm)
            # go through all nodes
            print("begin to process nodules...")
            img_array = img_array.transpose(2,1,0)      # take care on the sequence of axis of v_center ,transfer to x,y,z
            print(img_array.shape)
            for node_idx, cur_row in mini_df.iterrows():
                node_x = cur_row["coordX"]
                node_y = cur_row["coordY"]
                node_z = cur_row["coordZ"]
                nodule_pos_str = str(node_x)+"_"+str(node_y)+"_"+str(node_z)
                # every nodules saved into size of 20x20x6,30x30x10,40x40x26
                imgs1 = np.ndarray([20,20,6],dtype=np.float32)
                imgs2 = np.ndarray([30,30,10],dtype=np.float32)
                imgs3 = np.ndarray([40,40,26],dtype=np.float32)
                center = np.array([node_x, node_y, node_z])   # nodule center
                v_center = np.rint((center-origin)/spacing)  # nodule center in voxel space (still x,y,z ordering)

                # false nodule
                imgs_fake1 = np.ndarray([20,20,6],dtype=np.float32)
                imgs_fake2 = np.ndarray([30,30,10],dtype=np.float32)
                imgs_fake3 = np.ndarray([40,40,26],dtype=np.float32)
                fake_center=[0,0,0]
                fake_center[0] = np.random.randint(20,img_array.shape[0]-20)
                fake_center[1] = np.random.randint(20, img_array.shape[1]-20)
                fake_center[2] = np.random.randint(13, img_array.shape[2]-13)
                print(v_center[0],v_center[1],v_center[2])

                try:
                    # these following imgs saves for plot
                    imgs1[:,:,:]=img_array[int(v_center[0]-10):int(v_center[0]+10),int(v_center[1]-10):int(v_center[1]+10),int(v_center[2]-3):int(v_center[2]+3)]
                    imgs2[:,:,:]=img_array[int(v_center[0]-15):int(v_center[0]+15),int(v_center[1]-15):int(v_center[1]+15),int(v_center[2]-5):int(v_center[2]+5)]
                    imgs3[:,:,:]=img_array[int(v_center[0]-20):int(v_center[0]+20),int(v_center[1]-20):int(v_center[1]+20),int(v_center[2]-13):int(v_center[2]+13)]
                    np.save(os.path.join(plot_output_path,"images_%s_%d_pos%s_size10x10.npy" % (str(file_name), node_idx,nodule_pos_str)),imgs1)
                    np.save(os.path.join(plot_output_path,"images_%s_%d_pos%s_size20x20.npy" % (str(file_name), node_idx,nodule_pos_str)),imgs2)
                    np.save(os.path.join(plot_output_path,"images_%s_%d_pos%s_size40x40.npy" % (str(file_name), node_idx,nodule_pos_str)),imgs3)
                    print("nodules %s from image %s extracted finished!..."%(node_idx,str(file_name)))

                    # these following are the standard data as input of CNN
                    truncate_hu(imgs1)
                    truncate_hu(imgs2)
                    truncate_hu(imgs3)
                    normalazation(imgs1)
                    normalazation(imgs2)
                    normalazation(imgs3)
                    np.save(os.path.join(normalization_output_path, "%d_real_size10x10.npy" % node_idx),imgs1)
                    np.save(os.path.join(normalization_output_path, "%d_real_size20x20.npy" % node_idx),imgs2)
                    np.save(os.path.join(normalization_output_path, "%d_real_size40x40.npy" % node_idx),imgs3)
                    print("normalization finished!..." )

                    # save fake nodule
                    imgs_fake1[:, :, :] = img_array[int(fake_center[0] - 10):int(fake_center[0] + 10),
                                     int(fake_center[1] - 10):int(fake_center[1] + 10),
                                     int(fake_center[2] - 3):int(fake_center[2] + 3)]
                    imgs_fake2[:, :, :] = img_array[int(fake_center[0] - 15):int(fake_center[0] + 15),
                                     int(fake_center[1] - 15):int(fake_center[1] + 15),
                                     int(fake_center[2] - 5):int(fake_center[2] + 5)]
                    imgs_fake3[:, :, :] = img_array[int(fake_center[0] - 20):int(fake_center[0] + 20),
                                     int(fake_center[1] - 20):int(fake_center[1] + 20),
                                     int(fake_center[2] - 13):int(fake_center[2] + 13)]
                    truncate_hu(imgs_fake1)
                    truncate_hu(imgs_fake2)
                    truncate_hu(imgs_fake3)
                    normalazation(imgs_fake1)
                    normalazation(imgs_fake2)
                    normalazation(imgs_fake3)
                    np.save(os.path.join(normalization_output_path, "%d_fake_size10x10.npy" % node_idx), imgs_fake1)
                    np.save(os.path.join(normalization_output_path, "%d_fake_size20x20.npy" % node_idx), imgs_fake2)
                    np.save(os.path.join(normalization_output_path, "%d_fake_size40x40.npy" % node_idx), imgs_fake3)
                    print(" generate fake cubic finished...")

                except Exception,e:
                    print(" process images %s error..."%str(file_name))
                    print(Exception,":",e)
                    traceback.print_exc()


def plot_cubic(npy_file):
    '''
       plot the cubic slice by slice

    :param npy_file:
    :return:
    '''
    cubic_array = np.load(npy_file)
    f, plots = plt.subplots(int(cubic_array.shape[2]/3), 3, figsize=(50, 50))
    for i in range(1, cubic_array.shape[2]+1):
        plots[int(i / 3), int((i % 3) )].axis('off')
        plots[int(i / 3), int((i % 3) )].imshow(cubic_array[:,:,i], cmap=plt.cm.bone)

def plot_3d_cubic(image):
    '''
        plot the 3D cubic
    :param image:   image saved as npy file path
    :return:
    '''
    from skimage import measure, morphology
    from mpl_toolkits.mplot3d.art3d import Poly3DCollection
    image = np.load(image)
    verts, faces = measure.marching_cubes(image,0)
    fig = plt.figure(figsize=(40, 40))
    ax = fig.add_subplot(111, projection='3d')
    # Fancy indexing: `verts[faces]` to generate a collection of triangles
    mesh = Poly3DCollection(verts[faces], alpha=0.1)
    face_color = [0.5, 0.5, 1]
    mesh.set_facecolor(face_color)
    ax.add_collection3d(mesh)
    ax.set_xlim(0, image.shape[0])
    ax.set_ylim(0, image.shape[1])
    ax.set_zlim(0, image.shape[2])
    plt.show()

# LUNA2016 data prepare ,first step: truncate HU to -1000 to 400
def truncate_hu(image_array):
    image_array[image_array > 400] = 0
    image_array[image_array <-1000] = 0

# LUNA2016 data prepare ,second step: normalzation the HU
def normalazation(image_array):
    max = image_array.max()
    min = image_array.min()
    avg = image_array.mean()
    image_array = (image_array-min)/(max-min)-avg  # float cannot apply the compute,or array error will occur

    #print("this function should finish make data distribute in range[-1000,400] and average (0,1) ,then all subtract mean ")

# get the average HU value of npy by path.
# Considering the whole npy file size may extent to 160GB, we cannot put all of them into memory.This method sum them up point by point and average them
def average_npy_by_path(path):
    total = 0
    point_num =0
    for file in os.listdir(path):
        npy_file = os.path.join(path,file)


def search(path, word):
    '''
       find filename match keyword from path
    :param path:  path search from
    :param word:  keyword should be matched
    :return:
    '''
    filelist = []
    for filename in os.listdir(path):
        fp = os.path.join(path, filename)
        if os.path.isfile(fp) and word in filename:
            filelist.append(fp)
        elif os.path.isdir(fp):
            search(fp, word)
    return filelist


def get_train_batch(path,i,batch_size,size):
    batch_train =[]
    batch_label =[]
    list_real = search(path, 'real_size'+str(size)+"x"+str(size))
    list_fake = search(path, 'fake_size' + str(size) + "x" + str(size))
    batch_real = list_real[i*batch_size:(i+1)*batch_size]
    # get file name like  '1116_fake_size20x20.npy',they are constructed by  extract_cubir_from_mhd method
    batch_fake = list_fake[i*batch_size:(i+1)*batch_size]

    batch_train = batch_real+batch_fake  # union two list
    #batch_train = np.array([np.load(file) for file in batch_train])
    batch_array = []
    for npy in batch_train:
        try:
            arr = np.load(npy)
            arr = arr.transpose(2,1,0)
            batch_array.append(arr)
        except Exception,e:
            print("file not exists! %s"%npy)
            batch_array.append(batch_array[-1])  # some nodule process error leading nonexistent of the file, using the last file copy to fill
    batch_label = [[1,0]]*len(batch_real)+[[0,1]]*len(batch_fake)

    return np.array(batch_array),np.array(batch_label)


if __name__ =='__main__':

    annatation_file = '/data/LUNA2016/lung_imgs/evaluationScript/annotations/annotations.csv'
    plot_output_path = '/data/LUNA2016/cubic_npy'
    normalazation_output_path = '/data/LUNA2016/cubic_normalization_npy'
    for i in range(1,9):
        dcim_path = '/data/LUNA2016/lung_imgs/subset'+str(i)+"/"
        extract_cubic_from_mhd(dcim_path, annatation_file, plot_output_path,normalazation_output_path)
    print("finished!...")
    #list = search(normalazation_output_path,'real_size10x10')
    print(list)

    #plot_cubic(
    #    '/data/LUNA2016/cubic_npy/images_1.3.6.1.4.1.14519.5.2.1.6279.6001.868211851413924881662621747734.mhd_1123_pos-79.93305233_81.93715229_-169.4337204_size10x10.npy')


