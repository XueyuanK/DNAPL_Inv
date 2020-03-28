#BSUB -q mpi
#BSUB -n 24
#BSUB –o %J.out
#BSUB –e %J.err
comsol server -np 8 -silent -port 2036 -tmpdir temporary_files1 &
sleep 30s
matlab -nodisplay -r three_D_aquifer_HT_SP