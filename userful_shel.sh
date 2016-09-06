cat caffe.log | awk -F"\t" '$1 ~ /cat/{print}' | awk -F"\t" '$2 !~ /cat/{print}' | more
