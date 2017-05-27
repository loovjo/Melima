import os
import subprocess
import sys
import time

RED = "\033[38;5;1m"
GREEN = "\033[38;5;10m"
BLUE = "\033[38;5;6m"
BOLD = "\033[1m"
RESET = "\033[0m"


if "-h" in sys.argv[1:] or "--help" in sys.argv[1:]:
    from textwrap import dedent
    
    print(dedent("""\
        Usage: python3 %s [-a] [-h]
        
        %s is a program to compile this project. It compiles and minifies every file in the Source/ directory. 

        Options:
            -a      Only compiles modified files by checking the file hashes from the last compile
            -h      Show this help message
            -H      Set the file to read the hashes from. Default is .hashes
            -M      Don't minify the output, makes the compile faster but less efficient
        """ % (__file__, __file__)))
    sys.exit()

compile_front = True
compile_back = True

FILES_TO_COMPILE = []

if compile_front:
    FILES_TO_COMPILE.append( (("..", "Web", "Out"), ("Front", ), ["Main.elm"],) )

if compile_back:
    FILES_TO_COMPILE.append( (("..", "Back"), ("Back",), ["Server.elm"]) )

CHECK_HASH = "-a" in sys.argv[1:]
HASH_PATH = ".hashes"

if "-H" in sys.argv[1:] and sys.argv[-1] != "-H":
    idx = sys.argv.index("-H")
    HASH_PATH = sys.argv[idx + 1]

hashes = {}

import hashlib
from ast import literal_eval

if os.path.isfile(HASH_PATH):
    try:
        hashes = literal_eval(open(HASH_PATH, "r").read())
    except:
        print("Invalid .hashes file!")
        remake = input("Reinitialize the file? [Y/n] ").lower()
        if remake != "n":
            open(HASH_PATH, "w").close()
else:
    open(HASH_PATH, "w").close()

print("Starting compile...")

compiled = 0
start = time.time()

for proj in FILES_TO_COMPILE:
    for source in proj[2]:
        if source.endswith(".elm"):
            full_path = os.path.join(*proj[1], "Source", source)

            print("\n" + " " * 8 + "=" * 32)
            print()

            changed = True

            if not os.path.isfile(full_path):
                print(RED + "Couldn't find file %s! Aborting!" % full_path + RESET)
                sys.exit()

            content = open(full_path, "r").read()
            file_hash = hashlib.sha256(content.encode("ascii")).hexdigest()

            if full_path in hashes:
                if hashes[full_path] == file_hash:
                    changed = False
            hashes[full_path] = file_hash

            output = os.path.join(*proj[0], source.replace(".elm", ".js"))

            print(BLUE + "Compiling %s -> %s" % (full_path, output) + RESET)

            if not changed and CHECK_HASH:
                print(BLUE + "File not changed since last compile, skipping this file. (Use -a/--all to compile anyway)" + RESET)
                continue

            proc = subprocess.Popen(["elm-make", os.path.join("Source", source), "--output", os.path.join("..", output)], cwd=os.path.join(*proj[1]))
            if proc.wait() != 0:
                print(RED + "Cancelling compile" + RESET)
                sys.exit(1)

            if os.path.exists("../UglifyJS/bin/uglifyjs") and not "-M" in sys.argv[1:]:
                print(BLUE + "Minifying %s" % output + RESET)
                proc = subprocess.Popen(["../UglifyJS/bin/uglifyjs", "--output", output, output])
                if proc.wait() != 0:
                    print(RED + "Cancelling compile" + GREEN)
                    sys.exit(1)
            print(BOLD + "Done compiling %s" % full_path + RESET)
            compiled += 1

compile_time = time.time() - start

print(GREEN + BOLD + "\nCompiled %i %s total, took %.2f seconds" % (compiled, "file" if compiled == 1 else "files", compile_time) + RESET)

hash_file = open(HASH_PATH, "w")
hash_file.write(repr(hashes))
