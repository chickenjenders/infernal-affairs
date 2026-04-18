with open("core/scripts/training_sequence.gd", "r") as f:
    lines = f.readlines()

for i, line in enumerate(lines):
    if line.startswith("func load_slides() -> void:"):
        start = i
        break

code = [
    "func load_slides() -> void:\n",
    "\tvar dir = DirAccess.open(\"res://assets/phishing/\")\n",
    "\tif dir:\n",
    "\t\tdir.list_dir_begin()\n",
    "\t\tvar file_name = dir.get_next()\n",
    "\t\tvar slide_paths = []\n",
    "\t\twhile file_name != \"\":\n",
    "\t\t\tvar actual_name = file_name.replace(\".import\", \"\")\n",
    "\t\t\tif not dir.current_is_dir() and actual_name.ends_with(\".png\"):\n",
    "\t\t\t\tvar path = \"res://assets/phishing/\" + actual_name\n",
    "\t\t\t\tif not slide_paths.has(path):\n",
    "\t\t\t\t\tslide_paths.append(path)\n",
    "\t\t\tfile_name = dir.get_next()\n",
    "\n",
    "\t\t# Sort paths to ensure 1, 2, 3... order\n",
    "\t\tslide_paths.sort()\n",
    "\n",
    "\t\tfor path in slide_paths:\n",
    "\t\t\tvar texture = load(path)\n",
    "\t\t\tif texture is Texture2D:\n",
    "\t\t\t\tslides.append(texture)\n",
    "\telse:\n",
    "\t\tprint(\"An error occurred when trying to access the phishing assets folder.\")\n"
]

for i, line in enumerate(lines):
    if line.startswith("func show_slide"):
        end = i
        break

lines = lines[:start] + code + ["\n"] + lines[end:]

with open("core/scripts/training_sequence.gd", "w") as f:
    f.writelines(lines)
