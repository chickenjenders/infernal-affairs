import json
import os

def convert_twine_json_to_godot(json_file_path, output_gd_path):
    with open(json_file_path, 'r') as f:
        data = json.load(f)
    
    # Twine usually exports a list of passages
    passages = data.get('passages', [])
    godot_dict = {}
    
    for p in passages:
        name = p.get('name', 'start').lower().replace(' ', '_')
        text = p.get('text', '')
        
        # Simple Twine link parser: [[Link Text|TargetName]] or [[TargetName]]
        choices = []
        # Basic regex-less parsing for simplicity in this script
        lines = text.split('\n')
        clean_text = []
        for line in lines:
            if '[[' in line and ']]' in line:
                link_part = line.split('[[')[1].split(']]')[0]
                if '|' in link_part:
                    choice_text, target = link_part.split('|')
                else:
                    choice_text = link_part
                    target = link_part
                choices.append({
                    "text": choice_text.strip(),
                    "next": target.strip().lower().replace(' ', '_')
                })
            else:
                clean_text.append(line)
        
        godot_dict[name] = {
            "text": " ".join(clean_text).strip(),
            "choices": choices
        }

    # Generate the GDScript code
    gd_code = f"extends Node\n\nvar dialogue_data = {json.dumps(godot_dict, indent=4)}\n"
    
    with open(output_gd_path, 'w') as f:
        f.write(gd_code)
    print(f"Converted {len(passages)} passages to {output_gd_path}")

# Example usage (comment out if not needed)
# convert_twine_json_to_godot("my_story.json", "story_dialogue.gd")
