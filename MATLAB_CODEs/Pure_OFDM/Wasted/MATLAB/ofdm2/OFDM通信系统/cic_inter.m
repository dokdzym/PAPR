%************************beginning of file*****************************
%cic_inter.m
%�������CIC�˲������
function dout=cic_inter(din,r)

%��ֵCIC�˲���ͨ��������ֵʵ��������

%+++++++++++++++++++++++variables++++++++++++++++++++++++++++
% din       ��������
% r         �������Ĳ�ֵ����
% dout      �������
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 

din_1d=[0,din];
diff1=[din,0]-din_1d;
diff1_1d=[0,diff1(1:end-1)];
diff2=[diff1(1:end-1),0]-diff1_1d;
for i=1:r
  temp1(i,:)=diff2(1:end-1);
end
temp2=reshape(temp1,1,length(diff2(1:end-1))*r);
data_int=temp2;
for i=1:length(data_int)
    int1(i)=sum(data_int(1:i));
    int2(i)=sum(int1(1:i));
end
dout=int2;
%************************end of file**********************************

