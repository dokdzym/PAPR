%************************beginning of file*****************************
%add_GI_upsample.m
%��ѭ��ǰ��׺������������

function dout=add_CYC_upsample(din,upsample)
%����ѭ��ǰ��׺�ǽ�ÿ��OFDM���ŵ�ǰ32�����ݷ�
%������β������ÿ��OFDM���ŵĺ�32�����ݷŵ�����ͷ����
%��������ͨ���м����ķ�ʽʵ��

%+++++++++++++++++++++++variables++++++++++++++++++++++++++++
% din        ��������
% upsample   ���������� 
% dout       �������
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 

data_buf=[din(225:256),din,din(1:32)];

temp(1,:)=data_buf;
temp(2:upsample,:)=zeros(upsample-1,length(data_buf));
dout_temp=reshape(temp,1,length(data_buf)*upsample);
dout=dout_temp(1:end);
% ************************end of file*********************************