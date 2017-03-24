from flask import Flask,jsonify
from flask import request
from flask import render_template
from dicom_cube_process import online_predict


app = Flask(__name__)


@app.route('/papaya', methods=['GET'])
def get_papaya():
    # print('get')
    # print(url_for('static', filename='papaya.css'))
    # print(url_for('static', filename='papaya.js'))
    return render_template('index.html')


@app.route('/json', methods=['POST'])
def get_json():
    pid = request.form.get('pid')
    z = request.form.get('z')
    y = request.form.get('y')
    x = request.form.get('x')
    print('pid_z_y_x',pid,z,y,x)
    result = online_predict(pid,int(z),int(y),int(x))
    predicts = str(result[0,0])+','+str(result[0,1])
    result_json = {'result': predicts}
    return jsonify(result_json)


if __name__ == '__main__':
    app.run(debug=True,host= '0.0.0.0')


