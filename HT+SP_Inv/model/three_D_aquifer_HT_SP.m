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
load coord.mat   %measure the obs_HT in all the locations
load coord_SP.mat   %measure the obs_SP in all the locations
HHT=zeros(89,8);
SP=zeros(100,8);
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
HHT(:,i_well) = mphinterp(model,'dl.H','edim',3,'coord',coord_new,'dataset','dset4'); 
model.study('std5').run;
SP(:,i_well) = mphinterp(model,'V','edim',3,'coord',coord_SP,'dataset','dset5'); 
end
HHT=reshape(HHT,89*8,1);
SP=reshape(SP,100*8,1)*1000; %the unit of SP is mV
fid=fopen('./outputHHT.dat','w');
fprintf(fid,'%f\n',HHT);
fprintf(fid,'%f\n',SP);
fclose(fid);
exit;
