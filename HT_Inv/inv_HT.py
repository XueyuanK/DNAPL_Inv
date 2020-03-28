import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
import numpy as np
from pyPCGA import PCGA
import HT_comsol
import math
import datetime as dt
import os
import sys
import dill 

# para initialization
nx = 30
ny = 30
nz=10
npara=nx*ny*nz
Lx = 30.; Ly = 30.; Lz = 10;

# seems confusing considering flopy notation, remember python array ordering of col, row and lay
N = np.array([nx, ny, nz])
m = np.prod(N)
dx = np.array([1., 1., 1.])
xmin = np.array([0. + dx[0] / 2., 0. + dx[1] / 2., 0. + dx[2] / 2.])
xmax = np.array([Lx - dx[0] / 2., Ly - dx[1] / 2., Lz - dx[2] / 2.])

# covairance kernel and scale parameters
prior_std = 2.0**0.5
prior_cov_scale = np.array([15., 15., 3.])

def kernel(r): return (prior_std ** 2) * np.exp(-r)  

# for plotting
x = np.linspace(0. + dx[0] / 2., Lx - dx[0] / 2., N[0])
y = np.linspace(0. + dx[1] / 2., Ly - dx[1] / 2., N[1])
XX, YY = np.meshgrid(x, y)
pts = np.hstack((XX.ravel()[:, np.newaxis], YY.ravel()[:, np.newaxis]))

# load true value for comparison purpose
s_true = np.loadtxt('true_lnk.txt')
#s_true = np.array(s_true).reshape(-1, 1)  # make it 2D array

obs = np.loadtxt('obs.txt')

HT_params = params = {'nx': nx, 'ny': ny, 'nz': nz,}


def forward_model(s, parallelization, ncores=None):
    model = HT_comsol.Model(HT_params)

    if parallelization:
        simul_obs = model.run(s, parallelization, ncores)
    else:
        simul_obs = model.run(s, parallelization)
    return simul_obs


params = {'R': 0.05** 2, 'n_pc': 98,
          'maxiter': 10, 'restol': 0.01,
          'matvec': 'FFT', 'xmin': xmin, 'xmax': xmax, 'N': N,
          'prior_std': prior_std, 'prior_cov_scale': prior_cov_scale,
          'kernel': kernel, 'post_cov': "diag",
          'precond': True, 'LM': True, #'alphamax_LM': 50.0,  #'LM_smin' : 1.0, 'LM_smax' : 4.0,
          'parallel': True, 'ncores': 20, 'linesearch': True,
          'forward_model_verbose': False, 'verbose': False,
          'iter_save': True}

# params['objeval'] = False, if true, it will compute accurate objective function
# params['ncores'] = 36, with parallell True, it will determine maximum physcial core unless specified
params['Continue'] = False

s_init = np.ones((m, 1))*(-11)
#s_init = np.copy(s_true) # you can try with s_true!

# initialize
prob = PCGA(forward_model, s_init, pts, params, s_true, obs)
# prob = PCGA(forward_model, s_init, pts, params, s_true, obs, X = X) #if you want to add your own drift X

# run inversion
s_hat, simul_obs, post_diagv, iter_best = prob.Run()

#save all the variables
#dill.dump_session('PCGAresults.pkl')
