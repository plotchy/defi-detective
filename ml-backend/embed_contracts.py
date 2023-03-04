import os
import random
from utils import embed
from remove_comments import remove_noise
import json

source_path = './00/'
files = os.listdir(source_path)
random.shuffle(files)

def get_contracts():
    contracts = {}
    for file in files:
        with open(os.path.join(source_path, file), "r") as f:
            text = remove_noise(f.read())
            if text.strip() != "":
                contracts[file[41:]] = text
    return contracts


contracts = get_contracts()
for name, contract in list(contracts.items())[:200]:
    if os.path.exists("./embeddings/"+name+".json"):
        continue
    print("Embedding contract: ", name)
    try:
        embedding = embed(contract)
    except Exception as e:
        print(e)
        continue
    with open("./embeddings/"+name+".json", "w") as f:
        f.write(json.dumps(embedding))
