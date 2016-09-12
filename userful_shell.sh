 find ./cat/ -iname "*.jpg" | sed -n '1,100p' | xargs cp -t ../temp/


 794624 Aug 31 16:32 cat/
drwxrwxr-x  2 ubuntu ubuntu  618496 Aug 31 16:41 chipmunk/
-rw-rw-r--  1 ubuntu ubuntu       0 Apr 26 03:14 .cloud-locale-test.skip
drwxrwxr-x  2 ubuntu ubuntu  761856 Aug 31 17:06 dog/
drwxrwxr-x  2 ubuntu ubuntu  634880 Aug 31 16:17 fox/
drwxrwxr-x  2 ubuntu ubuntu  626688 Aug 31 16:57 giraffe/
drwxrwxr-x  2 ubuntu ubuntu  765952 Aug 31 18:02 guinea_pig/
drwxrwxr-x  2 ubuntu ubuntu  495616 Aug 31 17:07 hyena/
drwx------  3 ubuntu ubuntu    4096 Apr 26 03:29 .nv/
-rw-r--r--  1 ubuntu ubuntu     777 Apr 26 03:28 .profile
drwxrwxr-x  2 ubuntu ubuntu  503808 Aug 31 17:36 reindeer/
drwxrwxr-x  2 ubuntu ubuntu  507904 Aug 31 17:50 sikadeer/
drwxrwxr-x  2 ubuntu ubuntu  626688 Aug 31 16:26 squirrel/
drwx------  2 ubuntu ubuntu    4096 Apr 26 03:12 .ssh/
drwxrwxr-x  4 ubuntu ubuntu    4096 Apr 26 03:28 TensorFlow-Tutorials/
-rw-r--r--  1 root   root      1794 Sep  6 12:50 test_class.py
drwxr-xr-x  6 root   root      4096 Sep  7 14:43 train0907/
drwxrwxr-x  2 ubuntu ubuntu    4096 Sep  8 02:12 train0908/
-rw-------  1 ubuntu ubuntu    1923 Sep  6 12:33 .viminfo
drwxrwxr-x  2 ubuntu ubuntu  483328 Aug 31 17:13 weasel/
drwxrwxr-x  2 ubuntu ubuntu  786432 Aug 31 18:09 wolf/

http://ec2-52-32-202-72.us-west-2.compute.amazonaws.com/files/20160908-015724-8442/caffe_output.log


find ./cat/ -iname "*.jpg" | sed -n '7000,8000p' | xargs cp -t ./train0908/cat

mkdir ./train0908/cat
mkdir ./train0908/chipmunk
mkdir ./train0908/dog
mkdir ./train0908/fox
mkdir ./train0908/giraffe
mkdir ./train0908/guinea_pig
mkdir ./train0908/hyena
mkdir ./train0908/reindeer
mkdir ./train0908/sikadeer
mkdir ./train0908/squirrel
mkdir ./train0908/weasel
mkdir ./train0908/wolf


find ./chipmunk/ -iname "*.jpg" | sed -n '7000,7999p' | xargs cp -t ./train0908/chipmunk
find ./dog/ -iname "*.jpg" | sed -n '7000,7999p' | xargs cp -t ./train0908/dog
find ./fox/ -iname "*.jpg" | sed -n '7000,7999p' | xargs cp -t ./train0908/fox/
find ./giraffe/ -iname "*.jpg" | sed -n '1,1000p' | xargs cp -t ./train0908/giraffe/
find ./guinea_pig/ -iname "*.jpg" | sed -n '1000,2000p' | xargs cp -t ./train0908/guinea_pig/
find ./hyena/ -iname "*.jpg" | sed -n '1000,1999p' | xargs cp -t ./train0908/hyena/
find ./reindeer/ -iname "*.jpg" | sed -n '1000,1999p' | xargs cp -t ./train0908/reindeer/
find ./sikadeer/ -iname "*.jpg" | sed -n '1000,1999p' | xargs cp -t ./train0908/sikadeer/
find ./squirrel/ -iname "*.jpg" | sed -n '1000,1999p' | xargs cp -t ./train0908/squirrel/
find ./weasel/ -iname "*.jpg" | sed -n '1000,1999p' | xargs cp -t ./train0908/weasel/
find ./wolf/ -iname "*.jpg" | sed -n '1000,1999p' | xargs cp -t ./train0908/wolf/


