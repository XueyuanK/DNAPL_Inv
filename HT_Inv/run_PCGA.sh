#BSUB -q largemem
#BSUB -n 24
#BSUB –o %J.out
#BSUB –e %J.err
python inv_HHT_conti.py