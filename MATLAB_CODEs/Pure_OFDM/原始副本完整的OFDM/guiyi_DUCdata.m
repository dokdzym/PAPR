%************************beginning of file*****************************
%guiyi_DUCdata.m

function [dataout,datamax]=guiyi_DUCdata(datain)

%ʵ�����ݵĹ�һ��

%+++++++++++++++++++++++variables++++++++++++++++++++++++++++
% datain         ��������
% dataout        �������
% datamax        ���������е����ֵ
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 

datamax=max(abs(datain));
dataout=datain./datamax;
% ************************end of file**********************************