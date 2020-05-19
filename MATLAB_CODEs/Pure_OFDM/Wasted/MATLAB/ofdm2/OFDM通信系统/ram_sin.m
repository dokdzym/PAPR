%************************beginning of file*****************************
%ram_sin.m
%��������DDS�Ĳ��ұ�
function [ysin,ycos]=ram_sin(adr)
%dds��ʽ��Ҫ��sin��
%ram_sinΪ�Ĵ�������
%adrΪ�����ַ,yΪ��������

%+++++++++++++++++++++++variables++++++++++++++++++++++++++++
% adr        �����ַ
% ysin       ���������ֵ
% ycos       ���������ֵ
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 

anl_inc=2*pi/128;
for n=1:128
    data_sin(n)=sin((n-1)*anl_inc);
    data_cos(n)=cos((n-1)*anl_inc);
end
ysin=data_sin(adr+1);
ycos=data_cos(adr+1);
% ************************end of file***********************************
