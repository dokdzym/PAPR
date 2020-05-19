function  QAM_data=QAM_code4(data_in) 
data_in_pol = bin2pol(data_in) ;% 将二进制数据转化为极点数据
data_length = length(data_in_pol);
r = rem(data_length,2);% 检查输入数据是否是二的倍数
if r ~= 0
   data_in_pol(data_length+1) =-1; %当输入数据序列不是二的倍数时在最后填-1补充
end
data_length = length(data_in_pol); %重新计算数据长度
b=data_length/2;
for j=1:b
    QAM_data(j) = data_in_pol(j*2-1)+i*data_in_pol(j*2);
end
%将极点数据转化为QAM复数序列