aws s3 cp ./train0908.zip s3://yangjj-share01/

find ./ -iname "*.jpg" | wc -l

mv guinea_pig 0
mv squirrel 1
mv sikadeer 2
mv fox 3
mv dog 4
mv wolf 5
mv cat 6
mv chipmunk 7
mv giraffe 8
mv reindeer 9
mv hyena 10
mv weasel 11


ifconfig eth0 | grep 'inet addr' 


/home/sjkxb/Downloads/tools/caffe-master/build/tools
#solver里面指定了net的结构
caffe train -solver models/finetune_flickr_style/solver.prototxt -weights models/bvlc_reference_caffenet/bvlc_reference_caffenet.caffemodel -gpu 0


bvlc_reference_caffenet.caffemodel

find ./1/ -iname "*.jpg" | sed 's/^\.//g' | sed -n '1,1000p' | sed "s/$/ 1/" >> dataset0908/train.txt
find ./1/ -iname "*.jpg" | sed 's/^\.//g' | sed -n '1000,1300p' | sed "s/$/ 1/" >> dataset0908/test.txt 
cat test.txt | awk '{print ".."$1}' | xargs cp -t ./test/


./build/tools/caffe train -solver models/gpu_model/solver_bot20160908.prototxt -weights models/bvlc_reference_caffenet/bvlc_reference_caffenet.caffemodel -gpu 0


$caffe_root/build/examples/cpp_classification/classification.bin \
> $caffe_root/models/gpu_model/deploy.prototxt \
> $caffe_root/models/gpu_model/snapshot_iter_120.caffemodel \
/home/gpu01/bot_img/dataset0908/mean.binaryproto


find ./0/ -iname "*" | sed 's/^\.//g' | sed -n '1,8400p' | sed "s/$/ 0/" | more 

---------- Prediction for /home/gpu01/bot_img/0/005f8985622048ea987e2506b12fc469.jpg ----------
1.0000 - "0"
0.0000 - "1"


find ./0/ -type f \( -iname \*.jpg -o -iname \*.png -o -iname \*.gif \) | sed 's/^\.//g' | sed -n '1,8400p' | sed "s/$/ 0/" >> dataset_12c/train.txt
find ./0/ -type f \( -iname \*.jpg -o -iname \*.png -o -iname \*.gif \) | sed 's/^\.//g' | sed -n '8401,12000p' | sed "s/$/ 0/" > dataset_12c/test.txt


cat dataset_12c/train.txt  | wc -l
cat dataset_12c/test.txt  | wc -l


find ./1/ -type f \( -iname \*.jpg -o -iname \*.png -o -iname \*.gif \) | sed 's/^\.//g' | sed -n '1,7000p' | sed "s/$/ 1/" >> dataset_12c/train.txt
find ./1/ -type f \( -iname \*.jpg -o -iname \*.png -o -iname \*.gif \) | sed 's/^\.//g' | sed -n '7001,10000p' | sed "s/$/ 1/" >> dataset_12c/test.txt

find ./2/ -type f \( -iname \*.jpg -o -iname \*.png -o -iname \*.gif \) | sed 's/^\.//g' | sed -n '1,5600p' | sed "s/$/ 2/" >> dataset_12c/train.txt
find ./2/ -type f \( -iname \*.jpg -o -iname \*.png -o -iname \*.gif \) | sed 's/^\.//g' | sed -n '5601,8000p' | sed "s/$/ 2/" >> dataset_12c/test.txt

find ./3/ -type f \( -iname \*.jpg -o -iname \*.png -o -iname \*.gif \) | sed 's/^\.//g' | sed -n '1,7000p' | sed "s/$/ 3/" >> dataset_12c/train.txt
find ./3/ -type f \( -iname \*.jpg -o -iname \*.png -o -iname \*.gif \) | sed 's/^\.//g' | sed -n '7001,10000p' | sed "s/$/ 3/" >> dataset_12c/test.txt

find ./4/ -type f \( -iname \*.jpg -o -iname \*.png -o -iname \*.gif \) | sed 's/^\.//g' | sed -n '1,8400p' | sed "s/$/ 4/" >> dataset_12c/train.txt
find ./4/ -type f \( -iname \*.jpg -o -iname \*.png -o -iname \*.gif \) | sed 's/^\.//g' | sed -n '8401,12000p' | sed "s/$/ 4/" >> dataset_12c/test.txt

