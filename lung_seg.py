import numpy as np # linear algebra
import pandas as pd # data processing, CSV file I/O (e.g. pd.read_csv)
import skimage, os
from skimage.morphology import ball, disk, dilation, binary_erosion, remove_small_objects, erosion, closing, reconstruction, binary_closing
from skimage.measure import label,regionprops, perimeter
from skimage.morphology import binary_dilation, binary_opening
from skimage.filters import roberts, sobel
from skimage import measure, feature
from skimage.segmentation import clear_border
from skimage import data
from scipy import ndimage as ndi
import matplotlib.pyplot as plt
from mpl_toolkits.mplot3d.art3d import Poly3DCollection
import dicom
import scipy.misc
import numpy as np

from luna16_config import dicom_path,lung2017_path

def check_dicom(im):
    # lung = dicom.read_file(dicom_path+'IMG-0001-00001.dcm')
    slice = im.pixel_array
    slice[slice == -2000] = 0
    # plt.imshow(slice, cmap=plt.cm.gray)
    # plt.show()
    return slice

def plot_im(im,centroid):
    cube = np.ndarray([40,40], dtype=np.float32)
    cube[:,:] = im[int(centroid[0] - 20):int(centroid[0] + 20),int(centroid[1] - 20):int(centroid[1] + 20)]
    plt.imshow(cube, cmap='gray')
    plt.show()


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


def get_n_masks(im,z):
    coords = []
    binary = im < 604
    cleared = clear_border(binary)
    label_image = label(cleared)
    areas = [r.area for r in regionprops(label_image)]
    areas.sort()
    if len(areas) > 2:
        for region in regionprops(label_image):
            if region.area < 6 and region.area > 3:
                # print(region.centroid)
                # print(region.area)
                centroid = region.centroid
                coord = [int(centroid[0]),int(centroid[1]),z]
                # plot_im(im,centroid)
                coords.append(coord)
    return coords

def get_masks(im):
    '''
    Step 1: Convert into a binary image.
    '''
    print('step1')
    binary = im < 604
    # plt.imshow(binary,cmap=plt.cm.gray)
    # plt.show()

    '''
    Step 2: Remove the blobs connected to the border of the image.
    '''
    print('step2')
    cleared = clear_border(binary)
    # plt.imshow(cleared,cmap=plt.cm.gray)
    # plt.show()
    '''
    Step 3: Label the image.
    '''
    print('step3')
    label_image = label(cleared)
    # plt.imshow(label_image,cmap=plt.cm.gray)
    # plt.show()

    '''
    Step 4: Keep the labels with 2 largest areas.
    '''
    print('step4')
    areas = [r.area for r in regionprops(label_image)]
    areas.sort()
    if len(areas) > 2:
        for region in regionprops(label_image):
            if region.area < 10 and region.area > 3:
                print(region.centroid,region.area)
                # print(region.area)
                centroid = region.centroid
                plot_im(im,centroid)
                # label_image[int(centroid[0]),int(centroid[1])] = 1000
                # for coordinates in region.coords:
                #     label_image[coordinates[0], coordinates[1]] = 0
    # binary = label_image > 999
    # plt.imshow(binary,cmap=plt.cm.gray)
    # plt.show()

    '''
    Step 5: Erosion operation with a disk of radius 2. This operation is
    seperate the lung nodules attached to the blood vessels.
    '''
    # print('step5')
    # selem = disk(2)
    # binary = binary_erosion(binary, selem)
    # plt.imshow(binary,cmap=plt.cm.gray)
    # plt.show()


def loop_slices(slices):
    all_coords = []
    for i in range(0,slices.__len__()):
        im = check_dicom(slices[i])
        coords = get_n_masks(im,i)
        all_coords.append(coords)
        # print(coords.__len__())
        # count = 0
        # for j in range(0,coords.__len__()):
        #     print(int(coords[j][0]),int(coords[j][1]),coords[j][2])
        #     count+=1
    # print(count)
    return all_coords


def normalizePlanes(npzarray):
    maxHU = 400.
    minHU = -1000.

    npzarray = (npzarray - minHU) / (maxHU - minHU)
    npzarray[npzarray > 1] = 1.
    npzarray[npzarray < 0] = 0.
    return npzarray


def cut_cube(npy_img,voxelCoord, z, width, y_bias, x_bias):
    #voxelcoord: y,x,z
    npy_ct = npy_img[int(voxelCoord[2] - z / 2):int(voxelCoord[2] + z / 2),:,:]
    # datatype(z,y,x) = float32,to input to tensorflow
    # y_bias, x bias for data augmentation
    cube = np.ndarray([z, width, width], dtype=np.float32)
    cube[:, :, :] = npy_ct[:,
                    int(voxelCoord[0] - width / 2 + y_bias):int(voxelCoord[0] + width / 2 + y_bias),
                    int(voxelCoord[1] - width / 2 + x_bias):int(voxelCoord[1] + width / 2 + x_bias)]
    cube = normalizePlanes(cube)
    return cube


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


