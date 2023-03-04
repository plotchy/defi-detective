import json
import os
from pathlib import Path
from flask import Flask, request
from remove_comments import remove_noise
from utils import embed
import numpy as np

app = Flask(__name__)

with open('evecs.json') as f:
  evecs = json.loads(f.read())
evecs = np.array(evecs)

@app.route('/')
def pca():
  address = request.args.get('address')
  print("address", './00byaddress/'+address+'.sol')
  if not os.path.exists('./00byaddress/'+address+'.sol'):
    return json.dumps({"error": "Address not found"})

  if os.path.exists('./addr_embeddings/'+address):
    with open('./addr_embeddings/'+address) as f:
      embedding = json.loads(f.read())
  else:
    with open('./00byaddress/'+address+'.sol') as f:
      code = f.read()
    code = remove_noise(code)
    embedding = embed(code)["data"][0]["embedding"]
    with open('./addr_embeddings/'+address, 'w') as f:
      f.write(json.dumps(embedding))
  
  embedding=np.array(embedding)
  pca = np.dot(evecs.T, embedding.T).T
  
  return json.dumps(pca.tolist())

if __name__ == '__main__':
  app.run()