import json
import os
os.environ['TF_CPP_MIN_LOG_LEVEL'] = '3' 
import numpy as np
import tensorflow as tf
from tensorflow import keras
from tensorflow.python.keras import layers
import matplotlib.pyplot as plt

def load_data(path):
    files = os.listdir(path)
    data = {}
    for file in files:
        with open(path + file) as f:
            data[file[:-9]] = {"emb":np.array(json.loads(f.read())["data"][0]['embedding'])}
    return data

embs = load_data('./embeddings/')
with open('./scraping/data/allprots.json') as f:
    data = json.loads(f.read())
for i in range(len(data)):
    if data[i]["slug"] in embs:  
        embs[data[i]["slug"]]["category"] = data[i]["category"]

categories = [emb["category"] for emb in embs.values()]
categories = list(dict.fromkeys(categories))
print(categories)

cat_eye = np.eye(len(categories))
def one_hot_encode(category):
    return cat_eye[categories.index(category)]

samples = [[emb["emb"], one_hot_encode(emb["category"])] for emb in embs.values()]
emb_size = len(samples[0][0])
def make_model():
    model = tf.keras.Sequential()
    # model.add(layers.Dense(len(categories), activation='softmax', input_shape=(len(samples[0][0]),)))
    model.add(layers.Dense(64, activation='relu', input_shape=(emb_size,)))
    model.add(layers.Dense(2))
    model.add(layers.ReLU())
    model.add(layers.Dense(len(categories), activation='softmax'))
    model.compile(optimizer=keras.optimizers.Adam(learning_rate=0.00001),
                  loss='categorical_crossentropy',
                  metrics=['accuracy'])
    return model

def train(samples, model):
    X = np.array([sample[0] for sample in samples])
    Y = np.array([sample[1] for sample in samples])
    model.fit(X, Y, epochs=400, batch_size=32)
    model.optimizer.lr = 0.001
    model.fit(X, Y, epochs=400, batch_size=32)
    model.optimizer.lr = 0.00001
    model.fit(X, Y, epochs=500, batch_size=32)
    return model

train_set, test_set = samples[:int(len(samples)*0.8)], samples[int(len(samples)*0.8):]

model = make_model()

if True:
    model = train(train_set, model)
    model.save_weights('./model.h5')
else:
    model.build((None, emb_size))
    model.load_weights('./model.h5')

def eval(samples, model):
    X = np.array([sample[0] for sample in samples])
    Y = np.array([sample[1] for sample in samples])
    predicted = np.argmax(model.predict(X), axis=1)
    true = np.argmax(Y, axis=1)
    correct = np.sum(predicted == true)
    print("xddd", predicted, true)
    print("haha", correct/len(samples), correct, len(samples))

eval(train_set, model)
eval(test_set, model)


def to_2d(emb, model):
    y = model.layers[0](emb)
    y = model.layers[1](y)
    return y.numpy()

def plot(samples, model, name):
  plt.figure()
  red = to_2d(np.array([sample[0] for sample in samples]), model)
  plt.scatter(red[:,0], red[:,1], c=[np.argmax(sample[1]) for sample in samples], cmap='tab20')
  plt.savefig('plot_'+name+'.png')

plot(samples, model, 'all')
plot(train_set, model, 'train')
plot(test_set, model, 'test')
