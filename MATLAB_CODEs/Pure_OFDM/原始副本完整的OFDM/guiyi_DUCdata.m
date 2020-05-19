%************************beginning of file*****************************
%guiyi_DUCdata.m

function [dataout,datamax]=guiyi_DUCdata(datain)

%实现数据的归一化

%+++++++++++++++++++++++variables++++++++++++++++++++++++++++
% datain         输入数据
% dataout        输出数据
% datamax        输入数据中的最大值
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 

datamax=max(abs(datain));
dataout=datain./datamax;
% ************************end of file**********************************