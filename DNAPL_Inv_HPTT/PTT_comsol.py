import numpy as np
import os
import math
import change_coor

class Model:
    def __init__(self, params=None):   

        self.ncores = 16

        if params is not None:
            self.nx = params['nx']
            self.ny = params['ny']
            self.nz = params['nz']
        else:
            raise ValueError("You have to provide relevant parameters")


    def run_model_single(self, logHK):
        '''run PTT in comsol
        '''
        # construct the large logHK matrix
        logHK_large=change_coor.SmallVec2LargeVec(logHK)
        # write sntran to inputK.dat
        ngrid = 30 * 30 * 10
        coor = np.zeros([ngrid, 4])
        os.chdir('.//input_files_single')
        index = 0
        for k in range(0, 10, 1):
            for j in range(0, 30, 1):
                for i in range(0, 30, 1):
                    coor[index, 0] = i
                    coor[index, 1] = j
                    coor[index, 2] = k
                    coor[index, 3] = 1.0/  (  math.exp(-1*logHK_large[index])    +1)
                    index = index + 1
        np.savetxt("inputSn.dat", coor, fmt="%f  %f  %f  %f")
        # run PTT-COMSOL
        os.system('./run_test.sh')
        simul_obs=np.loadtxt('outputHHT.dat')
        os.remove('outputHHT.dat')
        os.chdir("../")
        return simul_obs

    def run_model_parallel(self, logHK):
        '''run PTT in comsol
        '''
        logHK_large=np.zeros([9000,logHK.shape[1]])
        for iterk in range(0, logHK.shape[1], 1):
            logHK_large[0:9000,iterk]=change_coor.SmallVec2LargeVec(logHK[0:3610,iterk])
        # transform all the ensembles of s to input files of COMSOL
        ngrid = 30 * 30 * 10
        coor = np.zeros([ngrid, 4])
        ngroup=int(logHK.shape[1]/self.ncores)
        os.chdir('.//input_files_parallel')

        simul_obs=[]

        for igroup in range(0,ngroup,1):
            logHK_group=logHK_large[:,igroup*self.ncores:(igroup+1)*self.ncores]
            for ireaz in range(0, self.ncores, 1):
                str_dir = './/parallel' + str(ireaz + 1)
                os.chdir(str_dir)
                index = 0
                for k in range(0, 10, 1):
                    for j in range(0, 30, 1):
                        for i in range(0, 30, 1):
                            coor[index, 0] = i
                            coor[index, 1] = j
                            coor[index, 2] = k
                            coor[index, 3] = 1.0/ (math.exp(-1*logHK_group[index,ireaz])+1)
                            index = index + 1
                np.savetxt("inputSn.dat", coor, fmt="%f  %f  %f  %f")
                os.chdir("../")
            # run PTT-COMSOL
            os.system('./run_test.sh')
            # read the observation
            simul_obs_group = np.loadtxt('outputHHT.dat')  # collect all the obs (for one gruop) in this file
            os.remove('outputHHT.dat')
            if simul_obs == []:
                simul_obs = simul_obs_group
            else:
                simul_obs=np.hstack((simul_obs,simul_obs_group))
        os.chdir("../")

        return simul_obs


    def run(self, HK, par, ncores=None):
        if ncores is None:
            ncores = self.ncores

        #delet the matlabprefs.mat for comsol run
        #if os.path.exists('//share//home//shixq2//.matlab//R2015a//matlabprefs.mat'):
        #  os.remove('//share//home//shixq2//.matlab//R2015a//matlabprefs.mat')

        #method_args = range(HK.shape[1])
        #args_map = [(HK[:, arg:arg + 1], arg) for arg in method_args]

        #HK[HK<-1.0986]=-1.0986  #cutoff for sn=0.0

        if par:
            if HK.shape[1]==2:
                simul_obs = self.run_model_single(HK[:,0])   #2 times of forward (3)
                simul_obs = np.vstack((simul_obs,self.run_model_single(HK[:, 1])))
                simul_obs=simul_obs.transpose()
            else:
                simul_obs = self.run_model_parallel(HK) #n_pc forward (2) parallel!
        else:
            simul_obs = self.run_model_single(HK)       #initial forward (1)
            simul_obs.shape = (simul_obs.shape[0], 1)   #transpose the 1d array
        return simul_obs

        # pool.close()
        # pool.join()



if __name__ == '__main__':
    import numpy as np

    params = {'nx': 80, 'ny': 40}

    mymodel = Model(params)

    simul_obs = mymodel.run_model(logHK)

    np.savetxt('obs_true.txt',simul_obs)
    for i in range(0,2040,1):
        simul_obs[i]=simul_obs[i]+np.random.normal(0, 0.01*abs(simul_obs[i]), 1)
    np.savetxt('obs_noise.txt', simul_obs)