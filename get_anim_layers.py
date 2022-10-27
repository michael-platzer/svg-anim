#!/usr/bin/env python3

import sys
import xml.etree.ElementTree as ET

tree = ET.parse(sys.argv[1])
root = tree.getroot()

layers = {}

for group in root.iter('{http://www.w3.org/2000/svg}g'):
    if group.attrib.get('{http://www.inkscape.org/namespaces/inkscape}groupmode', '') == 'layer':
        layers[group.attrib['id']] = []

        onlys = group.attrib['{http://www.inkscape.org/namespaces/inkscape}label'].split(',')
        for only in onlys:
            tok = only.split('-')
            if len(tok) == 1:
                _range = (int(tok[0]), int(tok[0]))
            elif len(tok) == 2:
                _range = (0 if tok[0] == '' else int(tok[0]), -1 if tok[1] == '' else int(tok[1]))
            else:
                raise ValueError(f"Layer `{onlys}' has invalid range specifier `{only}'")

            layers[group.attrib['id']].append(_range)

anim_steps = max(max(max(start, end) for start, end in val) for key, val in layers.items()) + 1

for idx in range(anim_steps):
    visible = set()
    for key, ranges in layers.items():
        show = False
        for _range in ranges:
            if _range[0] <= idx and (idx <= _range[1] or _range[1] == -1):
                visible.add(key)
                break
    print(' '.join(visible))
