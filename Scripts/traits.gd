extends VBoxContainer

@onready var traits_list = $TraitsBox/TraitsList
@onready var trait_tag_scene = load("res://ui/TraitTag.tscn")

func display_traits(traits: Array):
    # Clear old tags
    for child in traits_list.get_children():
        child.queue_free()
    
    # Add each new tag
    for trait_text in traits:
        var tag = null
        if trait_tag_scene and trait_tag_scene is PackedScene:
            tag = trait_tag_scene.instantiate()
        else:
            tag = Label.new()
        tag.text = trait_text
        traits_list.add_child(tag)
