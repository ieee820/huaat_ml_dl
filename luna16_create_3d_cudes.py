import SimpleITK as sitk
import numpy as np
import csv
import os
from PIL import Image
import matplotlib.pyplot as plt
from random import shuffle
# from keras.preprocessing.image import ImageDataGenerator, array_to_img, img_to_array, load_img
import traceback


def load_itk_image(filename):
    itkimage = sitk.ReadImage(filename)
    numpyImage = sitk.GetArrayFromImage(itkimage)

    numpyOrigin = np.array(list(reversed(itkimage.GetOrigin())))
    numpySpacing = np.array(list(reversed(itkimage.GetSpacing())))

    return numpyImage, numpyOrigin, numpySpacing


def readCSV(filename):
    lines = []
    with open(filename, "rb") as f:
        csvreader = csv.reader(f)
        for line in csvreader:
            lines.append(line)
    return lines


def worldToVoxelCoord(worldCoord, origin, spacing):
    stretchedVoxelCoord = np.absolute(worldCoord - origin)
    voxelCoord = np.rint(stretchedVoxelCoord / spacing)
    return voxelCoord


def normalizePlanes(npzarray):
    maxHU = 400.
    minHU = -1000.

    npzarray = (npzarray - minHU) / (maxHU - minHU)
    npzarray[npzarray > 1] = 1.
    npzarray[npzarray < 0] = 0.
    return npzarray


def plot_cube(cube, i):
    #cube_180d = np.fliplr(cube[i])
    plt.imshow(cube[i], cmap='gray')
    plt.show()


def cut_cube(npy_img,voxelCoord, z, width, y_bias, x_bias):
    # mirror the images , the same with the web browser
    npy_ct = npy_img[int(voxelCoord[0] - z / 2):int(voxelCoord[0] + z / 2),:,:]
    # datatype(z,y,x) = float32,to input to tensorflow
    # y_bias, x bias for data augmentation
    cube = np.ndarray([z, width, width], dtype=np.float32)
    cube[:, :, :] = npy_ct[:,
                    int(voxelCoord[1] - width / 2 + y_bias):int(voxelCoord[1] + width / 2 + y_bias),
                    int(voxelCoord[2] - width / 2 + x_bias):int(voxelCoord[2] + width / 2 + x_bias)]
    cube = normalizePlanes(cube)
    flip_cube = np.ndarray([z, width, width], dtype=np.float32)
    for i in range(cube.shape[0]):
        flip_cube[i] = np.fliplr(cube[i])

    return flip_cube


def angle_transpose(cube, degree):
    '''
     @param file : a npy file which store all information of one cubic
     @param degree: how many degree will the image be transposed,90,180,270 are OK
    '''
    cube_rotation = np.zeros(cube.shape, dtype=np.float32)
    for depth in range(cube.shape[0]):
        silce = cube[depth]
        silce.reshape((silce.shape[0], silce.shape[1], 1))
        img = Image.fromarray(silce)
        # img.show()
        out = img.rotate(degree)  # degree = 90,180,270
        cube_rotation[depth, :, :] = np.array(out).reshape(cube.shape[1], -1)[:, :]

    return cube_rotation


def reverse_cube(cube):
    re_cube = np.ndarray(cube.shape, dtype=np.float32)
    j = 0
    for i in range(cube.shape[0] - 1, -1, -1):
        re_cube[j, :, :] = cube[i, :, :]
        j += 1
    return re_cube


