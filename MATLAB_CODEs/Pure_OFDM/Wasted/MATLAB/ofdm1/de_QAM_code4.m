function  data_out=de_QAM_code4(data_in) 
data_length = length(data_in);%����������ݳ���
re_data_in=real(data_in);%�����븴������ʵ����ֵ��re_data_in
im_data_in=imag(data_in);%�����븴�������鲿��ֵ��im_data_in
%QAM���
for j=1:data_length
    if  re_data_in(j) < 0 
        data_out(j*2-1) = 0;%ʵ��С��0ʱ�������Ӧ������Ϊ0
    else
        data_out(j*2-1) = 1;%ʵ������0ʱ�������Ӧ������Ϊ1
    end
    if im_data_in(j) < 0
        data_out(j*2) = 0;%�鲿С��0ʱ�������Ӧż����Ϊ0
       else 
         data_out(j*2) = 1;%�鲿����0ʱ�������Ӧż����Ϊ1
    end
end
        
