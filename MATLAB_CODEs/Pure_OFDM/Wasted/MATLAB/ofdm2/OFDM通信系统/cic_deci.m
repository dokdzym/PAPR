%************************beginning of file*****************************
%cic_deci.m
%���ջ���CIC�˲������
function dout=cic_deci(din,r,init)

%��ȡCIC�˲���ͨ��������ʵ��

%+++++++++++++++++++++++variables++++++++++++++++++++++++++++
% din       ��������
% r         �������ĳ�ȡ����
% init      �趨�ĳ�ʼֵ
% dout      �������
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 

for i=1:length(din),
    int1(i)=sum(din(1:i));
    int2(i)=sum(int1(1:i));
end

data_diff=zeros(1,length(int2)/r);
data_diff=int2(init:r:end);

data_1d=[data_diff,0];
diff1=[0,data_diff]-data_1d;
diff1_1d=[diff1,0];
diff2=[0,diff1]-diff1_1d;
dout=diff2(1:end-2);
% ************************end of file**********************************

