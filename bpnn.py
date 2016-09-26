# -*- coding:utf-8 -*-
'''
使用python完成的后向传播网络
back propagation network by python
'''

import math
import random
import string

import matplotlib.pyplot as plt

def rand(a,b):
    '''

    :param a:   the small number of data to be randomed
    :param b:   the big number of data to be randomed
    :return:    one number random between [a,b]
    '''
    return (b-a)*random.random()+a

def makeMatrix(i,j,fill=0.0):
    '''
      create a matrix
    :param i:        the raw size of the matrix to be created
    :param j:        the column size of the matrix to be created
    :param fill:      the initial value of the matrix
    :return:         a list stand for new matrix like {[0,0,0],[0,0,0],...}
    '''

    m = []
    for a in range(i):
        m.append([fill]*j)
    return m

def sigmod(x):
    '''
    the sigmod function,tanh is a little better than the standard  1/(1+e^-x)
    :param x:    the self variable
    :return:     the value after tanh
    '''
    return math.tanh(x)

def dsigmod(y):
    '''
    sigmod函数的导数。  the derivative of our sigmod function ,in terms of the output (like y)
    :param y:      the output
    :return:        the derivative of sigmod function when output is y
    '''
    return 1.0-y**2

class NN:
    def __init__(self,ni,nh,no):
        '''
        神经网络初始化 initial the network
        :param ni:    the size of input layer
        :param nh:    the size of hidden layer
        :param no:    the size of output layer
        '''
        self.ni = ni+1  #add 1 for bias node
        self.nh = nh
        self.no = no

        # activations for nodes
        self.ai = [1.0]*self.ni
        self.ah = [1.0]*self.nh
        self.ao = [1.0]*self.no

        # create the weight matrix
        self.wi = makeMatrix(self.ni,self.nh)
        self.wo = makeMatrix(self.nh,self.no)

        # set them to random value
        for i in range(self.ni):
            for j in range(self.nh):
                self.wi[i][j] = rand(-0.2,0.2)
        for m in range(self.nh):
            for n in range(self.no):
                self.wo[m][n] = rand(-2.0,2.0)

        # last change in weight for momentum
        self.ci = makeMatrix(self.ni,self.nh)
        self.co = makeMatrix(self.nh,self.no)

    def update(self,inputs):
        '''
           update the input layer,hidden layer,output layer params

        :param inputs:  the input of bp-network
        :return:        the output of bp-network
        '''

        assert  len(inputs)==self.ni-1

        # input activations
        for i in range(self.ni-1):
            self.ai[i] = inputs[i]

        # hidden activations
        for j in range(self.nh):
            sum = 0.0
            for i in range(self.ni):
                sum = sum +self.ai[i]*self.wi[i][j]
            self.ah[j] = sigmod(sum)

        # output activations
        for k in range(self.no):
            sum = 0.0
            for j in range(self.nh):
                sum = sum + self.ah[j]*self.wi[j][k]
            self.ao[k] = sigmod(sum)

        return self.ao[:]

    def backPropagate(self,targets,learning_rate,M):

        assert len(targets)==self.no

        # calculate error  terms for output
        output_deltas = [0.0] * self.no
        for k in range(self.no):
            error = targets[k]-self.ao[k]
            output_deltas[k] = dsigmod(self.ao[k])*error

        # calculate error terms for hidden
        hidden_deltas = [0.0]*self.nh
        for j in range(self.nh):
            error = 0.0
            for k in range(self.no):
                error = error + output_deltas[k]*self.wo[j][k]
            hidden_deltas[j] = dsigmod(self.ah[j])*error

        # update output weight
        for j in range(self.nh):
            for k in range(self.no):
                change =  output_deltas[k]*self.ah[k]
                self.wo[j][k] = self.wo[j][k]+learning_rate*change+M*self.co[j][k]
                self.co[j][k]=change
                #print "change = %f,\tM*[%d][%d] = %f "%(learning_rate*change,j,k,M*self.co[j][k])

        # update input weight
        for i in range(self.ni):
            for j in range(self.nh):
                change = hidden_deltas[j]*self.ai[i]
                self.wi[i][j] = self.wi[i][j]+learning_rate*change+M*self.ci[i][j]
                self.ci[i][j] =change

        # calculate total error
        error = 0
        for k in range(len(targets)):
            error = error +0.5*(targets[k]-self.ao[k])**2
        return error

    def test(self,patterns):
        for p in patterns:
            print (p[0],'-->',self.update(p[0]))

    def weight(self):
        print "..input weight.."
        for i in range(self.ni):
            print(self.wi[i])
        print()
        print "..output weight.."
        for j in range(self.nh):
            print(self.wo[j])

    def train(self,patterns,iterations=1000,learning_rate=0.2,M=0.1):
        '''
        train the network

        :param patterns:
        :param iterations:   迭代次数，默认为1000次
        :param learning_rate: 学习速率
        :param M:               momentum factor 动量因子
        :return:
        '''
        x = []
        loss = []
        for i in range(iterations):
            error = 0
            for p in patterns:
                input = p[0]
                targets =p[1]
                self.update(input)
                error = error +self.backPropagate(targets,learning_rate,M)
            if i%100 ==0:
                print " iterations = %d,  error = %-.4f"%(i,error)
                x.append(i)
                loss.append(error)
        plt.plot(x,loss)
        plt.show()


def demo():
    pat = [
     [[0,0],[0]],
    [[0,1],[1]],
    [[1,0],[1]],
    [[1,1],[0]]
    ]
    print '...begin to train...'
    n = NN(2,2,1)
    n.train(pat,learning_rate=0.5,M=0.1)
    print '------now test output-----'
    n.test(pat)

if __name__=='__main__':
    demo()