find ./5/ -type f \( -iname \*.jpg -o -iname \*.png -o -iname \*.gif \) | sed 's/^\.//g' | sed -n '1,8400p' | sed "s/$/ 5/" >> dataset_12c/train.txt
find ./5/ -type f \( -iname \*.jpg -o -iname \*.png -o -iname \*.gif \) | sed 's/^\.//g' | sed -n '8401,12000p' | sed "s/$/ 5/" >> dataset_12c/test.txt

find ./6/ -type f \( -iname \*.jpg -o -iname \*.png -o -iname \*.gif \) | sed 's/^\.//g' | sed -n '1,8400p' | sed "s/$/ 6/" >> dataset_12c/train.txt
find ./6/ -type f \( -iname \*.jpg -o -iname \*.png -o -iname \*.gif \) | sed 's/^\.//g' | sed -n '8401,12000p' | sed "s/$/ 6/" >> dataset_12c/test.txt

find ./7/ -type f \( -iname \*.jpg -o -iname \*.png -o -iname \*.gif \) | sed 's/^\.//g' | sed -n '1,6750p' | sed "s/$/ 7/" >> dataset_12c/train.txt
find ./7/ -type f \( -iname \*.jpg -o -iname \*.png -o -iname \*.gif \) | sed 's/^\.//g' | sed -n '6751,9670p' | sed "s/$/ 7/" >> dataset_12c/test.txt

find ./8/ -type f \( -iname \*.jpg -o -iname \*.png -o -iname \*.gif \) | sed 's/^\.//g' | sed -n '1,6750p' | sed "s/$/ 8/" >> dataset_12c/train.txt
find ./8/ -type f \( -iname \*.jpg -o -iname \*.png -o -iname \*.gif \) | sed 's/^\.//g' | sed -n '6751,9670p' | sed "s/$/ 8/" >> dataset_12c/test.txt

find ./9/ -type f \( -iname \*.jpg -o -iname \*.png -o -iname \*.gif \) | sed 's/^\.//g' | sed -n '1,5500p' | sed "s/$/ 9/" >> dataset_12c/train.txt
find ./9/ -type f \( -iname \*.jpg -o -iname \*.png -o -iname \*.gif \) | sed 's/^\.//g' | sed -n '5501,7900p' | sed "s/$/ 9/" >> dataset_12c/test.txt

find ./10/ -type f \( -iname \*.jpg -o -iname \*.png -o -iname \*.gif \) | sed 's/^\.//g' | sed -n '1,5500p' | sed "s/$/ 10/" >> dataset_12c/train.txt
find ./10/ -type f \( -iname \*.jpg -o -iname \*.png -o -iname \*.gif \) | sed 's/^\.//g' | sed -n '5501,7900p' | sed "s/$/ 10/" >> dataset_12c/test.txt

find ./11/ -type f \( -iname \*.jpg -o -iname \*.png -o -iname \*.gif \) | sed 's/^\.//g' | sed -n '1,5100p' | sed "s/$/ 11/" >> dataset_12c/train.txt
find ./11/ -type f \( -iname \*.jpg -o -iname \*.png -o -iname \*.gif \) | sed 's/^\.//g' | sed -n '5101,7300p' | sed "s/$/ 11/" >> dataset_12c/test.txt


#测试集图片格式转换：
rm testset1/Thumbs.db
[root@docker03 ~]# ls ./testset1/*.jpg | wc -l
8062
[root@docker03 ~]# ls ./testset1/*.png | wc -l
223
[root@docker03 ~]# ls ./testset1/*.gif | wc -l
159



aws s3 ls s3://yangjj-share01

aws s3 cp s3://yangjj-share01/bot_image_test_1.rar ./

aws s3 cp s3://yangjj-share01/snapshot_iter_50000.caffemodel ./

aws s3 rm s3://yangjj-share01/cat.zip
aws s3 rm s3://yangjj-share01/chipmunk.zip
aws s3 rm s3://yangjj-share01/dog.zip
aws s3 rm s3://yangjj-share01/fox.zip
aws s3 rm s3://yangjj-share01/giraffe.zip
aws s3 rm s3://yangjj-share01/guinea_pig.zip
aws s3 rm s3://yangjj-share01/hyena.zip
aws s3 rm s3://yangjj-share01/reindeer.zip
aws s3 rm s3://yangjj-share01/sikadeer.zip
aws s3 rm s3://yangjj-share01/squirrel.zip
aws s3 rm s3://yangjj-share01/weasel.zip
aws s3 rm s3://yangjj-share01/wolf

