#!/bin/sh  

# build
sys/unix/setup.sh sys/unix/hints/linux.500 
make fetch-lua
make && make install

# run
~/nh/install/games/hetnack 