def print_all_coords(all_coords):
    for i in range(0,all_coords.__len__()):
        if all_coords[i].__len__() > 0:
            for j in range(0,all_coords[i].__len__()):
                if all_coords[i][j].__len__() > 0:
                    print(all_coords[i][j][0],all_coords[i][j][1],all_coords[i][j][2])


def plot_cube(cube, i):
    #cube_180d = np.fliplr(cube[i])
    plt.imshow(cube[i], cmap='gray')
    plt.show()


# if save = 1 ,save the imgs ; else plot the imgs
def check_cube(cube):
    for i in np.arange(0,cube.shape[0]):
        plot_cube(cube,i)

def get_segmented_lungs(im, plot=True):

    '''
    This funtion segments the lungs from the given 2D slice.
    '''
    # if plot == True:
    #     f, plots = plt.subplots(8, 1, figsize=(40, 40))
    '''
    Step 1: Convert into a binary image.
    '''
    print('step1')
    binary = im < 604
    plt.imshow(binary,cmap=plt.cm.gray)
    plt.show()

    '''
    Step 2: Remove the blobs connected to the border of the image.
    '''
    print('step2')
    cleared = clear_border(binary)
    plt.imshow(cleared,cmap=plt.cm.gray)
    plt.show()
    '''
    Step 3: Label the image.
    '''
    print('step3')
    label_image = label(cleared)
    plt.imshow(label_image,cmap=plt.cm.gray)
    plt.show()

    '''
    Step 4: Keep the labels with 2 largest areas.
    '''
    print('step4')
    areas = [r.area for r in regionprops(label_image)]
    areas.sort()
    if len(areas) > 2:
        for region in regionprops(label_image):
            if region.area < areas[-2]:
                for coordinates in region.coords:
                       label_image[coordinates[0], coordinates[1]] = 0
    binary = label_image > 0
    plt.imshow(binary,cmap=plt.cm.gray)
    plt.show()

    '''
    Step 5: Erosion operation with a disk of radius 2. This operation is
    seperate the lung nodules attached to the blood vessels.
    '''
    print('step5')
    selem = disk(2)
    binary = binary_erosion(binary, selem)
    plt.imshow(binary,cmap=plt.cm.gray)
    plt.show()

    '''
    Step 6: Closure operation with a disk of radius 10. This operation is
    to keep nodules attached to the lung wall.
    '''
    print('step6')
    selem = disk(10)
    binary = binary_closing(binary, selem)
    plt.imshow(binary,cmap=plt.cm.gray)
    plt.show()

    '''
    Step 7: Fill in the small holes inside the binary mask of lungs.
    '''
    print('step7')
    edges = roberts(binary)
    binary = ndi.binary_fill_holes(edges)
    plt.imshow(binary,cmap=plt.cm.gray)
    plt.show()

    '''
    Step 8: Superimpose the binary mask on the input image.
    '''
    print('step8')
    get_high_vals = binary == 0
    im[get_high_vals] = 0
    plt.imshow(im,cmap=plt.cm.gray)
    plt.show()


    return im


def test():
    list_x_train = []
    list_y_train = []
    slices = load_scan(lung2017_path+'0708c00f6117ed977bbe1b462b56848c')
    all_coords = loop_slices(slices)
    # print(all_coords[127][2][0],all_coords[127][2][1],all_coords[127][2][2])
    img = get_pixels_hu(slices)
    # voxelCoord = [all_coords[127][2][0],all_coords[127][2][1],all_coords[127][2][2]]
    # voxelCoord = [int(217),int(355),int(127)]
    for i in range(15,163):
        for j in range(0,all_coords[i].__len__()):
                if all_coords[i][j].__len__() > 0:
                    voxelCoord = [all_coords[i][j][0],all_coords[i][j][1],all_coords[i][j][2]]
                    cube = cut_cube(img,voxelCoord,26,40,0,0)
                    list_x_train.append(cube)
                    list_y_train.append(voxelCoord)

    x_all = np.array(list_x_train)
    y_all = np.array(list_y_train)
    np.save('dicom_cubes',x_all)
    np.save('dicom_cubes_coord',y_all)

def test1():
    dicom_cubes = np.load('dicom_cubes.npy')
    dicom_cubes_coord = np.load('dicom_cubes_coord.npy')
    check_cube(dicom_cubes[10])
    print(dicom_cubes_coord[10])


if __name__ == '__main__':
    test()
