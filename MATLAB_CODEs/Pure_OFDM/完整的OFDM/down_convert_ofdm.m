%************************beginning of file*****************************
%down_convert_ofdm.m

function [douti,doutq]=down_convert_ofdm(fwc_down,din)
%用DDS的方式实现下变频

%+++++++++++++++++++++++variables++++++++++++++++++++++++++++
% fwc_down      下变频处的频率控制字
% din           输入数据
% douti         输出数据的实部
% doutq         输出数据的虚部
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 

global seq_num   
global count_dds_down
global count_dds_down_tmp

for mkd=1:length(din)
       if (seq_num==1) & (mkd==1)
          count_dds_down=0;
          count_dds_down_tmp=0;
       else 
          count_dds_down=round(count_dds_down_tmp+fwc_down);
          count_dds_down_tmp=count_dds_down_tmp+fwc_down;
          if count_dds_down>=128
             count_dds_down=count_dds_down-128;
             count_dds_down_tmp=count_dds_down_tmp-128;
          end
       end
       [up_sin_d,up_cos_d]=ram_sin(count_dds_down);
       up_sin_td(mkd)=up_sin_d;
       up_cos_td(mkd)=up_cos_d;
   
       DDCdatai(mkd)=din(mkd)*up_cos_td(mkd);
       DDCdataq(mkd)=-din(mkd)*up_sin_td(mkd);
end
douti=DDCdatai;
doutq=DDCdataq;
% ************************end of file**********************************