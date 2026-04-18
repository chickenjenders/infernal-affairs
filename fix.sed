/func load_slides() -> void:/,/print("An error occurred/c\
func load_slides() -> void:\
        var dir = DirAccess.open("res://assets/phishing/")\
        if dir:\
                dir.list_dir_begin()\
                var file_name = dir.get_next()\
                var slide_paths = []\
                while file_name != "":\
                        var actual_name = file_name.replace(".import", "")\
                        if not dir.current_is_dir() and actual_name.ends_with(".png"):\
                                var path = "res://assets/phishing/" + actual_name\
                                if not slide_paths.has(path):\
                                        slide_paths.append(path)\
                        file_name = dir.get_next()\
\
                # Sort paths to ensure 1, 2, 3... order\
                slide_paths.sort()\
\
                for path in slide_paths:\
                        var texture = load(path)\
                        if texture is Texture2D:\
                                slides.append(texture)\
        else:\
                print("An error occurred when trying to access the phishing assets folder.")\
