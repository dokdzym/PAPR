%************************beginning of file*****************************
%up_convert_ofdm.m
%用DDS的方式实现上变频
function dout=up_convert_ofdm(fwc_up,dini,dinq)
%fwc_up是上变频处的频率控制字，每个控制字对应一个载波频率
%count_dds_up是用于查找存储表的整数值，

%+++++++++++++++++++++++variables++++++++++++++++++++++++++++
% fwc_down      上变频处的频率控制字
% dini          输入数据的实部
% dinq          输入数据的虚部
% dout          输出数据
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 

global seq_num
global count_dds_up

for mk=1:length(dini)
    if (seq_num==1) & (mk==1)
        count_dds_up=0;
    else 
        count_dds_up=count_dds_up+fwc_up;
       if count_dds_up>=128
          count_dds_up=count_dds_up-128;
       end
    end
   [up_sin,up_cos]=ram_sin(count_dds_up);
   up_sin_t(mk)=up_sin;
   up_cos_t(mk)=up_cos;
end
for xl=1:length(dini)
    DUCdata(xl)=dini(xl)*up_cos_t(xl)-dinq(xl)*up_sin_t(xl);
end
dout=DUCdata;
% ************************end of file***********************************
