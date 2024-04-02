source = "cdiiddwpgswtgt"

def rotate_character(c, n):
    return chr((ord(c) - ord('a') + n) % 26 + ord('a'))
    
for n in range(1, 26):
    print(''.join(rotate_character(c, n) for c in source))