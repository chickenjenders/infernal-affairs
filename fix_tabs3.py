lines = open('core/scripts/training_sequence.gd').readlines()
with open('core/scripts/training_sequence.gd', 'w') as f:
    for line in lines:
        s = line
        while s.startswith('\t '): s = s.replace('\t ', '\t\t', 1)
        while s.startswith('        '): s = s.replace('        ', '\t', 1)
        f.write(s)
