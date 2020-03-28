import numpy as np


def SmallVec2LargeVec(SmallVec):

    SmallVec=SmallVec.reshape(19,19,10,order='F')
    LargeVec=np.ones([30,30,10])*(-20.0)   # make sure sn=0
    LargeVec[6:25,6:25,0:10]=SmallVec
    LargeVec=LargeVec.reshape(30*30*10,order='F')

    return LargeVec



