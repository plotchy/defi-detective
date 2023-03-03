import json
import os
import numpy as np
import tensorflow as tf
from tensorflow.python.keras import layers

def load_data(path):
    files = os.listdir(path)
    data = {}
    for file in files:
        with open(path + file) as f:
            data[file[:-9]] = {"emb":np.array(json.loads(f.read())["data"][0]['embedding'])}
    return data

embs = load_data('./embeddings/')
with open('./pcacat.json') as f:
    data = json.loads(f.read())
for i in range(len(data)):
    embs[data[i]["name"]]["category"] = data[i]["category"]

categories = [emb["category"] for emb in embs.values()]
categories = list(set(categories))
print(categories)

cat_eye = np.eye(len(categories))
def one_hot_encode(category):
    return cat_eye[categories.index(category)]

samples = [[emb["emb"], one_hot_encode(emb["category"])] for emb in embs.values()]
emb_size = len(samples[0][0])
def make_model():
    model = tf.keras.Sequential()
    # model.add(layers.Dense(len(categories), activation='softmax', input_shape=(len(samples[0][0]),)))
    model.add(layers.Dense(2, activation='relu', input_shape=(emb_size,)))
    model.add(layers.Dense(len(categories), activation='softmax'))
    model.compile(optimizer='adam',
                  loss='categorical_crossentropy',
                  metrics=['accuracy'])
    return model

def train(samples, model):
    X = np.array([sample[0] for sample in samples])
    Y = np.array([sample[1] for sample in samples])
    model.fit(X, Y, epochs=10, batch_size=32)
    return model


def predict(model, sample):
    return model.predict(np.array([sample]))[0]

def predict_category(model, sample):
    return categories[np.argmax(predict(model, sample))]

train_set, test_set = samples[:int(len(samples)*0.8)], samples[int(len(samples)*0.8):]

model = train(train_set, make_model())

# model.save_weights('./model.h5')
# model = make_model()
# model.build((None, emb_size))
# model.load_weights('./model.h5')

def eval():
    correct = 0
    for sample in test_set:
        predicted = predict_category(model, sample[0])
        true = categories[np.argmax(sample[1])]
        if predicted == true:
            correct += 1
        print(predicted, true)
    print(correct/len(test_set), len(test_set))

eval()