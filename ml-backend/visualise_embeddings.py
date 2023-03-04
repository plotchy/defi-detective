import os
import json
import random
import numpy as np
from scipy import linalg as LA
from matplotlib import pyplot as MPL

def PCA(data):
    data -= data.mean(axis=0)
    R = np.cov(data, rowvar=False)
    evals, evecs = LA.eigh(R)
    idx = np.argsort(evals)[::-1]
    evecs = evecs[:,idx]
    evecs = evecs[:, :2]
    data_resc = np.dot(evecs.T, data.T).T
    with open('evecs.json', 'w') as f:
        f.write(json.dumps(evecs.tolist()))
    return data_resc[:, 0], data_resc[:, 1]

def plot_pca(xs, ys, labels):
    clr1 =  '#2026B2'
    fig = MPL.figure()
    ax1 = fig.add_subplot(111)
    ax1.plot(xs, ys, '.', mfc=clr1, mec=clr1)
    for i, txt in enumerate(labels):
        if txt == 'uniswap-v2' or txt == 'olympus-dao' or txt == 'sushiswap' or random.random() < 0.05:
            ax1.annotate(txt, (xs[i], ys[i]))
    MPL.savefig("pca.png")

def load_data(path):
    files = os.listdir(path)
    data = []
    for file in files:
        with open(path + file) as f:
            data.append(json.loads(f.read())["data"][0]['embedding'])
    names = [file[:-9] for file in files]
    return names, data

names, data = load_data('./embeddings/')
data = np.array(data)
xs, ys = PCA(data)

plot_pca(xs, ys, names)

files = os.listdir('./00/')
def get_address(name):
    for f in files:
        if name in f:
            print(name, " in ", f)
            return f[:40]

with open ('pca.json', 'w') as f:
    data_json = [({"name":name, "position": list(data), "address": get_address(name)}) for name, data in zip(names, zip(xs, ys))]
    f.write(json.dumps(data_json))

