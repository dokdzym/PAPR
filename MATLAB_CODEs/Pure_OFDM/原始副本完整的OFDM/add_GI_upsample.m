%************************beginning of file*****************************
%add_GI_upsample.m
%加循环前后缀和升采样程序

function dout=add_CYC_upsample(din,upsample)
%插入循环前后缀是将每个OFDM符号的前32个数据放
%到符号尾部，将每个OFDM符号的后32个数据放到符号头部，
%升采样是通过中间插零的方式实现

%+++++++++++++++++++++++variables++++++++++++++++++++++++++++
% din        输入数据
% upsample   升采样倍数 
% dout       输出数据
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 

data_buf=[din(225:256),din,din(1:32)];

temp(1,:)=data_buf;
temp(2:upsample,:)=zeros(upsample-1,length(data_buf));
dout_temp=reshape(temp,1,length(data_buf)*upsample);
dout=dout_temp(1:end);
% ************************end of file*********************************