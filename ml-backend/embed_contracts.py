# read contracts from ../contracts/

import os

def get_contracts():
    contracts = {}
    for file in os.listdir("../contracts/"):
        with open(os.path.join("../contracts/", file), "r") as f:
            contracts[file] = f.read()
    return contracts

# embed contracts
from utils import embed, save_model

contracts = get_contracts()
embeddings = {}
for name, contract in contracts.items():
    embeddings[name] = embed(contract)

save_model(embeddings, "contract_embeddings.pkl")