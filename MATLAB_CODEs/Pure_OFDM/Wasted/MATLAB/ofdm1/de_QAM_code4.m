function  data_out=de_QAM_code4(data_in) 
data_length = length(data_in);%求出输入数据长度
re_data_in=real(data_in);%将输入复数序列实部赋值给re_data_in
im_data_in=imag(data_in);%将输入复数序列虚部赋值给im_data_in
%QAM解调
for j=1:data_length
    if  re_data_in(j) < 0 
        data_out(j*2-1) = 0;%实部小于0时，输出相应奇序列为0
    else
        data_out(j*2-1) = 1;%实部大于0时，输出相应奇序列为1
    end
    if im_data_in(j) < 0
        data_out(j*2) = 0;%虚部小于0时，输出相应偶序列为0
       else 
         data_out(j*2) = 1;%虚部大于0时，输出相应偶序列为1
    end
end
        