# flag = type of cube augmentations
def augmentation_cube(npy_ct,prefix, voxelCoord, z, width, y_bias, x_bias, flag):

    cube = cut_cube(npy_ct,voxelCoord, z, width, y_bias, x_bias)
    re_cube = reverse_cube(cube)
    np.save(npy_save_path + prefix + '20_' + 'cube_' + flag, cube)
    np.save(npy_save_path + prefix + '20_' + 're_cube_' + flag, re_cube)

    cube_90d = angle_transpose(cube,90)
    re_cube_90d = reverse_cube(cube_90d)
    np.save(npy_save_path + prefix + '20_' + 'cube_90d' + flag, cube_90d)
    np.save(npy_save_path + prefix + '20_' + 're_cube_90d' + flag, re_cube_90d)

    cube_180d = angle_transpose(cube,180)
    re_cube_180d = reverse_cube(cube_180d)
    np.save(npy_save_path + prefix + '20_' + 'cube_180d' + flag, cube_180d)
    np.save(npy_save_path + prefix + '20_' + 're_cube_180d' + flag, re_cube_180d)

    cube_270d = angle_transpose(cube,270)
    re_cube_270d = reverse_cube(cube_270d)
    np.save(npy_save_path + prefix + '20_' + 'cube_270d' + flag, cube_270d)
    np.save(npy_save_path + prefix + '20_' + 're_cube_270d' + flag, re_cube_270d)


def batch_cut_cube(z, width, bias):
    for anno in annos[1:]:
        numpyImage, numpyOrigin, numpySpacing = load_itk_image(img_folder + anno[0] + '.mhd')
        worldCoord = np.asarray([float(anno[3]), float(anno[2]), float(anno[1])])
        # order = z,y,x
        voxelCoord = worldToVoxelCoord(worldCoord, numpyOrigin, numpySpacing)
        prefix = 'lung16_' + str(anno[3]) + '_' + str(anno[2]) + '_' + str(anno[1]) + '_'
        # cube augmentation and then save
        augmentation_cube(numpyImage,prefix, voxelCoord, z, width, 0, 0, '00')
        #
        augmentation_cube(numpyImage,prefix, voxelCoord, z, width, bias, 0, '01')
        #
        augmentation_cube(numpyImage,prefix, voxelCoord, z, width, 0, bias, '02')
        #
        augmentation_cube(numpyImage,prefix, voxelCoord, z, width, -bias, 0, '03')
        #
        augmentation_cube(numpyImage,prefix, voxelCoord, z, width, 0, -bias, '04')
        #
        augmentation_cube(numpyImage,prefix, voxelCoord, z, width, bias, bias, '05')
        #
        augmentation_cube(numpyImage,prefix, voxelCoord, z, width, bias, -bias, '06')
        #
        augmentation_cube(numpyImage,prefix, voxelCoord, z, width, -bias, bias, '07')
        #
        augmentation_cube(numpyImage,prefix, voxelCoord, z, width, -bias, -bias, '08')


def batch_cut_negative_cube(z, width):
    # shuffle cans
    index_shuf = range(len(cans))
    shuffle(index_shuf)
    j = 0
    for i in index_shuf:
        numpyImage, numpyOrigin, numpySpacing = load_itk_image(img_folder + cans[i][0] + '.mhd')
        worldCoord = np.asarray([float(cans[i][3]), float(cans[i][2]), float(cans[i][1])])
        # order = z,y,x
        voxelCoord = worldToVoxelCoord(worldCoord, numpyOrigin, numpySpacing)
        prefix = 'lung16_' + str(cans[i][3]) + '_' + str(cans[i][2]) + '_' + str(cans[i][1]) + '_'
        # test if the voxelCoord inside the 512x512xslice range
        if abs(voxelCoord[0]-numpyImage.shape[0]) > 6 and abs(voxelCoord[1]-numpyImage.shape[1]) > 20 and abs(voxelCoord[2]-numpyImage.shape[2]) > 20:
            # cut negative cube
            cube = cut_cube(numpyImage,voxelCoord, z, width, 0, 0)
            print str(i)+'|'+ cans[i][0]
            np.save(negative_npy_save_path + prefix + '20_' + 'cube_' + 'negative', cube)
            j += 1
            if j >= 85392:
                break


