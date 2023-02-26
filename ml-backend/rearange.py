import os
import sys
import Levenshtein 


def minimize_sum(arr):
    n, m = len(arr), len(arr[0])
    picked = set()
    row_picks = []
    row_indices = []
    for i in range(n):
        min_val, min_idx = float('inf'), None
        for j in range(m):
            if arr[i][j] < min_val and j not in picked:
                min_val = arr[i][j]
                min_idx = j
        picked.add(min_idx)
        row_picks.append(min_val)
        row_indices.append(min_idx)
    return row_indices


def rearrange(contract1_text, contract2_text):
    contracts1 = contract1_text.split('\n}')[0:-1]
    contracts2 = contract2_text.split('\n}')[0:-1]

    contracts1 = [contract.strip() + '\n}' for contract in contracts1]
    contracts2 = [contract.strip() + '\n}' for contract in contracts2]

    swapped = False
    if len(contracts1) > len(contracts2):
        contracts1, contracts2 = contracts2, contracts1
        swapped = True

    distances = []
    for i in range(len(contracts1)):
        distances.append([])
        for j in range(len(contracts2)):
            distances[i].append(Levenshtein.distance(contracts1[i], contracts2[j]))

    c1 = "\n".join(contracts1)
    indices = minimize_sum(distances)
    missing = set(range(len(contracts2))) - set(indices)
    c2 = ""
    for i in indices:
        c2 += contracts2[i]+'\n'
    for i in missing:
        c2 += contracts2[i]+'\n'
    if swapped:
        c1, c2 = c2, c1
    return c1, c2


c1_name = sys.argv[1]
c2_name = sys.argv[2]
path1 = '../contracts_no_comments/'+c1_name
path2 = '../contracts_no_comments/'+c2_name

with open(path1, 'r') as f:
    contract1_text = f.read()
with open(path2, 'r') as f:
    contract2_text = f.read()

c1, c2 = rearrange(contract1_text, contract2_text)

if not os.path.exists('../contracts_rearranged'):
    os.makedirs('../contracts_rearranged')
with open('../contracts_rearranged/'+c1_name, 'w') as f:
    f.write(c1)
with open('../contracts_rearranged/'+c2_name, 'w') as f:
    f.write(c2)
