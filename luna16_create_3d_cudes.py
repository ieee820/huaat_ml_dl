import SimpleITK as sitk
import numpy as np
import csv
import os
from PIL import Image
import matplotlib.pyplot as plt
# from keras.preprocessing.image import ImageDataGenerator, array_to_img, img_to_array, load_img

npy_save_path = 'E:/work_temp/luna16_output/'


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
    plt.imshow(cube[i, :, :], cmap='gray')
    plt.show()


# def cube_augmentation(cube,i):
#     datagen = ImageDataGenerator(
#         rotation_range=0.2,
#         width_shift_range=0.2,
#         height_shift_range=0.2,
#         shear_range=0.2,
#         zoom_range=0.2,
#         horizontal_flip=True,
#         fill_mode='nearest')
#
#     cube = cube[i,:,:].reshape(1,20,20,1)
#     i = 0
#     for batch in datagen.flow(cube,
# 						  batch_size=1,
#                           save_to_dir='E:/work_temp/luna16_output/',
#                           save_prefix='lung16',
#                           save_format='jpg'):
#         i += 1
#         if i > 10:
#             break  # otherwise the generator would loop indefinitely
# for i in np.arange(0,cube.shape[0]):
#     plot_cube(cube,i)
#
# print 'begin transform'

# cube_rotation = angle_transpose(cube,270)
#
# for i in np.arange(0,cube_rotation.shape[0]):
#     plot_cube(cube_rotation,i)
# c1 = np.load('lung16_-279.2924241_75.79401283_58.51266333_20_cube.npy')
# for i in np.arange(0,c1.shape[0]):
#      plot_cube(c1,i)
# print '*******'
# c2 = np.load('lung16_-279.2924241_75.79401283_58.51266333_20_re_cube.npy')
# for i in np.arange(0,c2.shape[0]):
#      plot_cube(c2,i)

# for i in np.arange(0,re_cube.shape[0]):
#     plot_cube(re_cube,i)


img_folder = 'D:/luna2016/data/'
anno_path = 'D:/luna2016/annotations.csv'

# load annotations
annos = readCSV(anno_path)




def cut_cube(npy_ct,voxelCoord, z, width, y_bias, x_bias):
    # datatype(z,y,x) = float32,to input to tensorflow
    # y_bias, x bias for data augmentation
    cube = np.ndarray([z, width, width], dtype=np.float32)
    cube[:, :, :] = npy_ct[int(voxelCoord[0] - z / 2):int(voxelCoord[0] + z / 2),
                    int(voxelCoord[1] - width / 2 + y_bias):int(voxelCoord[1] + width / 2 + y_bias),
                    int(voxelCoord[2] - width / 2 + x_bias):int(voxelCoord[2] + width / 2 + x_bias)]
    cube = normalizePlanes(cube)

    return cube


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


def batch_cat_cube(z, width, bias):
    for anno in annos[181:182]:
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


def check_cube(cube):
    for i in np.arange(0,cube.shape[0]):
        plot_cube(cube,i)

if __name__ == '__main__':
    # batch_cat_cube(6, 20, 3)
    cube = np.load(npy_save_path+'lung16_-279.2924241_75.79401283_58.51266333_20_re_cube_270d08'+'.npy')
    check_cube(cube)
    print cube.shape

