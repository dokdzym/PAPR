%************************beginning of file*****************************
%deqpsk.m

function dout=deqpsk(din)
%ʵ��QPSK���

%+++++++++++++++++++++++variables++++++++++++++++++++++++++++
% din        ��������
% dout       �������
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 

dout_temp(1,:)=real(din);
dout_temp(2,:)=imag(din);

dout=reshape(dout_temp,1,length(din)*2);
% ************************end of file**********************************