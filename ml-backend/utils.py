import openai
from settings import OPENAI_SECRET_KEY
openai.api_key = OPENAI_SECRET_KEY

def embed(text):
  print("Embedding text")
  model_id = "text-embedding-ada-002"
  embedding = openai.Embedding.create(input=text, engine=model_id)
  return embedding

import pickle

def save_model(model, filename):
  pickle.dump(model, open(filename, 'wb'))

def load_model(filename):
  return pickle.load(open(filename, 'rb'))

