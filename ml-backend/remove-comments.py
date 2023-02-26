
import os
import re

def remove_comments(string):
    pattern = r"(\".*?\"|\'.*?\')|(/\*.*?\*/|//[^\r\n]*$)"
    # first group captures quoted strings (double or single)
    # second group captures comments (//single-line or /* multi-line */)
    regex = re.compile(pattern, re.MULTILINE|re.DOTALL)
    def _replacer(match):
        # if the 2nd group (capturing comments) is not None,
        # it means we have captured a non-quoted (real) comment string.
        if match.group(2) is not None:
            return "" # so we will return empty to remove the comment
        else: # otherwise, we will return the 1st group
            return match.group(1) # captured quoted-string
    return regex.sub(_replacer, string)

if not os.path.exists('../contracts_no_comments'):
    os.makedirs('../contracts_no_comments')
contracts = os.listdir('../contracts')
for contract in contracts:
    with open('../contracts/' + contract, 'r') as f:
        contract_text = f.read()
        contract_text_no_comments = remove_comments(contract_text)
        contract_text_no_comments = os.linesep.join([s for s in contract_text_no_comments.splitlines() if s.strip()])
        # remove pragma solidity lines
        contract_text_no_comments = os.linesep.join([s for s in contract_text_no_comments.splitlines() if not s.startswith('pragma solidity')])
        with open('../contracts_no_comments/' + contract, 'w') as f2:
            f2.write(contract_text_no_comments)