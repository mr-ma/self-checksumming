INPUT_DEP_PATH=/usr/local/lib
SC_PATH=/home/sip/self-checksumming/build/lib
#$1 is the .c file for transformation
#$2 only protect input dependent functions
echo 'build changes'
make -C build/

clang-3.9 $1 -c -emit-llvm -o guarded.bc
clang-3.9 rtlib.c -c -emit-llvm
echo 'Remove old patch guide file'
rm guide.txt
echo 'Transform'
opt-3.9 -load $INPUT_DEP_PATH/libInputDependency.so -load $SC_PATH/libSCPass.so guarded.bc -sc -input-dependent-functions=$2 -dump-checkers-network="checkers.json" -functions="sc-include" -o guarded.bc
echo 'Link'
llvm-link-3.9 guarded.bc rtlib.bc -o out.bc
echo 'Binary'
clang-3.9 out.bc -o out 

echo 'Post patching'
python patcher/dump_pipe.py out guide.txt patch_guide

echo 'Run'
./out

