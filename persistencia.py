import json, sys, os

asignatura = sys.argv[1]
path_practica = sys.argv[2]
print(asignatura + " " + path_practica)
json_path = os.getcwd() + "/" + "paths.json"
with open(json_path) as f:
	jsony = json.load(f)
	print(jsony)
	jsony[asignatura] = path_practica 
with open(json_path, "w") as f:
	json.dump(jsony, f, indent = 4)
