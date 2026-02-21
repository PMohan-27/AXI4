source ../venv/bin/activate
cd test
make
gtkwave dump.fst
cd ..
deactivate