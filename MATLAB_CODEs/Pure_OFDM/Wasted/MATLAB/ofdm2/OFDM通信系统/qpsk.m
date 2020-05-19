%************************beginning of file*****************************
%qpsk.m
%QPSK����ӳ��
function dout=qpsk(din)

%+++++++++++++++++++++++variables++++++++++++++++++++++++++++
% din        ��������
% dout       �������
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 

din2=1-2*din;
din_temp=reshape(din2,2,length(din)/2);
for i=1:length(din)/2,
    dout(i)=din_temp(1,i)+j*din_temp(2,i);
end
% ************************end of file***********************************
