from flask import Flask
from flask import request
# import datetime,json
from dicom_cube_process import online_predict



app = Flask(__name__)
#api = Api(app)


@app.route('/predict', methods=['GET'])
def get():
    slices_folder = request.args.get('slices_folder')
    z = request.args.get('z')
    y = request.args.get('y')
    x = request.args.get('x')
    print(slices_folder,z,y,x)
    result = online_predict(slices_folder,int(z),int(y),int(x))
    # print(result.shape)
    # print(result[0,0],result[0,1])
    return str(result[0,0])+','+str(result[0,1])


if __name__ == '__main__':
    app.run(debug=True,host= '0.0.0.0')
