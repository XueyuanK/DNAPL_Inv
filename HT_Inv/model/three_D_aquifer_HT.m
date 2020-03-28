clc
clear
close all

addpath('/share/home/shixq1/COMSOL54/multiphysics/mli');
delete('/share/home/shixq1/.matlab/R2019b/matlabprefs.mat');
mphstart(61036);
model = mphopen('three_D_aquifer_HT');
%%
%import the logk
model.func('int1').discardData; %int1 is the Tag for interpolation function in comsol
model.func('int1').set('filename', './inputK.dat');
model.func('int1').importData;

%%
%defined the coord for observation
load coord.mat   %measure the obs_HT in all the locations 90
HHT=zeros(89,8);
for i_well=1:8
i_well_str=num2str(i_well);
model.component('comp1').variable('var1').set('i_well', i_well_str);
%run model
model.study('std4').run;
%delt the location of injection well
 coord_new=coord;
switch i_well
case 1
coord_new(:,1)=[];
case 2 
coord_new(:,15)=[];
case 3
coord_new(:,25)=[];
case 4 
coord_new(:,31)=[];
case 5
coord_new(:,55)=[];
case 6
coord_new(:,61)=[];
case 7
coord_new(:,85)=[];
otherwise
coord_new(:,95)=[];
end
HHT(:,i_well) = mphinterp(model,'dl.H','edim',3,'coord',coord_new,'dataset','dset4'); %measurements for all the time steps
%model.study('std5').run;
%SP(:,i_well) = mphinterp(model,'V','edim',3,'coord',coord_SP,'dataset','dset5'); 
end
HHT=reshape(HHT,89*8,1);
fid=fopen('./outputHT.dat','w');
fprintf(fid,'%f\n',HHT);
fclose(fid);
exit;
