/func load_slides() -> void/,/print("An error occurred/ {
s/^[ \t]*var dir/\tvar dir/
s/^[ \t]*if dir:/\tif dir:/
s/^[ \t]*dir.list/\t\tdir.list/
s/^[ \t]*var file_name/\t\tvar file_name/
s/^[ \t]*var slide_paths/\t\tvar slide_paths/
s/^[ \t]*while file_name/\t\twhile file_name/
s/^[ \t]*var actual_name/\t\t\tvar actual_name/
s/^[ \t]*if not dir.curr/\t\t\tif not dir.curr/
s/^[ \t]*var path =/\t\t\t\tvar path =/
s/^[ \t]*if not slide_paths.has/\t\t\t\tif not slide_paths.has/
s/^[ \t]*slide_paths.append/\t\t\t\t\tslide_paths.append/
s/^[ \t]*file_name = dir.get_next()/\t\t\tfile_name = dir.get_next()/
s/^[ \t]*# Sort/\t\t# Sort/
s/^[ \t]*slide_paths.sort/\t\tslide_paths.sort/
s/^[ \t]*for path in slide_paths/\t\tfor path in slide_paths/
s/^[ \t]*var texture =/\t\t\tvar texture =/
s/^[ \t]*if texture is/\t\t\tif texture is/
s/^[ \t]*slides.append(texture)/\t\t\t\tslides.append(texture)/
s/^[ \t]*else:/\telse:/
s/^[ \t]*print("An error/\t\tprint("An error/
}