unrar x -r ./bot_image_test_1.rar 


mkdir 0_gif
mkdir 1_gif
mkdir 2_gif
mkdir 3_gif
mkdir 4_gif
mkdir 5_gif
mkdir 6_gif
mkdir 7_gif
mkdir 8_gif
mkdir 9_gif
mkdir 10_gif
mkdir 11_gif


mv 0/*.gif 0_gif/
mv 1/*.gif 1_gif/
mv 2/*.gif 2_gif/
mv 3/*.gif 3_gif/
mv 4/*.gif 4_gif/
mv 5/*.gif 5_gif/
mv 6/*.gif 6_gif/
mv 7/*.gif 7_gif/
mv 8/*.gif 8_gif/
mv 9/*.gif 9_gif/
mv 10/*.gif 10_gif/
mv 11/*.gif 11_gif/
mv testset2/*.gif ./testset2_gif/

rm -r 0_gif/*.gif
rm -r 1_gif/*.gif
rm -r 2_gif/*.gif
rm -r 3_gif/*.gif
rm -r 4_gif/*.gif
rm -r 5_gif/*.gif
rm -r 6_gif/*.gif
rm -r 7_gif/*.gif
rm -r 8_gif/*.gif
rm -r 9_gif/*.gif
rm -r 10_gif/*.gif
rm -r 11_gif/*.gif

cp 0_gif/*.png 0/
cp 1_gif/*.png 1/
cp 2_gif/*.png 2/
cp 3_gif/*.png 3/
cp 4_gif/*.png 4/
cp 5_gif/*.png 5/
cp 6_gif/*.png 6/
cp 7_gif/*.png 7/
cp 8_gif/*.png 8/
cp 9_gif/*.png 9/
cp 10_gif/*.png 10/
cp 11_gif/*.png 11/


#20160909 21:53
#
cp -r 2/ 0908_img_bak/
cp -r 3/ 0908_img_bak/
cp -r 4/ 0908_img_bak/
cp -r 5/ 0908_img_bak/
cp -r 6/ 0908_img_bak/
cp -r 7/ 0908_img_bak/
cp -r 8/ 0908_img_bak/
cp -r 9/ 0908_img_bak/
cp -r 10/ 0908_img_bak/
cp -r 11/ 0908_img_bak/

#20160910
rm -r 0/*.gif
rm -r 1/*.gif
rm -r 2/*.gif
rm -r 3/*.gi
rm -r 4/*.gif
rm -r 5/*.gif
rm -r 6/*.gif
rm -r 7/*.gif
rm -r 8/*.gif
rm -r 9/*.gif
rm -r 10/*.gif
rm -r 11/*.gif

#
find ./0/ -iname "*.gif" | wc -l
find ./1/ -iname "*.gif" | wc -l
find ./2/ -iname "*.gif" | wc -l
find ./3/ -iname "*.gif" | wc -l
find ./4/ -iname "*.gif" | wc -l
find ./5/ -iname "*.gif" | wc -l
find ./6/ -iname "*.gif" | wc -l
find ./7/ -iname "*.gif" | wc -l
find ./8/ -iname "*.gif" | wc -l
find ./9/ -iname "*.gif" | wc -l
find ./10/ -iname "*.gif" | wc -l
find ./11/ -iname "*.gif" | wc -l

#
mv testset1/*.gif testset1_gif/
rm -r testset1_gif/*.gif
$ ls testset1/* | wc -l
8360
cp -r testset1_gif/*.png testset1/
$ ls testset1/* | wc -l
8519

#
mv 0 0910_img/
mv 1 0910_img/
mv 2 0910_img/
mv 3 0910_img/
mv 4 0910_img/
mv 5 0910_img/
mv 6 0910_img/
mv 7 0910_img/
mv 8 0910_img/
mv 9 0910_img/
mv 10 0910_img/
mv 11 0910_img/

#create lmdb
export caffe_root='/home/sjkxb/Downloads/tools/caffe-master/'
$caffe_root/build/tools/convert_imageset -shuffle -resize_height=256 -resize_width=256 \
 ./0910_img/ ./lmdb_0910/train.txt ./lmdb_0910/train_lmdb
$caffe_root/build/tools/convert_imageset -shuffle -resize_height=256 -resize_width=256 \
 ./0910_img/ ./lmdb_0910/test.txt ./lmdb_0910/test_lmdb
$caffe_root/build/tools/compute_image_mean ./lmdb_0910/train_lmdb/ ./lmdb_0910/mean.binaryproto

#train 2016-09-10
./model_bak_0908/snapshot_iter_50000.caffemodel
export caffe_root='/home/sjkxb/Downloads/tools/caffe-master/'
$caffe_root/build/tools/caffe train -solver ./solver_bot20160908_12c.prototxt -weights ../model_bak_0908/snapshot_iter_50000.caffemodel  -gpu 0

#upload model
aws s3 ls s3://yangjj-share01
aws s3 cp snapshot_iter_50000.caffemodel  s3://yangjj-share01/


#download model to ec2
aws s3 cp s3://yangjj-share01/snapshot_iter_30000.caffemodel ./model_0908_12c
mv model_0908_12c/snapshot_iter_50000.caffemodel model_0908_12c/snapshot_iter_50000.caffemodel.bak
mv model_0908_12c/mean.npy model_0908_12c/mean.npy.bak
rm model_0908_12c/mean.binaryproto
cd /opt
ls -tl model_0908_12c
rm model_0908_12c/caffe_predict_top2_scroces_bot_gpu.py 
mv model_0908_12c/snapshot_iter_30000.caffemodel model_0908_12c/snapshot_iter_50000.caffemodel
#convert npy
docker start 056e
docker exec -it 056e bash
python convert_mean_to_npy.py ./mean_0910.binaryproto.0910 ./model_0908_12c/mean.npy
#run predict
nohup python nolog_caffe_predict_top2_scroces_bot_gpu.py ./testset1 ./0910.log &
cat nohup.out | wc -l
mv nohup.out nohup_0910_t1.out
zip nohup_0910_t1.out.zip nohup_0910_t1.out

#do testset2
mv model_0908_12c/snapshot_iter_50000.caffemodel model_0908_12c/snapshot_iter_30000.caffemodel.bak
aws s3 cp s3://yangjj-share01/snapshot_iter_50000.caffemodel ./model_0908_12c
nohup python nolog_caffe_predict_top2_scroces_bot_gpu.py ./testset2 ./0910.log &
ls -tl
mv nohup.out nohup_0910_t2.out
sudo zip nohup_0910_t2.out.zip nohup_0910_t2.out
sz nohup_0910_t2.out.zip

#过滤图片类型
.jpg .jpeg .png .gif

#modify the fc8-re to fc8-0910
$caffe_root/build/tools/caffe train -solver ./solver_bot20160908_12c.prototxt -weights ./pretrain_model/snapshot_iter_50000.caffemodel -gpu 0

#使用pycaffe
for req in $(cat requirements.txt); do pip install $req; done
export PYTHONPATH=/home/sjkxb/Downloads/tools/caffe-master/python:$PYTHONPATH
export PYTHONPATH=/home/sjkxb/Downloads/tools/caffe-master/python

#fix  Intel MKL FATAL ERROR: Cannot load libmkl_avx2.so or libmkl_def.so
conda install nomkl numpy scipy scikit-learn numexpr
conda remove mkl mkl-service

#install docker
wget https://get.docker.com/builds/Linux/x86_64/docker-latest.tgz
tar -xvzf docker-latest.tgz

#2016-09-11
root@sjkxb-Default-string:/data/bot_img# find ./0910_img/ -iname "*" | wc -l
127490
root@sjkxb-Default-string:/data/bot_img# find ./0910_img/ -iname "*.jpg" | wc -l
122886
root@sjkxb-Default-string:/data/bot_img# find ./0910_img/ -iname "*.jpeg" | wc -l
1377
root@sjkxb-Default-string:/data/bot_img# find ./0910_img/ -iname "*.png" | wc -l
3214
root@sjkxb-Default-string:/data/bot_img# find ./0910_img/ -iname "*.gif" | wc -l
0
#make testset1
cat testset2_0911_01.txt | sort -k2 -n | wc -l

#setup the deploy.prototxt
layer:fc8-0910
/usr/bin/python convert_mean_to_npy.py ./lmdb_0910/mean_0910.binaryproto ./model_0910/pretrain_model/mean.npy
/usr/bin/python caffe_predict.py ./custom_test_imgs

#make 0911 testset
$caffe_root/build/tools/convert_imageset -shuffle -resize_height=256 -resize_width=256 ./testset1_nogif/ test_datasets_labels/testset_t1_0911.txt  ./test_lmdb

#train data 0911 , testset = bot test1 sets
/data/bot_img/lmdb_0911/mean_lmdb_0911.binaryproto
/data/bot_img/model_0911
cd /data/bot_img/model_0911
$caffe_root/build/tools/caffe train -solver ./solver_model_0911.prototxt -weights ./snapshot_iter_300000.caffemodel -gpu 0
cat nohup.out | grep 'Test\snet\soutput'

snapshot_iter_50000.0911_1838.caffemodel
#0216.09.12
/cygdrive/c/Python27/python.exe 
$caffe_root/build/tools/convert_imageset -shuffle true -resize_height=256 -resize_width=256 /data/bot_img/img_0910 ./test_datasets_labels/sorted_t2_and_base_r1500_lmdb_labels.txt ./lmdb_0912/test_lmdb
snapshot_iter_50000.0911_1838.caffemodel
nohup $caffe_root/build/tools/caffe train -solver ./solver_model_0912.prototxt -weights ./snapshot_iter_50000.0911_1838.caffemodel  -gpu 0 &

#2016.09.12 21:03
root@sjkxb-Default-string:/data/bot_img# find ./img_0910/ -iname "*.jpg" | wc -l
149382
root@sjkxb-Default-string:/data/bot_img# find ./img_0910/ -iname "*.jpeg" | wc -l
1701
root@sjkxb-Default-string:/data/bot_img# find ./img_0910/ -iname "*.png" | wc -l
4991
root@sjkxb-Default-string:/data/bot_img# find ./img_0910/ -iname "*.gif" | wc -l
0
root@sjkxb-Default-string:/data/bot_img# date
2016年 09月 12日 星期一 20:59:27 CST
root@sjkxb-Default-string:/data/bot_img# 


#
ls ../img_0910/0/ | wc -l
ls ../img_0910/1/ | wc -l
ls ../img_0910/2/ | wc -l
ls ../img_0910/3/ | wc -l
ls ../img_0910/4/ | wc -l
ls ../img_0910/5/ | wc -l
ls ../img_0910/6/ | wc -l
ls ../img_0910/7/ | wc -l
ls ../img_0910/8/ | wc -l
ls ../img_0910/9/ | wc -l
ls ../img_0910/10/ | wc -l
ls ../img_0910/11/ | wc -l

#图片类别分布情况：
root@sjkxb-Default-string:/data/bot_img/test_datasets_labels# ls ../img_0910/0/ | wc -l
13556
root@sjkxb-Default-string:/data/bot_img/test_datasets_labels# ls ../img_0910/0/ | wc -l
13556
root@sjkxb-Default-string:/data/bot_img/test_datasets_labels# ls ../img_0910/1/ | wc -l
11537
root@sjkxb-Default-string:/data/bot_img/test_datasets_labels# ls ../img_0910/2/ | wc -l
9725
root@sjkxb-Default-string:/data/bot_img/test_datasets_labels# ls ../img_0910/3/ | wc -l
11781
root@sjkxb-Default-string:/data/bot_img/test_datasets_labels# ls ../img_0910/4/ | wc -l
14348
root@sjkxb-Default-string:/data/bot_img/test_datasets_labels# ls ../img_0910/5/ | wc -l
12550
root@sjkxb-Default-string:/data/bot_img/test_datasets_labels# ls ../img_0910/6/ | wc -l
14021
root@sjkxb-Default-string:/data/bot_img/test_datasets_labels# ls ../img_0910/7/ | wc -l
11085
root@sjkxb-Default-string:/data/bot_img/test_datasets_labels# ls ../img_0910/8/ | wc -l
11871
root@sjkxb-Default-string:/data/bot_img/test_datasets_labels# ls ../img_0910/9/ | wc -l
9035
root@sjkxb-Default-string:/data/bot_img/test_datasets_labels# ls ../img_0910/10/ | wc -l
9297
root@sjkxb-Default-string:/data/bot_img/test_datasets_labels# ls ../img_0910/11/ | wc -l
8676
