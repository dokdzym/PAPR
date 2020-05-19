%************************beginning of file*****************************
%up_convert_ofdm.m
%��DDS�ķ�ʽʵ���ϱ�Ƶ
function dout=up_convert_ofdm(fwc_up,dini,dinq)
%fwc_up���ϱ�Ƶ����Ƶ�ʿ����֣�ÿ�������ֶ�Ӧһ���ز�Ƶ��
%count_dds_up�����ڲ��Ҵ洢�������ֵ��

%+++++++++++++++++++++++variables++++++++++++++++++++++++++++
% fwc_down      �ϱ�Ƶ����Ƶ�ʿ�����
% dini          �������ݵ�ʵ��
% dinq          �������ݵ��鲿
% dout          �������
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
