import numpy as np # linear algebra
import pandas as pd # data processing, CSV file I/O (e.g. pd.read_csv)
import dicom
import os
import scipy.ndimage
import matplotlib.pyplot as plt
from PIL import Image
from luna2016_3d_predict import predict_by_one
import luna16_config


def normalizePlanes(npzarray):
    maxHU = 400.
    minHU = -1000.

    npzarray = (npzarray - minHU) / (maxHU - minHU)
    npzarray[npzarray > 1] = 1.
    npzarray[npzarray < 0] = 0.
    return npzarray


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

def plot_cube(cube, i):
    #cube_180d = np.fliplr(cube[i])
    plt.imshow(cube[i], cmap='gray')
    plt.show()


# if save = 1 ,save the imgs ; else plot the imgs
def check_cube(cube,save,path):
    for i in np.arange(0,cube.shape[0]):
        if save == 1:
            Image.fromarray(cube[i] * 255).convert('L').save(os.path.join(path,str(i)+'.tiff'))
        else:
            plot_cube(cube,i)


# Load the scans in given folder path
def load_scan(path):
    slices = [dicom.read_file(path + '/' + s ) for s in os.listdir(path)]
    slices.sort(key = lambda x: float(x.ImagePositionPatient[2]))
    try:
        slice_thickness = np.abs(slices[0].ImagePositionPatient[2] - slices[1].ImagePositionPatient[2])
    except:
        slice_thickness = np.abs(slices[0].SliceLocation - slices[1].SliceLocation)

    for s in slices:
        s.SliceThickness = slice_thickness

    return slices

def get_pixels_hu(slices):
    image = np.stack([s.pixel_array for s in slices])
    # Convert to int16 (from sometimes int16),
    # should be possible as values should always be low enough (<32k)
    image = image.astype(np.int16)

    # Set outside-of-scan pixels to 0
    # The intercept is usually -1024, so air is approximately 0
    image[image == -2000] = 0

    # Convert to Hounsfield units (HU)
    for slice_number in range(len(slices)):

        intercept = slices[slice_number].RescaleIntercept
        slope = slices[slice_number].RescaleSlope

        if slope != 1:
            image[slice_number] = slope * image[slice_number].astype(np.float64)
            image[slice_number] = image[slice_number].astype(np.int16)

        image[slice_number] += np.int16(intercept)

    return np.array(image, dtype=np.int16)


def resample(image, scan, new_spacing=[1,1,1]):
    # Determine current pixel spacing
    spacing = np.array([scan[0].SliceThickness] + scan[0].PixelSpacing, dtype=np.float32)

    resize_factor = spacing / new_spacing
    new_real_shape = image.shape * resize_factor
    new_shape = np.round(new_real_shape)
    real_resize_factor = new_shape / image.shape
    new_spacing = spacing / real_resize_factor

    image = scipy.ndimage.interpolation.zoom(image, real_resize_factor, mode='nearest')

    return image, new_spacing


def cut_plane(npy_ct,voxelCoord, z,width):
    # datatype(z,y,x) = float32,to input to tensorflow
    # y_bias, x bias for data augmentation
    cube = np.ndarray([z, width, width], dtype=np.float32)
    cube[:, :, :] = npy_ct[int(voxelCoord[0] - z / 2):int(voxelCoord[0] + z / 2),:,:]
    cube = normalizePlanes(cube)
    flip_cube = np.ndarray([z, width, width], dtype=np.float32)
    for i in range(cube.shape[0]):
        flip_cube[i] = np.fliplr(cube[i])
    return flip_cube

def online_predict(slices_folder,z,y,x):
    slices = load_scan(luna16_config.luna16_path+slices_folder)
    npy_img = get_pixels_hu(slices)
    voxelCoord = [npy_img.shape[0]-z,y,npy_img.shape[2]-x]
    cube = cut_cube(npy_img,voxelCoord,6,20,0,0)
    check_cube(cube,1,'temp_imgs')
    result = predict_by_one(cube)
    return result

if __name__ == '__main__':
    slices = load_scan(luna16_config+'0015ceb851d7251b8f399e39779d1e7d')
    npy_img = get_pixels_hu(slices)
    voxelCoord = [npy_img.shape[0]-56,388,npy_img.shape[2]-326]
    # cube = cut_plane(npy_img,voxelCoord,6,512)
    cube = cut_cube(npy_img,voxelCoord,6,20,0,0)
    check_cube(cube,0,'temp_imgs')
    # predict_by_one(cube)
    # print(cube.shape)
    #np.save('0708c00f6117ed977bbe1b462b56848c_negative',cube)
    # online_predict('00edff4f51a893d80dae2d42a7f45ad1',52,257,69)