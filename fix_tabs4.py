with open('core/scripts/training_sequence.gd', 'r') as f:
    lines = f.readlines()
with open('core/scripts/training_sequence.gd', 'w') as f:
    for line in lines:
        if line.strip() == "":
            f.write("\n")
            continue
        
        # Count leading whitespace logic
        s = line
        indent_level = 0
        while len(s) > 0 and s[0] in [' ', '\t']:
            if s[0] == '\t':
                indent_level += 1
            elif s[0] == ' ':
                # Let's say 4 empty spaces equals one tab, or 8 spaces
                # in your file it seems there's 8 spaces per level
                pass
            s = s[1:]
            
        # Hardcode the specific block to be absolutely safe
        f.write(line)
