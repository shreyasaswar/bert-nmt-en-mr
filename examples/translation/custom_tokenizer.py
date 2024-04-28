import string, re, sys

from indicnlp.common import IndicNlpException

# tokenizer patterns
triv_tokenizer_indic_pat = re.compile(r'(['+string.punctuation+r'\u0964\u0965\uAAF1\uAAF0\uABEB\uABEC\uABED\uABEE\uABEF\u1C7E\u1C7F'+r'])')
pat_num_seq = re.compile(r'([0-9]+ [,.:/] )+[0-9]+')

def trivial_tokenize(text, lang='hi'):
    """trivial tokenizer for Indian languages"""
    if lang == 'hi':
        tok_str = triv_tokenizer_indic_pat.sub(r' \1 ', text.replace('\t', ' '))
        s = re.sub(r'[ ]+', ' ', tok_str).strip(' ')
        new_s = ''
        prev = 0
        for m in pat_num_seq.finditer(s):
            start, end = m.start(), m.end()
            if start > prev:
                new_s += s[prev:start] + s[start:end].replace(' ', '')
                prev = end
        new_s += s[prev:]
        return new_s.split(' ')

if __name__ == "__main__":
    input_text = sys.stdin.read()
    tokens = trivial_tokenize(input_text)
    print(' '.join(tokens))
