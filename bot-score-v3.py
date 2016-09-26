
# coding: utf-8

# In[4]:

#-*-coding;utf-8-*-
def readcsv2dict(path):     ###把文件转换成字典返回，以第一列值为key，其余值为value
    try:
        fl=open(path,'r').read()
        lis1= fl.split('\n')
        lis2=[i.split('\t') for i in lis1]
        dic={i[0]:i[1:] for i in lis2} 
    except:
        print '文件格式错误'
    try:
        del dic['']
    except:
        pass
    return dic


def scoring(answer,test):   ###对提交的文件进行计分
    score=0
    for i in test.keys():  
        
        try :   
            if answer[i][0]==answer[i][1] or answer[i][1]=='':#只有一个动物的题目
                ###计分条件((top1在答案中)*(0<=top1置信度<=1)*1.0+(top2在答案中)*(0<=top2置信度<=1)*0.4)*(top1置信度<=top2置信度)*(top1<>top2)*(是否隐藏题目)
                score+=((test[i][0] in answer[i][:2])*(float(test[i][1])<=1 and float(test[i][1])>=0)*1.0+(test[i][2] in answer[i][:2])*(float(test[i][3])<=1 and float(test[i][3])>=0)*0.4)*(float(test[i][3])<=float(test[i][1]))*bool(not(test[i][0] == test[i][2]))*(1+(answer[i][2]=='1'))
            else:#两个动物的题目
                ###同上，最后判断是否隐藏题目的条件多一条判断是否两个答案都对。
                score+=((test[i][0] in answer[i][:2])*(float(test[i][1])<=1 and float(test[i][1])>=0)*1.0+(test[i][2] in answer[i][:2])*(float(test[i][3])<=1 and float(test[i][3])>=0)*0.4)*(float(test[i][3])<=float(test[i][1]))*bool(not(test[i][0] == test[i][2]))*(1+(answer[i][2]=='1')*((test[i][0] in answer[i][:2])and(test[i][2] in answer[i][:2])))

        except KeyError:
            score+=0.0

            
    return  score#"%.3f%%"  %(score/len(answer)*100)

answer= readcsv2dict('E:\\caffe\\0926\\BOT_Image_Testset 6.txt')    ###存放答案的文件
test= readcsv2dict('E:\\caffe\\0926\\0925.t6.res101.txt')      ###参赛者提交的答案

print 'the player No1 score is '+ str(scoring(answer,test))





# In[ ]:



