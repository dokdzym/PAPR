function  QAM_data=QAM_code4(data_in) 
data_in_pol = bin2pol(data_in) ;% ������������ת��Ϊ��������
data_length = length(data_in_pol);
r = rem(data_length,2);% ������������Ƿ��Ƕ��ı���
if r ~= 0
   data_in_pol(data_length+1) =-1; %�������������в��Ƕ��ı���ʱ�������-1����
end
data_length = length(data_in_pol); %���¼������ݳ���
b=data_length/2;
for j=1:b
    QAM_data(j) = data_in_pol(j*2-1)+i*data_in_pol(j*2);
end
%����������ת��ΪQAM��������