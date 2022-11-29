#!/usr/local/bin/python3

import subprocess
import string
import json

class Component:
    def __init__(self, name, version):
        self.name = name
        self.version= version

    def __str__(self):
        return f"{self.name}: [version: {self.version}]"

bashCommand = "cue eval inputs.cue --out json"
process = subprocess.Popen(bashCommand.split(), stdout=subprocess.PIPE)
output, error = process.communicate()

cue_output = json.loads(output)
# print(cue_output["mesh"])

componentList=[]

mesh_images = cue_output["mesh"]["spec"]["images"]
defaults_images = cue_output["defaults"]["images"]

images = mesh_images | defaults_images

# print(images)
# print(type(images))
for name in images:
    image=images[name]
    print(name)
    print(image)
    x=image.split(":")
    print(f"{x}")
    path=x[0]
    version=x[1]

    print(f"path: {path}")
    print(f"version: {version}\n")
    # if x[0] == "greymatter.jfrog.io":
    #     version=x[2].split(":")[1].split("-")[0]
    # componentList.append(Component(name, version))
    
# for c in componentList:
#     print(c)


