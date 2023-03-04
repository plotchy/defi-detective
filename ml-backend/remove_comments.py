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
    text = os.linesep.join([s for s in text.splitlines() if not s.startswith('import ')])
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
    contracts = rem(contracts, 'contract Ownable')
    contracts = rem(contracts, 'contract Context')
    return '\n'.join(contracts)


def remove_noise(text):
    text = remove_comments(text)
    text = remove_libs(text)
    return text



if __name__ == "__main__":
    source_path = './00/'
    files = os.listdir(source_path)
    for file in files:
        with open(os.path.join(source_path, file), "r") as fr:
            with open(os.path.join('./cleaned', file[41:]), "w") as fw:
                fw.write(remove_noise(fr.read()))