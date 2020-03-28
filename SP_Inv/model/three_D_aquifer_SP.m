clc
clear
close all

addpath('/share/home/shixq2/COMSOL54/multiphysics/mli');
mphstart(2036);
model = mphopen('three_D_aquifer_HT_SP');
%%
%import the logk
model.func('int1').discardData; %int1 is the Tag for interpolation function in comsol
model.func('int1').set('filename', './inputK.dat');
model.func('int1').importData;

%%
%defined the coord for observation
%load coord.mat   %measure the obs_HT in all the locations 90
load coord_SP.mat   %measure the obs_SP in all the locations 100
SP=zeros(100,8);
for i_well=1:8
i_well_str=num2str(i_well);
model.component('comp1').variable('var1').set('i_well', i_well_str);
%run model
model.study('std4').run;
%read the solution at certain point
%HHT(:,i_well) = mphinterp(model,'dl.H','edim',3,'coord',coord,'dataset','dset4'); %measurements for all the time steps
model.study('std5').run;
SP(:,i_well) = mphinterp(model,'V','edim',3,'coord',coord_SP,'dataset','dset5'); 
end
SP=reshape(SP,100*8,1)*1000; %the unit of SP is mV
fid=fopen('./outputSP.dat','w');
%fprintf(fid,'%f\n',HHT);
fprintf(fid,'%f\n',SP);
fclose(fid);
% coord = [15;15.498;8.1094]; %%%%%should be noted: xyz coord are ranged at column!
% T = mphinterp(model,'dl.H','edim',3,'coord',coord,'dataset','dset2','t',30); %dl.H is the head data; t is time
exit;
