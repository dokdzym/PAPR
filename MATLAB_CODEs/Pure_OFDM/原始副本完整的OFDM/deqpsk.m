%************************beginning of file*****************************
%deqpsk.m

function dout=deqpsk(din)
%实现QPSK解调

%+++++++++++++++++++++++variables++++++++++++++++++++++++++++
% din        输入数据
% dout       输出数据
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 

dout_temp(1,:)=real(din);
dout_temp(2,:)=imag(din);

dout=reshape(dout_temp,1,length(din)*2);
% ************************end of file**********************************