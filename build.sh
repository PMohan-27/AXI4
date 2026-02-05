source venv/bin/activate
cd test
make
gtkwave sim_build/axi4_lite.fst
cd ..
deactivate