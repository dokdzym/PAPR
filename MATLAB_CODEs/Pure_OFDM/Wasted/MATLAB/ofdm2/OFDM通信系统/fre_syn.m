%************************beginning of file*****************************
%fre_syn.m

function dout=fre_syn(datai,dataq)
%实现系统的频率同步

%频偏的估计范围由帧长度和循环间隔长度来决定。在
%本系统中，短训练序列的频偏估计范围为 （2000Hz）；长训
%练序列频偏估计范围为250Hz，前一个有较大的纠偏范围，估
%计值得到的方差较大；后一个方法的纠偏范围较小，估计值得
%到的方差较小。频率跟踪可以用循环前后缀的周期重复性来完
%成，其频偏估计范围为125Hz。

%+++++++++++++++++++++++variables++++++++++++++++++++++++++++
% datai         输入数据的实部
% dataq         输入数据的虚部
% dout          输出数据
%++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++ 

global seq_num  
global dingshi  
global m_syn 


if seq_num==1
    if  m_syn(50)>10
     for m=1:128
         fre_back_tmp(m)=(datai(40+m-1)+j*dataq(40+m-1))*conj(datai(40+m-1+16)+j*dataq(40+m-1+16));
     end
     fre_back_sum=sum(fre_back_tmp);
     fre_offset_tmp=-320*angle(fre_back_sum)/(2*pi*16);
     fre_offset=fre_offset_tmp/0.005;
    end
elseif seq_num==2
    for m=1:128
          fre_back_tmp(m)=(datai(dingshi+m-1)+j*dataq(dingshi+m-1))*conj(datai(dingshi+m-1+128)+j*dataq(dingshi+m-1+128));
    end
       fre_back_sum=sum(fre_back_tmp);
       fre_offset_tmp=-320*angle(fre_back_sum)/(2*pi*128);
       fre_offset=fre_offset_tmp/0.005;

elseif seq_num>2
    for m=1:48
      fre_back_tmp(m)=(datai(dingshi+m)+j*dataq(dingshi+m))*conj(datai(dingshi+m+256)+j*dataq(dingshi+m+256));
    end
    fre_back_sum=sum(fre_back_tmp);
    fre_offset_tmp=-320*angle(fre_back_sum)/(2*pi*256);
    fre_offset= fre_offset_tmp/0.005;
end
dout=fre_offset;
% ************************end of file**********************************
