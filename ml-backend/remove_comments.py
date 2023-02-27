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
