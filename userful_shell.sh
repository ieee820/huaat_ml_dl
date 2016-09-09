cat caffe.log | awk -F"\t" '$1 ~ /cat/{print}' | awk -F"\t" '$2 !~ /cat/{print}' | more

#测试caffe prediction
python caffe_main_test02.py /root/test_dir /root/test.log

#过滤文件
find ./cat/ -iname "*.jpg" | sed -n '1,100p' | xargs cp -t ../temp/