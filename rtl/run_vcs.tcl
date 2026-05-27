pkill -f nWave
rm -r simv *.fsdb ucli.key csrc simv.daidir
vcs -f vlog.f -full64 -debug_access+all +v2k -o simv
./simv
nWave wave.fsdb &
