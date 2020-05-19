%************************beginning of file*****************************
%ram_sin.m
%构造用于DDS的查找表
function [ysin,ycos]=ram_sin(adr)
%dds方式需要的sin表
%ram_sin为寄存器名称
%adr为输入地址,y为读出数据

%+++++++++++++++++++++++variables++++++++++++++++++++++++++++
% adr        输入地址
% ysin       输出的正弦值
% ycos       输出的余弦值
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 

anl_inc=2*pi/128;
for n=1:128
    data_sin(n)=sin((n-1)*anl_inc);
    data_cos(n)=cos((n-1)*anl_inc);
end
ysin=data_sin(adr+1);
ycos=data_cos(adr+1);
% ************************end of file***********************************
