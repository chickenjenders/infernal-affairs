import re

with open('core/scenes/securityquestions.tscn', 'r') as f:
    content = f.read()

# Make sure to update the load_steps
content = re.sub(r'load_steps=9', 'load_steps=13', content)

# We need the ext_resource for Garet-Heavy.otf if it's not already there.
# Let's see if we can just use Garet-Heavy.ttf (id=3_c8ywn) for both.
# That makes it easier!

style_boxes = """
[sub_resource type="StyleBoxFlat" id="StyleBoxFlat_846tc"]
bg_color = Color(0.88, 0.8594667, 0.8184, 1)
border_width_left = 5
border_width_top = 5
border_width_right = 5
border_width_bottom = 5
border_color = Color(0, 0, 0, 1)
corner_radius_top_left = 15
corner_radius_top_right = 15
corner_radius_bottom_right = 15
corner_radius_bottom_left = 15

[sub_resource type="StyleBoxFlat" id="StyleBoxFlat_ssjav"]
bg_color = Color(0.6, 0, 0, 1)
corner_radius_top_left = 20
corner_radius_top_right = 20
corner_radius_bottom_right = 20
corner_radius_bottom_left = 20

[sub_resource type="StyleBoxFlat" id="StyleBoxFlat_w3p4h"]
bg_color = Color(0.9384885, 0.16622159, 0.15112776, 1)
corner_radius_top_left = 20
corner_radius_top_right = 20
corner_radius_bottom_right = 20
corner_radius_bottom_left = 20
"""

# Insert style boxes before the node
content = content.replace('[node name="security_questions"', style_boxes + '\n[node name="security_questions"')

panel_node = """
[node name="SecurityLabel" type="Panel" parent="."]
layout_mode = 0
offset_left = 442.0
offset_top = 196.0
offset_right = 1160.0
offset_bottom = 540.0
theme_override_styles/panel = SubResource("StyleBoxFlat_846tc")

[node name="Label" type="Label" parent="SecurityLabel"]
layout_mode = 0
offset_left = 42.0
offset_top = 52.0
offset_right = 702.0
offset_bottom = 185.0
theme_override_colors/font_color = Color(0.72402245, 0, 0.09185388, 1)
theme_override_colors/font_outline_color = Color(0, 0, 0, 1)
theme_override_constants/outline_size = 2
theme_override_fonts/font = ExtResource("3_c8ywn")
theme_override_font_sizes/font_size = 40
text = "SECURITY"
horizontal_alignment = 1
vertical_alignment = 1
autowrap_mode = 2

[node name="Button" type="Button" parent="SecurityLabel"]
layout_mode = 0
offset_left = 247.0
offset_top = 220.0
offset_right = 486.0
offset_bottom = 289.0
theme_override_fonts/font = ExtResource("3_c8ywn")
theme_override_font_sizes/font_size = 30
theme_override_styles/normal = SubResource("StyleBoxFlat_ssjav")
theme_override_styles/hover = SubResource("StyleBoxFlat_w3p4h")
text = "START"
"""

content = content.replace('[node name="popup" parent="." instance=ExtResource("5_jltq0")]', panel_node + '\n[node name="popup" parent="." instance=ExtResource("5_jltq0")]')

with open('core/scenes/securityquestions.tscn', 'w') as f:
    f.write(content)

