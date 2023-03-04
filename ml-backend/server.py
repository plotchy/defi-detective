from flask import Flask, request
from remove_comments import remove_noise
app = Flask(__name__)

@app.route('/')
def hello():
  address = request.args.get('address')
  with open('../00byaddress/'+address+'.sol') as f:
    code = f.read()
  code = remove_noise(code)
  return code

if __name__ == '__main__':
  app.run()