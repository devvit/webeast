rm -rf *.lua
for f in `ls *.moon`; do moonc $f; done; lapis server production
