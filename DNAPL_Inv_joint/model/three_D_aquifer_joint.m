clc
clear
close all

addpath('/home/shi_1/COMSOL54/multiphysics/mli/');
delete('/home/shi_1/.matlab/R2014b/matlabprefs.mat');
mphstart(2036);
model = mphopen('three_D_aquifer_PT_s');

%%
%import the K
model.func('int1').discardData; %int1 is the Tag for interpolation function in comsol
model.func('int1').set('filename', './inputK.dat');
model.func('int1').importData;

%import the Sn
model.func('int4').discardData; %int4 is the Tag for interpolation function in comsol
model.func('int4').set('filename', './inputSn.dat');
model.func('int4').importData;

%%
%defined the coord for observation
load coord.mat   %measure the obs_M1 in all the locations 90
tm1=zeros(89,8);

for i_well=1:8
i_well_str=num2str(i_well);
model.component('comp1').variable('var1').set('i_well', i_well_str);
%run model
model.study('std4').run;
model.study('std5').run; %partitioning
% del the measurements at the injection port
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
tm1(:,i_well) = mphinterp(model,'c','edim',3,'coord',coord_new,'dataset','dset5'); 
end

%limit the M1 > 0
flag1=tm1<0;
tm1(flag1)=0;

tm1=reshape(tm1,89*8,1);
tm1=tm1/(3600*24); % transform to day

fid=fopen('./outputHHT.dat','w');
fprintf(fid,'%f\n',tm1);
fclose(fid);

exit;
