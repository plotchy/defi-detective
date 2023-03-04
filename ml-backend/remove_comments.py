import os
import re

pattern = r"(\".*?\"|\'.*?\')|(/\*.*?\*/|//[^\r\n]*$)"
regex = re.compile(pattern, re.MULTILINE|re.DOTALL)

def _replacer(match):
    if match.group(2) is not None:
        return ""
    else:
        return match.group(1)

def remove_comments(text):
    text = regex.sub(_replacer, text)
    text = os.linesep.join([s for s in text.splitlines() if s.strip()])
    text = os.linesep.join([s for s in text.splitlines() if not s.startswith('pragma ')])
    return text

def rem(items, pattern):
    return [item for item in items if pattern not in item]
def remove_libs(text):    
    contracts = text.split('\n}')[0:-1]
    contracts = [contract.strip() + '\n}' for contract in contracts]
    contracts = rem(contracts, 'library ')
    contracts = rem(contracts, 'interface')
    contracts = rem(contracts, 'abstract contract ')
    contracts = rem(contracts, 'contract ERC20')
    contracts = rem(contracts, 'contract ERC721')
    return '\n'.join(contracts)


def remove_noise(text):
    text = remove_comments(text)
    text = remove_libs(text)
    return text


if __name__ == "__main__":
    with open('./scraping/data/source/1inch-network.sol', 'r') as f:
        text = f.read()
        text = remove_comments(text)
        text = remove_libs(text)
    with open('./1inch-network.sol', 'w') as f:
        f.write(text)
