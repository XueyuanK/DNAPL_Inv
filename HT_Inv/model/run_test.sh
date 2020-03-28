#!/bin/sh
#BSUB -q largemem
#BSUB -n 24
#BSUB –o %J.out
#BSUB –e %J.err
killall -9 comsollauncher java
sleep 15s
comsol server -np 8 -silent -port 61036 -tmpdir temporary_files1 & 
sleep 30s
matlab -nodisplay -r three_D_aquifer_HT