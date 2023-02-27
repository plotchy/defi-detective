import os
import json
import numpy as np
from scipy import linalg as LA


def PCA(data, dims_rescaled_data=2):
    """
    returns: data transformed in 2 dims/columns + regenerated original data
    pass in: data as 2D NumPy array
    """
    m, n = data.shape
    # mean center the data
    data -= data.mean(axis=0)
    # calculate the covariance matrix
    R = np.cov(data, rowvar=False)
    # calculate eigenvectors & eigenvalues of the covariance matrix
    # use 'eigh' rather than 'eig' since R is symmetric, 
    # the performance gain is substantial
    evals, evecs = LA.eigh(R)
    # sort eigenvalue in decreasing order
    idx = np.argsort(evals)[::-1]
    evecs = evecs[:,idx]
    # sort eigenvectors according to same index
    evals = evals[idx]
    # select the first n eigenvectors (n is desired dimension
    # of rescaled data array, or dims_rescaled_data)
    evecs = evecs[:, :dims_rescaled_data]
    # carry out the transformation on the data using eigenvectors
    # and return the re-scaled data, eigenvalues, and eigenvectors
    return np.dot(evecs.T, data.T).T, evals, evecs

def plot_pca(data_resc, labels):
    from matplotlib import pyplot as MPL
    clr1 =  '#2026B2'
    fig = MPL.figure()
    ax1 = fig.add_subplot(111)
    ax1.plot(data_resc[:, 0], data_resc[:, 1], '.', mfc=clr1, mec=clr1)
    for i, txt in enumerate(labels):
        if i % 10 == 0:
            ax1.annotate(txt, (data_resc[i, 0], data_resc[i, 1]))
    MPL.savefig("pca.png")

def load_data(path):
    files = os.listdir(path)
    data = {}
    for file in files:
        with open(path + file) as f:
            data[file] = json.loads(f.read())["data"][0]['embedding']
    
    return data

data = load_data('./embeddings/')
names = [name for name, emb in data.items()]
data_matrix = np.array([emb for name, emb in data.items()])
data_resc, _eigenvals, _eigenvecs = PCA(data_matrix)

plot_pca(data_resc, names)


data_json = {name[:-9]: list(data) for name, data in zip(names, data_resc)}
with open ('pca.json', 'w') as f:
    f.write(json.dumps(data_json))

