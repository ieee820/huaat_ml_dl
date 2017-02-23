import numpy as np

trace = False
trace_forward = False

class FC:
    '''
    This class is not thread safe.
    '''
    def __init__(self, in_num, out_num, lr = 0.1):
        self._in_num = in_num
        self._out_num = out_num
        self.w = np.random.randn(in_num, out_num)
        self.b = np.zeros((out_num, 1))
        self.lr = lr
    def _sigmoid(self, in_data):
        return 1 / (1 + np.exp(-in_data))
    def forward(self, in_data):

        self.topVal = self._sigmoid(np.dot(self.w.T, in_data) + self.b)
        if trace_forward:
            print '=== topVal {0} ==='.format(self.topVal.shape)
            print self.topVal
        self.bottomVal = in_data
        return self.topVal
    def backward(self, loss):
        residual_z = loss * self.topVal * (1 - self.topVal)
        grad_w = np.dot(self.bottomVal, residual_z.T)
        grad_b = np.sum(residual_z)
        self.w -= self.lr * grad_w
        self.b -= self.lr * grad_b
        residual_x = np.dot(self.w, residual_z)
        if trace:
            print '=== z {0}==='.format(residual_z.shape)
            print residual_z
            print '=== grad_w {0}==='.format(grad_w.shape)
            print grad_w
            print '=== grad_b {0}==='.format(grad_b.shape)
            print grad_b
            print '=== self.w {0}==='.format(self.w.shape)
            print self.w
            print '=== self.b {0} ==='.format(self.b.shape)
            print self.b
            print '=== residual {0} ==='.format(residual_x.shape)
            print residual_x
        return residual_x

class SquareLoss:
    '''
    Same as above, not thread safe
    '''
    def forward(self, y, t):
        self.loss = y - t
        if trace:
            print '=== Loss ==='.format(self.loss.shape)
            print self.loss
        return np.sum(self.loss * self.loss) /  self.loss.shape[1] / 2
    def backward(self):
        if trace:
            print '=== loss {0} ==='.format(self.loss.shape)
            print self.loss
        return self.loss

class Net:
    def __init__(self, input_num=2, hidden_num=4, out_num=1, lr=0.1):
        self.fc1 = FC(input_num, hidden_num, lr)
        self.fc2 = FC(hidden_num, out_num, lr)
        self.loss = SquareLoss()
    def train(self, X, y): # X are arranged by col
        for i in range(10000):
            # forward step
            layer1out = self.fc1.forward(X)
            layer2out = self.fc2.forward(layer1out)
            loss = self.loss.forward(layer2out, y)
            if i % 1000 == 0:
                print 'iter = {0}, loss ={1}'.format(i, loss)
                print '=== Label vs Prediction ==='
                print 't={0}'.format(y)
                print 'y={0}'.format(layer2out)
            # backward step
            layer2loss = self.loss.backward()
            layer1loss = self.fc2.backward(layer2loss)
            saliency = self.fc1.backward(layer1loss)
        layer1out = self.fc1.forward(X)
        layer2out = self.fc2.forward(layer1out)
        print '=== Final ==='
        print 'X={0}'.format(X)
        print 't={0}'.format(y)
        print 'y={0}'.format(layer2out)

# example from https://mattmazur.com/2015/03/17/a-step-by-step-backpropagation-example/
X = np.array([[0.05, 0.1]]).T
y = np.array([[0.01, 0.99]]).T

net = Net(2,2,2,0.5)
net.fc1.w = np.array([[.15,.25], [.2, .3]])
net.fc1.b = np.array([[.35], [.35]])
net.fc2.w = np.array([[.4,.5], [.45,.55]])
net.fc2.b = np.array([[.6], [.6]])
net.train(X,y)