def fast_cut_negative_cube(z, width):
    prev = 'head'
    numpyImage = None
    numpyOrigin = None
    numpySpacing = None
    for can in cans:
        if can[0] == prev:
            worldCoord = np.asarray([float(can[3]), float(can[2]), float(can[1])])
            # order = z,y,x
            voxelCoord = worldToVoxelCoord(worldCoord, numpyOrigin, numpySpacing)
            prefix = 'lung16_' + str(can[3]) + '_' + str(can[2]) + '_' + str(can[1]) + '_'
            # test if the voxelCoord inside the 512x512xslice range
            if abs(voxelCoord[0]-numpyImage.shape[0]) > 6 and abs(voxelCoord[1]-numpyImage.shape[1]) > 20 and abs(voxelCoord[2]-numpyImage.shape[2]) > 20:
                try:
                # cut negative cube
                    cube = cut_cube(numpyImage,voxelCoord, z, width, 0, 0)
                except Exception, e:
                    print(" process images %s error..." % prefix)
                    print(Exception, ":", e)
                    traceback.print_exc()
                np.save(negative_npy_save_path + prefix + '20_' + 'cube_' + 'negative', cube)


            prev = can[0]
        else:
            numpyImage, numpyOrigin, numpySpacing = load_itk_image(img_folder + can[0] + '.mhd')
            worldCoord = np.asarray([float(can[3]), float(can[2]), float(can[1])])
            # order = z,y,x
            voxelCoord = worldToVoxelCoord(worldCoord, numpyOrigin, numpySpacing)
            prefix = 'lung16_' + str(can[3]) + '_' + str(can[2]) + '_' + str(can[1]) + '_'
            # test if the voxelCoord inside the 512x512xslice range
            if abs(voxelCoord[0]-numpyImage.shape[0]) > 6 and abs(voxelCoord[1]-numpyImage.shape[1]) > 20 and abs(voxelCoord[2]-numpyImage.shape[2]) > 20:
                try:
                    # cut negative cube
                    cube = cut_cube(numpyImage,voxelCoord, z, width, 0, 0)
                except Exception, e:
                    print(" process images %s error..." % prefix)
                    print(Exception, ":", e)
                    traceback.print_exc()
                np.save(negative_npy_save_path + prefix + '20_' + 'cube_' + 'negative', cube)

            prev = can[0]


# if save = 1 ,save the imgs ; else plot the imgs
def check_cube(cube,save,path):
    for i in np.arange(0,cube.shape[0]):
        if save == 1:
            Image.fromarray(cube[i] * 255).convert('L').save(os.path.join(path,str(i)+'.tiff'))
        else:
            plot_cube(cube,i)

if __name__ == '__main__':
    npy_save_path = 'E:/work_temp/luna16_output/positive/20mm/'
    negative_npy_save_path = 'E:/work_temp/luna16_output/negative/20mm/'
    img_folder = 'D:/luna2016/data/'
    anno_path = 'D:/luna2016/annotations.csv'
    candidates_path = 'cans_sort.txt'
    #
    # load annotations
    annos = readCSV(anno_path)
    # load candidates
    cans = readCSV(candidates_path)
    #
    # #batch_cut_negative_cube(6,20)
    # fast_cut_negative_cube(6,20)
    print('main_func')

    # batch_cut_cube(6, 20, 3)
    # cube = np.load(negative_npy_save_path+'lung16_-183.27_-127.57_-9.17_20_cube_negative'+'.npy')
    # check_cube(cube)
    # print cube.shape
    # index_shuf = range(len(cans))
    # shuffle(index_shuf)
    # j = 0
    # fo = open("cans_output.txt", "w")
    #
    # for i in index_shuf:
    #     # print cans[i]
    #     j += 1
    #     fo.write((cans[i][0])+','+(cans[i][1])+','+(cans[i][2])+','+(cans[i][3])+','+(cans[i][4])+'\n')
    #     if j >= 90000:
    #         break
    # fo.close()
